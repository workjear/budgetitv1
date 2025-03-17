
part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final int userId;
  final String fullName;
  final String gender;
  final String birthdate;
  final String accessToken;

  const ProfileLoaded({
    required this.userId,
    required this.fullName,
    required this.gender,
    required this.birthdate,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [userId, fullName, gender, birthdate, accessToken];
}

class ProfileSuccess extends ProfileState {
  final int userId;
  final String fullName;
  final String gender;
  final String birthdate;
  final String accessToken;

  const ProfileSuccess({
    required this.userId,
    required this.fullName,
    required this.gender,
    required this.birthdate,
    required this.accessToken,
  });

  @override
  List<Object?> get props => [userId, fullName, gender, birthdate, accessToken];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}