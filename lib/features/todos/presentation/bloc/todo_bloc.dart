import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/todo_repository.dart';
import '../../data/models/todo_model.dart';
import '../../domain/entities/todo_entity.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository _repository;
  List<TodoEntity> _currentTodos = [];
  String _searchQuery = '';
  final Set<int> _pendingDeletedIds = {};

  int get _pendingCount =>
      _currentTodos
          .whereType<TodoModel>()
          .where((todo) => !todo.isSynced)
          .length +
      _pendingDeletedIds.length;

  List<TodoEntity> get _filteredTodos {
    if (_searchQuery.isEmpty) return _currentTodos;
    final query = _searchQuery.toLowerCase();
    return _currentTodos
        .where((todo) => todo.title.toLowerCase().contains(query))
        .toList();
  }

  TodoBloc({required TodoRepository repository})
    : _repository = repository,
      super(TodoInitial()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<SearchTodosEvent>(_onSearchTodos);
    on<AddTodoEvent>(_onAddTodo);
    on<UpdateTodoTitleEvent>(_onUpdateTodoTitle);
    on<UpdateTodoCompletedEvent>(_onUpdateTodoCompleted);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<SyncTodosEvent>(_onSyncTodos);
  }

  Future<void> _onLoadTodos(
    LoadTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    emit(TodosLoadInProgress());
    final result = await _repository.getTodos();
    await result.fold(
      (failure) async {
        final cacheResult = await _repository.getCachedTodosOnly();
        cacheResult.fold(
          (_) => emit(TodosLoadFailure(message: failure.message)),
          (cached) {
            _currentTodos = cached;
            emit(
              TodosLoadSuccess(
                todos: _filteredTodos,
                pendingCount: _pendingCount,
              ),
            );
            emit(TodosServerError(message: failure.message));
          },
        );
      },
      (todos) async {
        _currentTodos = todos;
        emit(
          TodosLoadSuccess(todos: _filteredTodos, pendingCount: _pendingCount),
        );
      },
    );
  }

  void _onSearchTodos(SearchTodosEvent event, Emitter<TodoState> emit) {
    _searchQuery = event.query.trim().toLowerCase();
    emit(TodosLoadSuccess(todos: _filteredTodos, pendingCount: _pendingCount));
  }

  Future<void> _onAddTodo(AddTodoEvent event, Emitter<TodoState> emit) async {
    final tempId = DateTime.now().millisecondsSinceEpoch;
    _currentTodos = [
      TodoModel(
        id: tempId,
        userId: 1,
        title: event.title,
        completed: false,
        isSynced: true,
      ),
      ..._currentTodos,
    ];
    emit(TodosLoadSuccess(todos: _filteredTodos, pendingCount: _pendingCount));
    emit(TodoAddInProgress());
    final result = await _repository.addTodo(event.title, tempId);
    result.fold(
      (failure) {
        _currentTodos = _currentTodos
            .where((todo) => todo.id != tempId)
            .toList();
        emit(
          TodosLoadSuccess(todos: _filteredTodos, pendingCount: _pendingCount),
        );
        emit(TodoAddFailure(message: failure.message));
      },
      (addedTodo) {
        _currentTodos = _currentTodos.map((todo) {
          if (todo.id == tempId) {
            return addedTodo;
          }
          return todo;
        }).toList();

        emit(
          TodosLoadSuccess(todos: _filteredTodos, pendingCount: _pendingCount),
        );
        emit(TodoAddSuccess());
      },
    );
  }

  Future<void> _onUpdateTodoTitle(
    UpdateTodoTitleEvent event,
    Emitter<TodoState> emit,
  ) async {
    final original = _currentTodos.firstWhere((todo) => todo.id == event.id);
    _currentTodos = _currentTodos.map((todo) {
      if (todo.id == event.id) {
        return TodoModel(
          id: todo.id,
          userId: todo.userId,
          title: event.title,
          completed: todo.completed,
          isSynced: true,
        );
      }
      return todo;
    }).toList();
    emit(TodosLoadSuccess(todos: _filteredTodos, pendingCount: _pendingCount));
    emit(TodoUpdateInProgress());
    final result = await _repository.updateTodoTitle(event.id, event.title);
    result.fold(
      (failure) {
        _currentTodos = _currentTodos
            .map((todo) => todo.id == event.id ? original : todo)
            .toList();
        emit(
          TodosLoadSuccess(todos: _filteredTodos, pendingCount: _pendingCount),
        );
        emit(TodoUpdateFailure(message: failure.message));
      },
      (updatedTodo) {
        if (updatedTodo is TodoModel && !updatedTodo.isSynced) {
          _currentTodos = _markUnsynced(_currentTodos, event.id);
          emit(
            TodosLoadSuccess(
              todos: _filteredTodos,
              pendingCount: _pendingCount,
            ),
          );
        }
        emit(TodoUpdateSuccess());
      },
    );
  }

  Future<void> _onUpdateTodoCompleted(
    UpdateTodoCompletedEvent event,
    Emitter<TodoState> emit,
  ) async {
    final original = _currentTodos.firstWhere((todo) => todo.id == event.id);
    _currentTodos = _currentTodos.map((todo) {
      if (todo.id == event.id) {
        return TodoModel(
          id: todo.id,
          userId: todo.userId,
          title: todo.title,
          completed: event.completed,
          isSynced: true,
        );
      }
      return todo;
    }).toList();
    emit(TodosLoadSuccess(todos: _filteredTodos, pendingCount: _pendingCount));
    emit(TodoUpdateInProgress());
    final result = await _repository.updateTodoCompleted(
      event.id,
      event.completed,
    );
    result.fold(
      (failure) {
        _currentTodos = _currentTodos
            .map((todo) => todo.id == event.id ? original : todo)
            .toList();
        emit(
          TodosLoadSuccess(todos: _filteredTodos, pendingCount: _pendingCount),
        );
        emit(TodoUpdateFailure(message: failure.message));
      },
      (updatedTodo) {
        if (updatedTodo is TodoModel && !updatedTodo.isSynced) {
          _currentTodos = _markUnsynced(_currentTodos, event.id);
          emit(
            TodosLoadSuccess(
              todos: _filteredTodos,
              pendingCount: _pendingCount,
            ),
          );
        }
        emit(TodoUpdateSuccess());
      },
    );
  }

  Future<void> _onDeleteTodo(
    DeleteTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    final deletedTodo = _currentTodos.firstWhere((todo) => todo.id == event.id);
    final deletedTodoIndex = _currentTodos.indexWhere(
      (todo) => todo.id == event.id,
    );
    _currentTodos = _currentTodos.where((todo) => todo.id != event.id).toList();
    emit(TodosLoadSuccess(todos: _filteredTodos, pendingCount: _pendingCount));
    emit(TodoDeleteInProgress());
    final result = await _repository.deleteTodo(event.id);
    result.fold(
      (failure) {
        _currentTodos.insert(deletedTodoIndex, deletedTodo);
        emit(
          TodosLoadSuccess(todos: _filteredTodos, pendingCount: _pendingCount),
        );
        emit(TodoDeleteFailure(message: failure.message));
      },
      (isPending) {
        if (isPending) {
          _pendingDeletedIds.add(event.id);
          emit(
            TodosLoadSuccess(
              todos: _filteredTodos,
              pendingCount: _pendingCount,
            ),
          );
        }
        emit(TodoDeleteSuccess());
      },
    );
  }

  Future<void> _onSyncTodos(
    SyncTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    final pendingCountBeforeSync = _pendingCount;
    emit(
      TodosLoadSuccess(
        todos: _filteredTodos,
        pendingCount: pendingCountBeforeSync,
        isSyncing: true,
      ),
    );
    final result = await _repository.syncPendingChanges();
    result.fold(
      (_) => emit(
        TodosLoadSuccess(
          todos: _filteredTodos,
          pendingCount: _pendingCount,
          isSyncing: false,
        ),
      ),
      (syncedIds) {
        _currentTodos = _currentTodos.map((todo) {
          if (syncedIds.contains(todo.id) && todo is TodoModel) {
            return todo.copyWith(isSynced: true);
          }
          return todo;
        }).toList();
        _pendingDeletedIds.removeAll(syncedIds);
        emit(
          TodosLoadSuccess(
            todos: _filteredTodos,
            pendingCount: _pendingCount,
            isSyncing: false,
          ),
        );
        if (pendingCountBeforeSync > 0) {
          emit(syncedIds.isNotEmpty ? SyncSuccess() : SyncFailure());
        }
      },
    );
  }

  List<TodoEntity> _markUnsynced(List<TodoEntity> todos, int id) {
    return todos.map((todo) {
      if (todo.id == id && todo is TodoModel) {
        return todo.copyWith(isSynced: false);
      }
      return todo;
    }).toList();
  }
}
