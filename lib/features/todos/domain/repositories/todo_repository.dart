import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/todo_entity.dart';

abstract class TodoRepository {
  Future<Either<Failure, List<TodoEntity>>> getTodos();
  Future<Either<Failure, List<TodoEntity>>> getCachedTodosOnly();
  Future<Either<Failure, TodoEntity>> addTodo(String title, int id);
  Future<Either<Failure, TodoEntity>> updateTodoTitle(int id, String title);
  Future<Either<Failure, TodoEntity>> updateTodoCompleted(
    int id,
    bool completed,
  );
  Future<Either<Failure, bool>> deleteTodo(int id);
  Future<Either<Failure, Set<int>>> syncPendingChanges();
}
