import 'package:budgeit/data/auth/models/auth_response.dart';
import 'package:budgeit/data/auth/models/signin_req_params.dart';
import 'package:budgeit/data/auth/models/signup_req_params.dart';
import 'package:budgeit/domain/auth/entities/user.dart';
import 'package:dartz/dartz.dart';

import '../../../common/helper/message/Failure.dart';

abstract class AuthRepository{
  Future<Either<Failure, AuthResponse>> signIn(SignInReqParams params);
  Future<Either<Failure, void>> signUp(SignUpReqParams params);
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken);
  Future<Either<Failure, void>> updateUser(int userId, String fullname, String gender, DateTime birthdate, String accessToken);
  Future<Either<Failure, void>> signOut(String accessToken, String refreshToken);
  Future<Either<Failure, String>> getProtectedData(String accessToken);
  Future<Either<Failure, void>> requestReset(String email);
  Future<Either<Failure, void>> verifyResetCode(String email, String code);
  Future<Either<Failure, void>> resetPassword(String email, String code, String newPassword);
  Future<Either<Failure, void>> requestConfirmation(String email);
  Future<Either<Failure, AuthResponse>> confirmEmail(String email, String code);
  UserEntity mapToEntity(String token);
}