import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:blicq/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blicq/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blicq/features/auth/domain/repositories/auth_repository.dart';
import 'package:blicq/features/auth/domain/usecases/get_current_user.dart';
import 'package:blicq/features/auth/domain/usecases/user_sign_in_with_apple.dart';
import 'package:blicq/features/auth/domain/usecases/user_sign_in_with_email.dart';
import 'package:blicq/features/auth/domain/usecases/user_sign_in_with_google.dart';
import 'package:blicq/features/auth/domain/usecases/user_sign_out.dart';
import 'package:blicq/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blicq/core/common/beacon/ibeacon_service.dart';
import 'package:blicq/core/common/beacon/flutter_ibeacon_service.dart';
import 'package:blicq/core/common/notifications/notification_service.dart';
import 'package:blicq/features/auth/presentation/bloc/beacon_bloc.dart';
import 'package:blicq/features/auth/presentation/bloc/setup_bloc.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  _initBeacon();
  _initSetup();
  
  // External
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase Initialization Error: $e");
  }

  try {
    final sharedPreferences = await SharedPreferences.getInstance();
    serviceLocator.registerLazySingleton(() => sharedPreferences);
  } catch (e) {
    debugPrint("SharedPreferences Error: $e");
  }

  try {
    // Current google_sign_in 7.x+ requires explicit initialization
    await GoogleSignIn.instance.initialize();
  } catch (e) {
    debugPrint("Google Sign-In Initialization Error: $e");
  }

  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton(() => GoogleSignIn.instance);

  // iBeacon Service
  try {
    final ibeaconService = FlutterIBeaconService();
    await ibeaconService.initialize();
    serviceLocator.registerLazySingleton<IBeaconService>(() => ibeaconService);
  } catch (e) {
    debugPrint("iBeacon Service Error: $e");
    // Fallback if needed
  }

  // Notification Service
  try {
    final notificationService = NotificationService();
    await notificationService.initialize();
    serviceLocator.registerLazySingleton(() => notificationService);
  } catch (e) {
    debugPrint("Notification Service Error: $e");
  }
}

void _initAuth() {
  // Datasource
  serviceLocator.registerFactory<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      serviceLocator(),
      serviceLocator(),
    ),
  );

  // Repository
  serviceLocator.registerFactory<AuthRepository>(
    () => AuthRepositoryImpl(
      serviceLocator(),
    ),
  );

  // Usecases
  serviceLocator.registerFactory(() => UserSignInWithGoogle(serviceLocator()));
  serviceLocator.registerFactory(() => UserSignInWithApple(serviceLocator()));
  serviceLocator.registerFactory(() => UserSignInWithEmail(serviceLocator()));
  serviceLocator.registerFactory(() => UserSignOut(serviceLocator()));
  serviceLocator.registerFactory(() => GetCurrentUser(serviceLocator()));

  // Bloc
  serviceLocator.registerLazySingleton(
    () => AuthBloc(
      userSignInWithGoogle: serviceLocator(),
      userSignInWithApple: serviceLocator(),
      userSignInWithEmail: serviceLocator(),
      userSignOut: serviceLocator(),
      getCurrentUser: serviceLocator(),
    ),
  );
}

void _initSetup() {
  serviceLocator.registerLazySingleton(
    () => SetupBloc(
      beaconService: serviceLocator(),
      sharedPreferences: serviceLocator(),
    ),
  );
}

void _initBeacon() {
  serviceLocator.registerLazySingleton(
    () => BeaconBloc(serviceLocator()),
  );
}
