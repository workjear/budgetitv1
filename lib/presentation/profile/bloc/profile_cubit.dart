import 'package:budgeit/service_locator.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/bloc/session/session_cubit.dart';
import '../../../domain/auth/usecases/udpate_user.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UpdateUserUseCase _updateUserUseCase;
  final SessionCubit _sessionCubit;

  ProfileCubit()
      : _updateUserUseCase = sl<UpdateUserUseCase>(),
        _sessionCubit = sl<SessionCubit>(),
        super(ProfileInitial());

  void loadUserProfile({
    required int userId,
    required String fullName,
    required String gender,
    required String birthdate,
    required String accessToken,
  }) {
    // Store the access token when loading profile
    emit(ProfileLoaded(
      userId: userId,
      fullName: fullName,
      gender: gender,
      birthdate: birthdate,
      accessToken: accessToken,
    ));
  }

  Future<void> updateProfile({
    required int userId,
    required String fullName,
    required String gender,
    required String birthdate,
    required String accessToken,
  }) async {
    try {
      emit(ProfileLoading());

      final result = await _updateUserUseCase.call(
        params: UpdateUserParams(
          userId: userId,
          fullname: fullName,
          gender: gender,
          birthdate: birthdate,
          accessToken: accessToken,
        ),
      );

      result.fold(
            (failure) => emit(ProfileError(failure.message)),
            (_) {
          // Emit success state
          emit(ProfileSuccess(
            userId: userId,
            fullName: fullName,
            gender: gender,
            birthdate: birthdate,
            accessToken: accessToken,
          ));
          // Update SessionCubit with new user data
          _sessionCubit.updateUserData(
            fullName: fullName,
            gender: gender,
            birthdate: birthdate,
          );
        },
      );
    } catch (e) {
      emit(ProfileError('Failed to update profile: $e'));
    }
  }

  Future<void> updatePassword({
    required int userId,
    required String newPassword,
    required String accessToken,
  }) async {
    try {
      emit(ProfileLoading());

      // Assuming UpdateUserUseCase can handle password updates
      // You might need to create a separate use case for password updates
      final result = await _updateUserUseCase.call(
        params: UpdateUserParams(
          userId: userId,
          password: newPassword, // Add password to UpdateUserParams
          accessToken: accessToken,
        ),
      );

      result.fold(
            (failure) => emit(ProfileError(failure.message)),
            (_) => emit(ProfileSuccess(
          userId: userId,
          fullName: state is ProfileLoaded ? (state as ProfileLoaded).fullName : '',
          gender: state is ProfileLoaded ? (state as ProfileLoaded).gender : '',
          birthdate: state is ProfileLoaded ? (state as ProfileLoaded).birthdate : '',
          accessToken: accessToken,
        )),
      );
    } catch (e) {
      emit(ProfileError('Failed to update password: $e'));
    }
  }
}
