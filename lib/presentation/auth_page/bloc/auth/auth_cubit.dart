import 'package:budgeit/data/auth/models/auth_response.dart';
import 'package:budgeit/data/auth/models/signin_req_params.dart';
import 'package:budgeit/data/auth/models/signup_req_params.dart';
import 'package:budgeit/domain/auth/usecases/signin.dart';
import 'package:budgeit/domain/auth/usecases/signout.dart';
import 'package:budgeit/domain/auth/usecases/signup.dart';
import 'package:budgeit/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../../../common/bloc/session/session_cubit.dart';
import '../../../../common/bloc/session/session_state.dart';
import '../../../../data/auth/sources/auth_api_services.dart';
import '../../../../domain/auth/repositories/auth.dart';
import '../../../../domain/auth/usecases/verify_reset_codes.dart';
import '../../../calendar/bloc/calendar_cubit.dart';
import '../../../categories/bloc/educationalExpense/educationalexpense_cubit.dart';
import '../../../categories/bloc/income/income_cubit.dart';
import '../../../categories/bloc/personalExpense/myexpense_cubit.dart';
import '../../../icons/bloc/icons_cubit.dart';
import '../../../reports/bloc/reports_cubit.dart';
import 'auth_state.dart';

// Import the new use cases
import 'package:budgeit/domain/auth/usecases/confirm_email.dart';
import 'package:budgeit/domain/auth/usecases/request_confirmation.dart';
import 'package:budgeit/domain/auth/usecases/request_reset.dart';
import 'package:budgeit/domain/auth/usecases/reset_password.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase _signIn = sl<SignInUseCase>();
  final SignUpUseCase _signUp = sl<SignUpUseCase>();
  final SignOutUseCase _signOut = sl<SignOutUseCase>();
  final ConfirmEmailUseCase _confirmEmail = sl<ConfirmEmailUseCase>();
  final RequestConfirmationUseCase _requestConfirmation = sl<RequestConfirmationUseCase>();
  final RequestResetUseCase _requestReset = sl<RequestResetUseCase>();
  final ResetPasswordUseCase _resetPassword = sl<ResetPasswordUseCase>();
  final VerifyResetCodeUseCase _verifyResetCode = sl<VerifyResetCodeUseCase>();
  final storage = const FlutterSecureStorage();

  AuthCubit() : super(AuthInitial());

  void resetState() {
    emit(AuthInitial());
  }

  Future<void> _saveToken(AuthResponse response) async {
    await storage.write(key: 'accessToken', value: response.accessToken);
    await storage.write(key: 'refreshToken', value: response.refreshToken);
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    final params = SignInReqParams(email: email, password: password);
    final res = await _signIn.call(params: params);
    res.fold(
          (failure) {
        if (failure.message.contains("PendingVerification")) {
          emit(AuthEmailVerificationPending(email: email));
        } else {
          emit(AuthError(failure.message));
        }
      },
          (response) async {
        // Save tokens and ensure completion
        await _saveToken(response);
        // Wait for SessionCubit to update
        final sessionCubit = sl<SessionCubit>();
        await sessionCubit.loadTokens();
        // Check the state after loading
        if (sessionCubit.state is SessionAuthenticated) {
          emit(AuthAuthenticated(
            accessToken: response.accessToken,
            refreshToken: response.refreshToken,
            user: sl<AuthRepository>().mapToEntity(response.accessToken),
          ));
        } else {
          emit(AuthError('Failed to authenticate session after sign-in: ${sessionCubit.state}'));
        }
      },
    );
  }

  Future<void> signup({
    required String fullName,
    required String email,
    required String gender,
    required String password,
    required DateTime birthdate,
    required String enrolledProgram,
  }) async {
    emit(AuthLoading());
    final params = SignUpReqParams(
      fullName: fullName,
      emailAddress: email,
      gender: gender,
      password: password,
      birthdate: DateFormat('yyyy-MM-dd').format(birthdate),
      enrolledProgram: enrolledProgram,
    );
    final result = await _signUp.call(params: params);
    result.fold(
          (failure) => emit(AuthError(failure.message.toString())),
          (success) => emit(AuthEmailVerificationPending(email: email)),
    );
  }


  Future<void> confirmEmail(String email, String code) async {
    emit(AuthLoading());
    final params = ConfirmEmailParams(email: email, code: code);
    final result = await _confirmEmail.call(params: params);
    result.fold(
          (failure) => emit(AuthError(failure.message.toString())),
          (response) {
        _saveToken(response);
        sl<SessionCubit>().refresh(response.refreshToken);
        emit(AuthAuthenticated(
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          user: sl<AuthRepository>().mapToEntity(response.accessToken),
        ));
      },
    );
  }

  Future<void> requestConfirmation(String email) async {
    emit(AuthLoading());
    final params = RequestConfirmationParams(email: email);
    final result = await _requestConfirmation.call(params: params);
    result.fold(
          (failure) => emit(AuthError(failure.message.toString())),
          (_) => emit(AuthInitial()),
    );
  }

  Future<void> requestReset(String email) async {
    emit(AuthLoading());
    final params = RequestResetParams(email: email);
    final result = await _requestReset.call(params: params);
    result.fold(
          (failure) => emit(AuthError(failure.message.toString())),
          (_) => emit(AuthInitial()),
    );
  }

  Future<void> resetPassword(String email, String code, String newPassword) async {
    emit(AuthLoading());
    final params = ResetPasswordParams(email: email, code: code, newPassword: newPassword);
    final result = await _resetPassword.call(params: params);
    result.fold(
          (failure) => emit(AuthError(failure.message.toString())),
          (_) => emit(AuthInitial()),
    );
  }

  Future<void> verifyResetCode(String email, String code) async {
    emit(AuthLoading());
    final params = VerifyResetCodeParams(email: email, code: code);
    final result = await _verifyResetCode.call(params: params);
    result.fold(
          (failure) => emit(AuthError(failure.message.toString())),
          (_) => emit(AuthInitial()),
    );
  }

  Future<void> logout() async {
    if (state is AuthAuthenticated) {
      final currentState = state as AuthAuthenticated;
      emit(AuthLoading());
      final result = await _signOut.call(
        params: SignOutParams(
          accessToken: currentState.accessToken,
          refreshToken: currentState.refreshToken,
        ),
      );
      result.fold(
            (failure) => emit(AuthError(failure.message.toString())),
            (_) async {
          await storage.deleteAll();
          _resetAllCubits();
          emit(AuthInitial());
        },
      );
    } else {
      await storage.deleteAll();
      _resetAllCubits();
      emit(AuthInitial());
    }
  }

  Future<void> logoutAllDevices() async {
    if (state is AuthAuthenticated) {
      final currentState = state as AuthAuthenticated;
      emit(AuthLoading());
      final result = await sl<AuthApiService>().signOutAllDevices(currentState.accessToken);
      result.fold(
            (failure) => emit(AuthError(failure.message.toString())),
            (_) async {
          await storage.deleteAll();
          emit(AuthInitial());
        },
      );
    }
  }

  void _resetAllCubits() {
    final cubits = [
      sl<IconsCubit>(),
      sl<ReportsCubit>(),
      sl<AddIncomeCubit>(),
      sl<EducationalExpenseCubit>(),
      sl<PersonalExpenseCubit>(),
      sl<CategoryStreamCubit>(),
    ];

    for (var cubit in cubits) {
      cubit.close();
    }

    sl.resetLazySingleton<IconsCubit>();
    sl.resetLazySingleton<ReportsCubit>();
    sl.resetLazySingleton<AddIncomeCubit>();
    sl.resetLazySingleton<EducationalExpenseCubit>();
    sl.resetLazySingleton<PersonalExpenseCubit>();
    sl.resetLazySingleton<CategoryStreamCubit>();
  }
}