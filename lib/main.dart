import 'package:blicq/features/auth/presentation/bloc/setup_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blicq/init_dependencies.dart';
import 'package:blicq/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blicq/features/auth/presentation/bloc/beacon_bloc.dart';
import 'package:blicq/features/auth/presentation/widgets/auth_gate.dart';
import 'package:blicq/core/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start with a basic loading screen to avoid black screen while dependencies load
  runApp(const InitializationScreen());
  
  try {
    await initDependencies();
    
    // Once dependencies are loaded, run the main app
    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => serviceLocator<AuthBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<BeaconBloc>(),
          ),
          BlocProvider(
            create: (_) => serviceLocator<SetupBloc>(),
          ),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    debugPrint("Initialization Error: $e");
    // Show error screen if initialization fails
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text("Failed to initialize app: $e"),
        ),
      ),
    ));
  }
}

class InitializationScreen extends StatelessWidget {
  const InitializationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
              ),
              const SizedBox(height: 20),
              Text(
                "Initializing...",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proximity Aware',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}
