import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blicq/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blicq/features/auth/presentation/pages/setup_page.dart';
import 'package:blicq/features/auth/presentation/pages/login_page.dart';
import 'package:blicq/features/auth/presentation/pages/home_page.dart';
import 'package:blicq/core/constants/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blicq/init_dependencies.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final isSetupCompleted = serviceLocator<SharedPreferences>().getBool('setup_completed') ?? false;
            return isSetupCompleted ? const HomePage() : const SetupPage();
          } else if (state is AuthUnauthenticated || state is AuthInitial || state is AuthError) {
            return const LoginPage();
          } else if (state is AuthLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return const LoginPage();
        },
      ),
    );
  }
}
