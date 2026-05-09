abstract class TodoEvent {}

class LoadTodosEvent extends TodoEvent {}

class AddTodoEvent extends TodoEvent {
  final String title;

  AddTodoEvent({required this.title});
}

class UpdateTodoTitleEvent extends TodoEvent {
  final int id;
  final String title;

  UpdateTodoTitleEvent({required this.id, required this.title});
}

class UpdateTodoCompletedEvent extends TodoEvent {
  final int id;
  final bool completed;

  UpdateTodoCompletedEvent({required this.id, required this.completed});
}

class DeleteTodoEvent extends TodoEvent {
  final int id;

  DeleteTodoEvent({required this.id});
}

class SyncTodosEvent extends TodoEvent {}

class SearchTodosEvent extends TodoEvent {
  final String query;

  SearchTodosEvent({required this.query});
}
