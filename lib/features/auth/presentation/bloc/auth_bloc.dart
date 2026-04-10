import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:blicq/core/usecase/usecase.dart';
import 'package:blicq/features/auth/domain/entities/user.dart';
import 'package:blicq/features/auth/domain/usecases/get_current_user.dart';
import 'package:blicq/features/auth/domain/usecases/user_sign_in_with_apple.dart';
import 'package:blicq/features/auth/domain/usecases/user_sign_in_with_google.dart';
import 'package:blicq/features/auth/domain/usecases/user_sign_out.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignInWithGoogle _userSignInWithGoogle;
  final UserSignInWithApple _userSignInWithApple;
  final UserSignOut _userSignOut;
  final GetCurrentUser _getCurrentUser;
  StreamSubscription<UserEntity?>? _userSubscription;

  AuthBloc({
    required UserSignInWithGoogle userSignInWithGoogle,
    required UserSignInWithApple userSignInWithApple,
    required UserSignOut userSignOut,
    required GetCurrentUser getCurrentUser,
  })  : _userSignInWithGoogle = userSignInWithGoogle,
        _userSignInWithApple = userSignInWithApple,
        _userSignOut = userSignOut,
        _getCurrentUser = getCurrentUser,
        super(AuthInitial()) {
    on<AuthGoogleSignInRequested>(_onGoogleSignIn);
    on<AuthAppleSignInRequested>(_onAppleSignIn);
    on<AuthBackRequested>(_onSignOut);
    on<AuthUserChanged>(_onUserChanged);

    _userSubscription = _getCurrentUser.execute().listen((user) {
      add(AuthUserChanged(user));
    });
  }

  Future<void> _onGoogleSignIn(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _userSignInWithGoogle(NoParams());
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onAppleSignIn(
    AuthAppleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await _userSignInWithApple(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onSignOut(
    AuthBackRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _userSignOut(NoParams());
    emit(AuthUnauthenticated());
  }

  void _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
