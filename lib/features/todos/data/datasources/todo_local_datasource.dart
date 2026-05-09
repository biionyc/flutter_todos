import '../models/todo_model.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getCachedTodos();
  Future<void> cacheTodos(List<TodoModel> todos);
  Future<void> insertTodo(TodoModel todo);
  Future<void> updateTodo(TodoModel todo);
  Future<void> softDeleteTodo(int id);
  Future<void> restoreTodo(int id);
  Future<void> markSynced(int id);
  Future<List<TodoModel>> getPendingSync();
}
