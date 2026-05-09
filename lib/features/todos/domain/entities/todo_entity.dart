class TodoEntity {
  final int id;
  final int userId;
  final String title;
  final bool completed;

  const TodoEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });
}
