part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthGoogleSignInRequested extends AuthEvent {}

final class AuthAppleSignInRequested extends AuthEvent {}

final class AuthBackRequested extends AuthEvent {}

final class AuthUserChanged extends AuthEvent {
  final UserEntity? user;
  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}
