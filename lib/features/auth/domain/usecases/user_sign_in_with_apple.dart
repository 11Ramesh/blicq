import 'package:dartz/dartz.dart';
import 'package:blicq/core/error/failures.dart';
import 'package:blicq/core/usecase/usecase.dart';
import 'package:blicq/features/auth/domain/entities/user.dart';
import 'package:blicq/features/auth/domain/repositories/auth_repository.dart';

class UserSignInWithApple implements UseCase<UserEntity, NoParams> {
  final AuthRepository _repository;

  UserSignInWithApple(this._repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await _repository.signInWithApple();
  }
}
