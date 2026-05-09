import 'package:fpdart/fpdart.dart';
import '../../../../core/constants/auth_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<Either<Failure, Unit>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email.trim() == AuthConstants.email &&
        password == AuthConstants.password) {
      return right(unit);
    }
    return left(const AuthFailure(message: 'Invalid email or password'));
  }
}
