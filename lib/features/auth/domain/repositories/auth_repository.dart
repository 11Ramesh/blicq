import 'package:dartz/dartz.dart';
import 'package:blicq/core/error/failures.dart';
import 'package:blicq/features/auth/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, UserEntity>> signInWithApple();
  Stream<UserEntity?> get currentUser;
  Future<void> signOut();
}
