import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/todo_model.dart';
import 'todo_remote_datasource.dart';

class TodoRemoteDataSourceImpl implements TodoRemoteDataSource {
  final ApiClient _apiClient;

  TodoRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<List<TodoModel>> getTodos() async {
    final response = await _apiClient.get('${ApiConstants.todos}?_limit=100');
    return (response as List)
        .map((item) => TodoModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<TodoModel> addTodo(String title) async {
    final response = await _apiClient.post(
      ApiConstants.todos,
      body: {
        'title': title,
        'completed': false,
        'userId': ApiConstants.defaultUserId,
      },
    );
    return TodoModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<TodoModel> updateTodo(int id, String title, bool completed) async {
    final response = await _apiClient.patch(
      '${ApiConstants.todos}/$id',
      body: {
        'title': title,
        'completed': completed,
        'userId': ApiConstants.defaultUserId,
      },
    );
    return TodoModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTodo(int id) async {
    await _apiClient.delete('${ApiConstants.todos}/$id');
  }
}
