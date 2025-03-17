import 'dart:convert';

import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/network/dio_client.dart';
import 'package:budgeit/data/auth/models/auth_response.dart';
import 'package:budgeit/data/auth/models/signin_req_params.dart';
import 'package:budgeit/data/auth/models/signup_req_params.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';

abstract class AuthApiService {
  Future<Either<Failure, AuthResponse>> signIn(SignInReqParams params);
  Future<Either<Failure, void>> signUp(SignUpReqParams params);
  Future<Either<Failure, String>> getProtectedData(String accessToken);
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> signOut(String accessToken, String refreshToken);
  Future<Either<Failure, void>> updateUser(int userId, String fullname, String gender, DateTime birthdate, String accessToken);
  Future<Either<Failure, void>> signOutAllDevices(String accessToken);
  Future<Either<Failure, void>> requestReset(String email);
  Future<Either<Failure, void>> verifyResetCode(String email, String code);
  Future<Either<Failure, void>> resetPassword(String email, String code, String newPassword);
  Future<Either<Failure, void>> requestConfirmation(String email);
  Future<Either<Failure, AuthResponse>> confirmEmail(String email, String code);
}

class AuthApiServiceImpl extends AuthApiService {
  final client = sl<DioClient>(instanceName: 'apiUrl');

  @override
  Future<Either<Failure, AuthResponse>> signIn(SignInReqParams params) async {
    try {
      await params.setDeviceId();
      final response = await client.post(
        '/api/Users/loginuser',
        data: params.toMap(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return Right(AuthResponse.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(e.response?.data['message'] ?? 'Login Failed'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signUp(SignUpReqParams params) async {
    try {
      await params.setDeviceId();
      final response = await client.post(
        '/api/Users/registeruser',
        data: params.toMap(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return const Right(null); // Success, no data to return
    } on DioException catch (e) {
      final innerError = e.response?.data['inner'];
      final errorMessage = e.response?.data['message'] ?? 'Signup Failed';
      final detailedMessage = innerError != null ? '$errorMessage - Inner: $innerError' : errorMessage;
      print('Inner error: $innerError'); // Debugging
      return Left(Failure(detailedMessage));
    }catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUser(int userId, String fullname, String gender, DateTime birthdate, String accessToken) async {
    try {
      final payload = {
        'UserId': userId,
        'Fullname': fullname,
        'Gender': gender,
        'Birthdate': birthdate.toIso8601String(),
      };
      final response = await client.put(
        '/api/Users/updateuser',
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $accessToken'
          },
        ),
      );
      return const Right(null); // Success, no data to return
    } on DioException catch (e) {

      return Left(Failure(e.response?.data['message'] ?? 'Update Failed'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getProtectedData(String accessToken) async {
    try {
      final response = await client.get(
        '/api/Auth/protected', // Adjust this endpoint as needed
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return Right(response.data);
    } on DioException catch (e) {
      return Left(Failure(e.response?.data['message'] ?? 'Failed to get protected data'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken) async {
    try {
      final deviceId = await MobileDeviceIdentifier().getDeviceId();
      final response = await client.post(
        '/api/Users/refresh',
        data: {
          'RefreshToken': refreshToken,
          'DeviceIdentifier': deviceId,
        },
      );
      return Right(AuthResponse.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(e.response?.data['message'] ?? 'Refresh failed'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut(String accessToken, String refreshToken) async {
    try {
      final deviceId = await MobileDeviceIdentifier().getDeviceId();
      await client.post(
        '/api/Users/signout',
        data: {
          'RefreshToken': refreshToken,
          'DeviceIdentifier': deviceId,
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(e.response?.data['message'] ?? 'Signout failed'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOutAllDevices(String accessToken) async {
    try {
      await client.post(
        '/api/Users/signout-all',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(e.response?.data['message'] ?? 'Sign out all devices failed'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
  @override
  Future<Either<Failure, void>> requestReset(String email) async {
    try {
      final response = await client.post(
        '/api/Users/request-reset',
        data: {'Email': email},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(e.response?.data['message'] ?? 'Failed to request reset'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyResetCode(String email, String code) async {
    try {
      final response = await client.post(
        '/api/Users/verify-reset-code',
        data: {'Email': email, 'Code': code},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(e.response?.data['message'] ?? 'Failed to verify reset code'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email, String code, String newPassword) async {
    try {
      final response = await client.post(
        '/api/Users/reset-password',
        data: {'Email': email, 'Code': code, 'NewPassword': newPassword},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(e.response?.data['message'] ?? 'Failed to reset password'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestConfirmation(String email) async {
    try {
      final response = await client.post(
        '/api/Users/request-confirmation',
        data: {'Email': email},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return const Right(null);
    } on DioException catch (e) {
      return Left(Failure(e.response?.data['message'] ?? 'Failed to request confirmation code'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> confirmEmail(String email, String code) async {
    try {
      final response = await client.post(
        '/api/Users/confirm-email',
        data: {'Email': email, 'Code': code},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return Right(AuthResponse.fromJson(response.data));
    } on DioException catch (e) {
      return Left(Failure(e.response?.data['message'] ?? 'Failed to confirm email'));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}