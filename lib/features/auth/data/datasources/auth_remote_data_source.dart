import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:blicq/features/auth/data/models/user_model.dart';
import 'package:blicq/core/error/failures.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithApple();
  Future<UserModel> signInWithEmail(String email, String password);
  Stream<UserModel?> get currentUser;
  Future<void> signOut();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl(this._firebaseAuth, this._googleSignIn);

  @override
  Stream<UserModel?> get currentUser {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        photoUrl: user.photoURL,
      );
    });
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      print("googleUser+++++++++++++++++++++++++++++++++++++++++++: $googleUser");
      if (googleUser == null) {
        throw AuthFailure('Google sign in cancelled');
      }

      

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final authorization = await googleUser.authorizationClient.authorizeScopes(['email', 'profile']);
      
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw AuthFailure('User is null after Google sign in');
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        photoUrl: user.photoURL,
      );
    } catch (e) {
      print("Google Sign In Error: $e");
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithApple() async {
    try {
      final AppleAuthProvider appleProvider = AppleAuthProvider();
      
      // Using signInWithProvider ensures it works on both iOS (native) and Android (web-based)
      final UserCredential userCredential = await _firebaseAuth.signInWithProvider(appleProvider);
      final User? user = userCredential.user;

      if (user == null) {
        throw AuthFailure('User is null after Apple sign in');
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        photoUrl: user.photoURL,
      );
    } catch (e) {
      print("Apple Sign In Error: $e");
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;

      if (user == null) {
        throw AuthFailure('User is null after email sign in');
      }

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        name: user.displayName ?? '',
        photoUrl: user.photoURL,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        // Try to create user if it's for "test purpose" as the user mentioned
        try {
          final UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          final User? user = userCredential.user;
          if (user != null) {
            return UserModel(
              id: user.uid,
              email: user.email ?? '',
              name: user.displayName ?? '',
              photoUrl: user.photoURL,
            );
          }
        } catch (signUpError) {
          throw AuthFailure(signUpError.toString());
        }
      }
      throw AuthFailure(e.message ?? 'Authentication failed');
    } catch (e) {
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
