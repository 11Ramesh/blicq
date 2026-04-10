import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blicq/features/auth/presentation/bloc/auth_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proximity Aware'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(AuthBackRequested());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   CircleAvatar(
                    radius: 40,
                    backgroundImage: state.user.photoUrl != null 
                        ? NetworkImage(state.user.photoUrl!) 
                        : null,
                    child: state.user.photoUrl == null 
                        ? const Icon(Icons.person, size: 40) 
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome, ${state.user.name}!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(state.user.email),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
