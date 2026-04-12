import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initAuth();
  
  // External
  final firebaseApp = await Firebase.initializeApp();
  await GoogleSignIn.instance.initialize();
  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton(() => GoogleSignIn.instance);

  // iBeacon Service
  final ibeaconService = FlutterIBeaconService();
  await ibeaconService.initialize();
  serviceLocator.registerLazySingleton<IBeaconService>(() => ibeaconService);
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
