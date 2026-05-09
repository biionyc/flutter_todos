import '../models/todo_model.dart';

abstract class TodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<TodoModel> addTodo(String title);
  Future<TodoModel> updateTodo(int id, String title, bool completed);
  Future<void> deleteTodo(int id);
}
