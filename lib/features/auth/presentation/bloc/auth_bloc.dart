import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _repository;

  AuthBloc({required AuthRepository repository})
    : _repository = repository,
      super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoginInProgress());
    final result = await _repository.login(event.email, event.password);
    result.fold(
      (failure) => emit(AuthLoginFailure(message: failure.message)),
      (_) => emit(AuthLoginSuccess()),
    );
  }
}
