import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/data/auth/models/auth_response.dart';
import 'package:budgeit/data/auth/models/signin_req_params.dart';
import 'package:budgeit/domain/auth/repositories/auth.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

class SignInUseCase extends UseCase<Either<Failure, AuthResponse>, SignInReqParams> {
  @override
  Future<Either<Failure, AuthResponse>> call({SignInReqParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params')); // Add return here
    }
    return await sl<AuthRepository>().signIn(params);
  }
}