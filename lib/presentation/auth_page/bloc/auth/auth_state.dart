import '../../../../domain/auth/entities/user.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;

  AuthAuthenticated({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });
}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

class AuthEmailVerificationPending extends AuthState {
  final String email;
  AuthEmailVerificationPending({required this.email});
}
