import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../repositories/auth.dart';

class VerifyResetCodeParams {
  final String email;
  final String code;

  VerifyResetCodeParams({
    required this.email,
    required this.code,
  });
}

class VerifyResetCodeUseCase extends UseCase<Either<Failure, void>, VerifyResetCodeParams> {
  @override
  Future<Either<Failure, void>> call({VerifyResetCodeParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<AuthRepository>().verifyResetCode(params.email, params.code);
  }
}