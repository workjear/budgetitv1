import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../repositories/auth.dart';

class RequestResetParams {
  final String email;

  RequestResetParams({
    required this.email,
  });
}

class RequestResetUseCase extends UseCase<Either<Failure, void>, RequestResetParams> {
  @override
  Future<Either<Failure, void>> call({RequestResetParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<AuthRepository>().requestReset(params.email);
  }
}