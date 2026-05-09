import 'package:fpdart/fpdart.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network_info/network_info.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../datasources/todo_remote_datasource.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource _remoteDataSource;
  final TodoLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final DatabaseHelper _databaseHelper;

  TodoRepositoryImpl({
    required TodoRemoteDataSource remoteDataSource,
    required TodoLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
    required DatabaseHelper databaseHelper,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _databaseHelper = databaseHelper;

  @override
  Future<Either<Failure, List<TodoEntity>>> getTodos() async {
    if (await _networkInfo.isConnected) {
      try {
        final todos = await _remoteDataSource.getTodos();
        await _localDataSource.cacheTodos(todos);
        return right(todos);
      } on ServerException catch (e) {
        return left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final todos = await _localDataSource.getCachedTodos();
        return right(todos);
      } on CacheException catch (e) {
        return left(CacheFailure(message: e.message));
      }
    }
  }

  @override
  Future<Either<Failure, List<TodoEntity>>> getCachedTodosOnly() async {
    try {
      final todos = await _localDataSource.getCachedTodos();
      return right(todos);
    } on CacheException catch (e) {
      return left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, TodoEntity>> addTodo(String title, int tempId) async {
    final localTodo = TodoModel(
      id: tempId,
      userId: 1,
      title: title,
      completed: false,
      isSynced: false,
    );
    await _localDataSource.insertTodo(localTodo);

    if (await _networkInfo.isConnected) {
      try {
        final serverTodo = await _remoteDataSource.addTodo(title);
        final db = await _databaseHelper.database;
        await db.delete('todos', where: 'id = ?', whereArgs: [tempId]);
        //!dummy api always returns id 201, so we need to use the tempId to prevent unique id crash on local db
        await _localDataSource.insertTodo(
          serverTodo.copyWith(id: tempId, isSynced: true),
        );
        //!dummy api always returns id 201, so we need to use the tempId to prevent unique id crash on local db
        return right(serverTodo.copyWith(id: tempId, isSynced: true));
      } on ServerException catch (e) {
        final db = await _databaseHelper.database;
        await db.delete('todos', where: 'id = ?', whereArgs: [tempId]);
        return left(ServerFailure(message: e.message));
      }
    } else {
      return right(localTodo);
    }
  }

  @override
  Future<Either<Failure, TodoEntity>> updateTodoTitle(
    int id,
    String title,
  ) async {
    final cached = await _localDataSource.getCachedTodos();
    final existing = cached.firstWhere((todo) => todo.id == id);
    final updatedLocal = existing.copyWith(title: title, isSynced: false);
    await _localDataSource.updateTodo(updatedLocal);

    if (await _networkInfo.isConnected) {
      try {
        final serverTodo = await _remoteDataSource.updateTodo(
          id,
          title,
          existing.completed,
        );
        await _localDataSource.markSynced(id);
        return right(serverTodo);
      } on ServerException catch (e) {
        await _localDataSource.updateTodo(existing);
        return left(ServerFailure(message: e.message));
      }
    } else {
      return right(updatedLocal);
    }
  }

  @override
  Future<Either<Failure, TodoEntity>> updateTodoCompleted(
    int id,
    bool completed,
  ) async {
    final cached = await _localDataSource.getCachedTodos();
    final existing = cached.firstWhere((todo) => todo.id == id);
    final updatedLocal = existing.copyWith(
      completed: completed,
      isSynced: false,
    );
    await _localDataSource.updateTodo(updatedLocal);

    if (await _networkInfo.isConnected) {
      try {
        final serverTodo = await _remoteDataSource.updateTodo(
          id,
          existing.title,
          completed,
        );
        await _localDataSource.markSynced(id);
        return right(serverTodo);
      } on ServerException catch (e) {
        await _localDataSource.updateTodo(existing);
        return left(ServerFailure(message: e.message));
      }
    } else {
      return right(updatedLocal);
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTodo(int id) async {
    await _localDataSource.softDeleteTodo(id);

    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.deleteTodo(id);
        final db = await _databaseHelper.database;
        await db.delete('todos', where: 'id = ?', whereArgs: [id]);
        return right(unit);
      } on ServerException catch (e) {
        await _localDataSource.restoreTodo(id);
        return left(ServerFailure(message: e.message));
      }
    } else {
      return right(unit);
    }
  }

  @override
  Future<Either<Failure, Set<int>>> syncPendingChanges() async {
    final syncedIds = <int>{};
    try {
      final pending = await _localDataSource.getPendingSync();
      final db = await _databaseHelper.database;
      for (final item in pending) {
        try {
          final rows = await db.query(
            'todos',
            where: 'id = ?',
            whereArgs: [item.id],
          );
          if (rows.isEmpty) continue;
          final isDeleted = (rows.first['is_deleted'] as int) == 1;
          if (isDeleted) {
            await _remoteDataSource.deleteTodo(item.id);
            await db.delete('todos', where: 'id = ?', whereArgs: [item.id]);
          } else {
            await _remoteDataSource.updateTodo(
              item.id,
              item.title,
              item.completed,
            );
            await _localDataSource.markSynced(item.id);
          }
          syncedIds.add(item.id);
        } catch (_) {}
      }
    } catch (_) {}
    return right(syncedIds);
  }
}
