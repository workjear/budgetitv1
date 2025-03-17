import 'package:budgeit/data/auth/models/auth_response.dart';
import 'package:budgeit/data/auth/models/signin_req_params.dart';
import 'package:budgeit/data/auth/models/signup_req_params.dart';
import 'package:budgeit/data/auth/sources/auth_api_services.dart';
import 'package:budgeit/domain/auth/entities/user.dart';
import 'package:budgeit/domain/auth/repositories/auth.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../../../common/helper/message/Failure.dart';
import '../models/user.dart';

class AuthRepositoryImpl extends AuthRepository{
  @override
  Future<Either<Failure, AuthResponse>> signIn(SignInReqParams params) async{
    // TODO:implement signIn
    return await sl<AuthApiService>().signIn(params);
  }

  @override
  Future<Either<Failure, void>> signUp(SignUpReqParams params) async{
    // TODO: implement signUp
    return await sl<AuthApiService>().signUp(params);
  }

  @override
  Future<Either<Failure, String>> getProtectedData(String accessToken) async{
    // TODO: implement getProtectedData
    return await sl<AuthApiService>().getProtectedData(accessToken);
  }

  @override
  UserEntity mapToEntity(String accessToken) {
    try {
      final userModel = UserModel.fromToken(accessToken);
      return UserEntity(
        id: userModel.id,
        fullName: userModel.fullName,
        email: userModel.email,
        gender: userModel.gender,
        enrolledProgram: userModel.enrolledProgram,
        birthdate: userModel.birthdate,
      );
    } catch (e) {
      throw Exception('Failed to map token to entity: $e');
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken(String refreshToken) async{
    // TODO: implement refreshToken
    return await sl<AuthApiService>().refreshToken(refreshToken);
  }

  @override
  Future<Either<Failure, void>> signOut(String accessToken, String refreshToken) async{
    // TODO: implement signOut
    return await sl<AuthApiService>().signOut(accessToken, refreshToken);
  }

  @override
  Future<Either<Failure, AuthResponse>> confirmEmail(String email, String code) async{
    // TODO: implement confirmEmail
    return await sl<AuthApiService>().confirmEmail(email, code);
  }

  @override
  Future<Either<Failure, void>> requestConfirmation(String email) async {
    // TODO: implement requestConfirmation
    return await sl<AuthApiService>().requestConfirmation(email);
  }

  @override
  Future<Either<Failure, void>> requestReset(String email) async {
    // TODO: implement requestReset
    return await sl<AuthApiService>().requestReset(email);
  }

  @override
  Future<Either<Failure, void>> resetPassword(String email, String code, String newPassword) async {
    // TODO: implement resetPassword
    return await sl<AuthApiService>().resetPassword(email, code, newPassword);
  }

  @override
  Future<Either<Failure, void>> verifyResetCode(String email, String code) async {
    // TODO: implement verifyResetCode
    return await sl<AuthApiService>().verifyResetCode(email, code);
  }

  @override
  Future<Either<Failure, void>> updateUser(int userId, String fullname, String gender, DateTime birthdate, String accessToken) async {
    // TODO: implement updateUser
    return await sl<AuthApiService>().updateUser(userId, fullname, gender, birthdate, accessToken);
  }

}