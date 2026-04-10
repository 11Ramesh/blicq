import 'package:dartz/dartz.dart';
import 'package:blicq/core/error/failures.dart';
import 'package:blicq/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blicq/features/auth/domain/entities/user.dart';
import 'package:blicq/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Stream<UserEntity?> get currentUser => _remoteDataSource.currentUser;

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final user = await _remoteDataSource.signInWithGoogle();
      return Right(user);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    try {
      final user = await _remoteDataSource.signInWithApple();
      return Right(user);
    } on AuthFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
  }
  
}
