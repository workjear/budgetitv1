import 'package:budgeit/domain/auth/entities/user.dart';
import 'package:equatable/equatable.dart';

abstract class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

class SessionInitial extends SessionState {}

class SessionLoading extends SessionState {}

class SessionAuthenticated extends SessionState {
  final String accessToken;
  final String refreshToken;
  final UserEntity user;

  const SessionAuthenticated({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}

class SessionExpired extends SessionState {
  final String message;

  const SessionExpired(this.message);

  @override
  List<Object?> get props => [message];
}