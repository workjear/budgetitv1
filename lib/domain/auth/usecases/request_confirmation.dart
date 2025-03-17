import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../repositories/auth.dart';

class RequestConfirmationParams {
  final String email;

  RequestConfirmationParams({
    required this.email,
  });
}

class RequestConfirmationUseCase extends UseCase<Either<Failure, void>, RequestConfirmationParams> {
  @override
  Future<Either<Failure, void>> call({RequestConfirmationParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<AuthRepository>().requestConfirmation(params.email);
  }
}