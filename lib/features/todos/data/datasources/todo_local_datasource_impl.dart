import '../../../../core/database/database_helper.dart';
import '../models/todo_model.dart';
import 'todo_local_datasource.dart';

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final DatabaseHelper _databaseHelper;

  TodoLocalDataSourceImpl({required DatabaseHelper databaseHelper})
      : _databaseHelper = databaseHelper;

  @override
  Future<List<TodoModel>> getCachedTodos() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('todos', where: 'is_deleted = ?', whereArgs: [0]);
    return maps.map((map) => TodoModel.fromMap(map)).toList();
  }

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    final db = await _databaseHelper.database;
    await db.delete('todos');
    for (final todo in todos) {
      await db.insert('todos', todo.copyWith(isSynced: true).toMap());
    }
  }

  @override
  Future<void> insertTodo(TodoModel todo) async {
    final db = await _databaseHelper.database;
    await db.insert('todos', todo.toMap());
  }

  @override
  Future<void> updateTodo(TodoModel todo) async {
    final db = await _databaseHelper.database;
    await db.update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  @override
  Future<void> softDeleteTodo(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'todos',
      {'is_deleted': 1, 'is_synced': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> restoreTodo(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'todos',
      {'is_deleted': 0, 'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> markSynced(int id) async {
    final db = await _databaseHelper.database;
    await db.update(
      'todos',
      {'is_synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<TodoModel>> getPendingSync() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('todos', where: 'is_synced = ?', whereArgs: [0]);
    return maps.map((map) => TodoModel.fromMap(map)).toList();
  }
}
