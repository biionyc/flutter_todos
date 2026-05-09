import '../../domain/entities/todo_entity.dart';

class TodoModel extends TodoEntity {
  final bool isSynced;

  TodoModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.completed,
    this.isSynced = true,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: (json['id'] ?? 0) as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
    );
  }

  factory TodoModel.fromMap(Map<String, dynamic> map) {
    return TodoModel(
      id: map['id'] as int,
      userId: map['userId'] as int,
      title: map['title'] as String,
      completed: (map['completed'] as int) == 1,
      isSynced: (map['is_synced'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'completed': completed ? 1 : 0,
      'is_deleted': 0,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  TodoModel copyWith({
    int? id,
    int? userId,
    String? title,
    bool? completed,
    bool? isSynced,
  }) {
    return TodoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
