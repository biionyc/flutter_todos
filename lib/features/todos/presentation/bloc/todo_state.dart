import '../../domain/entities/todo_entity.dart';

abstract class TodoState {}

class TodoInitial extends TodoState {}

class TodosLoadInProgress extends TodoState {}

class TodosLoadSuccess extends TodoState {
  final List<TodoEntity> todos;
  final int pendingCount;
  final bool isSyncing;

  TodosLoadSuccess({
    required this.todos,
    this.isSyncing = false,
    this.pendingCount = 0,
  });
}

class TodosLoadFailure extends TodoState {
  final String message;

  TodosLoadFailure({required this.message});
}

class TodoAddInProgress extends TodoState {}

class TodoAddSuccess extends TodoState {}

class TodoAddFailure extends TodoState {
  final String message;

  TodoAddFailure({required this.message});
}

class TodoUpdateInProgress extends TodoState {}

class TodoUpdateSuccess extends TodoState {}

class TodoUpdateFailure extends TodoState {
  final String message;

  TodoUpdateFailure({required this.message});
}

class TodoDeleteInProgress extends TodoState {}

class TodoDeleteSuccess extends TodoState {}

class TodoDeleteFailure extends TodoState {
  final String message;

  TodoDeleteFailure({required this.message});
}

class TodosServerError extends TodoState {
  final String message;

  TodosServerError({required this.message});
}

class SyncSuccess extends TodoState {}

class SyncFailure extends TodoState {}
