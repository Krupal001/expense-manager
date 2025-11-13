import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/usecases/auth/get_current_user.dart';
import '../../../domain/usecases/auth/reset_password.dart';
import '../../../domain/usecases/auth/sign_in.dart';
import '../../../domain/usecases/auth/sign_out.dart';
import '../../../domain/usecases/auth/sign_up.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignIn signInUseCase;
  final SignUp signUpUseCase;
  final SignOut signOutUseCase;
  final GetCurrentUser getCurrentUserUseCase;
  final ResetPassword resetPasswordUseCase;

  AuthCubit({
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
    required this.resetPasswordUseCase,
  }) : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final result = await getCurrentUserUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    print('AuthCubit: Starting sign in process for email: $email');
    emit(AuthLoading());
    
    try {
      final result = await signInUseCase(
        SignInParams(email: email, password: password),
      );
      
      result.fold(
        (failure) {
          print('AuthCubit: Sign in failed with error: ${failure.message}');
          emit(AuthError(failure.message));
        },
        (user) {
          print('AuthCubit: Sign in successful for user: ${user.email}');
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e) {
      print('AuthCubit: Unexpected error during sign in: $e');
      emit(AuthError('An unexpected error occurred: $e'));
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    emit(AuthLoading());
    final result = await signUpUseCase(
      SignUpParams(email: email, password: password, name: name),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    final result = await signOutUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> resetPassword(String email) async {
    emit(AuthLoading());
    final result = await resetPasswordUseCase(ResetPasswordParams(email: email));
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthOperationSuccess('Password reset email sent! Check your inbox.')),
    );
  }
}
