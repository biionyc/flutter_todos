import '../../features/todos/domain/entities/todo_entity.dart';

abstract class Failure {
  final String message;

  const Failure({required this.message});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class ServerFailureWithCache extends Failure {
  final List<TodoEntity> cachedData;
  const ServerFailureWithCache({
    required super.message,
    required this.cachedData,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}
