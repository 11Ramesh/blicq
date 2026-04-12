import 'package:dartz/dartz.dart';
import 'package:blicq/core/error/failures.dart';
import 'package:blicq/core/usecase/usecase.dart';
import 'package:blicq/features/auth/domain/entities/user.dart';
import 'package:blicq/features/auth/domain/repositories/auth_repository.dart';

class UserSignInWithEmail implements UseCase<UserEntity, SignInWithEmailParams> {
  final AuthRepository _repository;

  UserSignInWithEmail(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(SignInWithEmailParams params) async {
    return await _repository.signInWithEmail(params.email, params.password);
  }
}

class SignInWithEmailParams {
  final String email;
  final String password;

  SignInWithEmailParams({required this.email, required this.password});
}
