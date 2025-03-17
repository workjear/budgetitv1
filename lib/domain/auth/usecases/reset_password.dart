import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../repositories/auth.dart';

class ResetPasswordParams {
  final String email;
  final String code;
  final String newPassword;

  ResetPasswordParams({
    required this.email,
    required this.code,
    required this.newPassword,
  });
}

class ResetPasswordUseCase extends UseCase<Either<Failure, void>, ResetPasswordParams> {
  @override
  Future<Either<Failure, void>> call({ResetPasswordParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<AuthRepository>().resetPassword(params.email, params.code, params.newPassword);
  }
}