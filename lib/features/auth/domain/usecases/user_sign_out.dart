import 'package:dartz/dartz.dart';
import 'package:blicq/core/error/failures.dart';
import 'package:blicq/core/usecase/usecase.dart';
import 'package:blicq/features/auth/domain/repositories/auth_repository.dart';

class UserSignOut implements UseCase<void, NoParams> {
  final AuthRepository _repository;

  UserSignOut(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    await _repository.signOut();
    return const Right(null);
  }
}
