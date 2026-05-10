import 'package:fpdart/fpdart.dart';
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

  TodoRepositoryImpl({
    required TodoRemoteDataSource remoteDataSource,
    required TodoLocalDataSource localDataSource,
    required NetworkInfo networkInfo,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, List<TodoEntity>>> getTodos() async {
    if (await _networkInfo.isConnected) {
      try {
        final todos = await _remoteDataSource.getTodos();
        await _localDataSource.cacheTodos(todos);
        return right(todos);
      } on ServerException catch (e) {
        try {
          final cached = await _localDataSource.getCachedTodos();
          return left(
            ServerFailureWithCache(message: e.message, cachedData: cached),
          );
        } catch (_) {
          return left(ServerFailure(message: e.message));
        }
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
        await _localDataSource.hardDeleteTodo(tempId);
        //!dummy api always returns id 201, so we need to use the tempId to prevent unique id crash on local db
        await _localDataSource.insertTodo(
          serverTodo.copyWith(id: tempId, isSynced: true),
        );
        //!dummy api always returns id 201, so we need to use the tempId to prevent unique id crash on local db
        return right(serverTodo.copyWith(id: tempId, isSynced: true));
      } on ServerException catch (e) {
        await _localDataSource.hardDeleteTodo(tempId);
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
    final existing = await _localDataSource.getTodoById(id);
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
    final existing = await _localDataSource.getTodoById(id);
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
  Future<Either<Failure, bool>> deleteTodo(int id) async {
    await _localDataSource.softDeleteTodo(id);

    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.deleteTodo(id);
        await _localDataSource.hardDeleteTodo(id);
        return right(false);
      } on ServerException catch (e) {
        await _localDataSource.restoreTodo(id);
        return left(ServerFailure(message: e.message));
      }
    } else {
      return right(true);
    }
  }

  @override
  Future<Either<Failure, int>> getPendingDeletedCount() async {
    try {
      final count = await _localDataSource.getPendingDeletedCount();
      return right(count);
    } catch (e) {
      return left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Set<int>>> syncPendingChanges() async {
    final syncedIds = <int>{};
    try {
      final pending = await _localDataSource.getPendingSync();
      for (final item in pending) {
        try {
          final isDeleted = await _localDataSource.isTodoDeleted(item.id);
          if (isDeleted) {
            await _remoteDataSource.deleteTodo(item.id);
            await _localDataSource.hardDeleteTodo(item.id);
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
