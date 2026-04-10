import 'package:blicq/features/auth/domain/entities/user.dart';
import 'package:blicq/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository _repository;

  GetCurrentUser(this._repository);

  Stream<UserEntity?> execute() {
    return _repository.currentUser;
  }
}
