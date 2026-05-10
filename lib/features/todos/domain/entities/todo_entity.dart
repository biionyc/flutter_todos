class TodoEntity {
  final int id;
  final int userId;
  final String title;
  final bool completed;
  final bool isSynced;

  const TodoEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
    this.isSynced = true,
  });

  TodoEntity copyWith({
    int? id,
    int? userId,
    String? title,
    bool? completed,
    bool? isSynced,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
