// domain/usecases/signout.dart
import 'package:budgeit/domain/auth/repositories/auth.dart';
import 'package:dartz/dartz.dart';

import '../../../common/helper/message/Failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../../service_locator.dart';

class SignOutParams {
  final String accessToken;
  final String refreshToken;

  SignOutParams({required this.accessToken, required this.refreshToken});
}

class SignOutUseCase implements UseCase<Either<Failure, void>, SignOutParams> {

  @override
  Future<Either<Failure, void>> call({SignOutParams? params}) async {
    if (params == null) {
      return Left(Failure('Signout parameters are required'));
    }
    return await sl<AuthRepository>().signOut(params.accessToken, params.refreshToken);
  }
}