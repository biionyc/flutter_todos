import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRepository {
  Future<Either<Failure, Unit>> login(String email, String password);
}
