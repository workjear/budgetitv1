import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/data/auth/models/auth_response.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../repositories/auth.dart';

class ConfirmEmailParams {
  final String email;
  final String code;

  ConfirmEmailParams({
    required this.email,
    required this.code,
  });
}

class ConfirmEmailUseCase extends UseCase<Either<Failure, AuthResponse>, ConfirmEmailParams> {
  @override
  Future<Either<Failure, AuthResponse>> call({ConfirmEmailParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<AuthRepository>().confirmEmail(params.email, params.code);
  }
}