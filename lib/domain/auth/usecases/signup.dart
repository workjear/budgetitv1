import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/data/auth/models/auth_response.dart';
import 'package:budgeit/data/auth/models/signup_req_params.dart';
import 'package:budgeit/domain/auth/repositories/auth.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

class SignUpUseCase extends UseCase<Either<Failure, void>, SignUpReqParams>{
  @override
  Future<Either<Failure, void>> call({SignUpReqParams? params}) async {
    // TODO: implement call
    if(params == null){
      Left(Failure('Invalid Params'));
    }
    return await sl<AuthRepository>().signUp(params!);
  }

}