// domain/usecases/refresh_token.dart
import 'package:budgeit/domain/auth/repositories/auth.dart';
import 'package:dartz/dartz.dart';

import '../../../common/helper/message/Failure.dart';
import '../../../core/usecase/usecase.dart';
import '../../../data/auth/models/auth_response.dart';
import '../../../service_locator.dart';

class RefreshTokenParams {
  final String refreshToken;

  RefreshTokenParams({required this.refreshToken});
}

class RefreshTokenUseCase implements UseCase<Either<Failure, AuthResponse>, RefreshTokenParams> {

  @override
  Future<Either<Failure, AuthResponse>> call({RefreshTokenParams? params}) async {
    if (params == null) {
      return Left(Failure('Refresh token parameter is required'));
    }
    return await sl<AuthRepository>().refreshToken(params.refreshToken);
  }
}