import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<UserModel> signUp(String email, String password, String name);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> resetPassword(String email);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseDatabase database;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.database,
  });

  @override
  Future<UserModel> signIn(String email, String password) async {
    try {
      print('AuthRemoteDataSource: Attempting to sign in with email: $email');
      
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('AuthRemoteDataSource: Firebase auth successful, user: ${credential.user?.uid}');

      if (credential.user == null) {
        throw Exception('Sign in failed - no user returned');
      }

      // Get user data from database
      print('AuthRemoteDataSource: Fetching user data from database');
      
      UserModel user;
      try {
        final snapshot = await database
            .ref()
            .child('users')
            .child(credential.user!.uid)
            .get();

        if (snapshot.exists) {
          print('AuthRemoteDataSource: User data found in database');
          final data = Map<String, dynamic>.from(snapshot.value as Map);
          user = UserModel.fromJson(data);
          print('AuthRemoteDataSource: User model created: ${user.email}');
        } else {
          print('AuthRemoteDataSource: User data not found in database, creating new user data');
          // Create user data if it doesn't exist
          user = UserModel(
            id: credential.user!.uid,
            email: email,
            name: credential.user!.displayName ?? 'User',
            createdAt: DateTime.now(),
          );
          
          try {
            // Try to save user data to database
            await database.ref().child('users').child(user.id).set(user.toJson());
            print('AuthRemoteDataSource: User data created successfully');
          } catch (e) {
            print('AuthRemoteDataSource: Failed to save user data, but continuing: $e');
            // Continue anyway - we have the user data locally
          }
        }
      } catch (dbError) {
        print('AuthRemoteDataSource: Database access failed (${dbError.toString()}), creating user locally');
        // If database access fails (permission denied), create user data locally
        user = UserModel(
          id: credential.user!.uid,
          email: email,
          name: credential.user!.displayName ?? 'User',
          createdAt: DateTime.now(),
        );
      }
      
      return user;
    } catch (e) {
      print('AuthRemoteDataSource: Error during sign in: $e');
      String errorMessage = _getAuthErrorMessage(e.toString());
      throw Exception(errorMessage);
    }
  }

  @override
  Future<UserModel> signUp(String email, String password, String name) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Sign up failed');
      }

      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        name: name,
        createdAt: DateTime.now(),
      );

      // Save user data to database
      await database.ref().child('users').child(user.id).set(user.toJson());

      return user;
    } catch (e) {
      String errorMessage = _getAuthErrorMessage(e.toString());
      throw Exception(errorMessage);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;

      // Get user data from database
      final snapshot = await database
          .ref()
          .child('users')
          .child(user.uid)
          .get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return UserModel.fromJson(data);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      String errorMessage = _getAuthErrorMessage(e.toString());
      throw Exception(errorMessage);
    }
  }

  String _getAuthErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email address.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled.';
    } else if (error.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later.';
    } else if (error.contains('email-already-in-use')) {
      return 'An account with this email already exists.';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password.';
    } else if (error.contains('invalid-credential')) {
      return 'Invalid email or password. Please check your credentials.';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection.';
    } else if (error.contains('permission-denied')) {
      return 'Access denied. Please try again.';
    } else {
      return 'Authentication failed. Please try again.';
    }
  }
}
