import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../repositories/auth.dart';

class UpdateUserParams {
  final int userId;
  final String? fullname;
  final String? birthdate;
  final String? gender;
  final String? accessToken;
  final String? password;

  UpdateUserParams({
    required this.userId,
    this.fullname,
    this.birthdate,
    this.gender,
    this.accessToken,
    this.password
  });
}

class UpdateUserUseCase extends UseCase<Either<Failure, void>, UpdateUserParams> {
  @override
  Future<Either<Failure, void>> call({UpdateUserParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<AuthRepository>().updateUser(params.userId, params.fullname!, params.gender!, DateTime.parse(params.birthdate!), params.accessToken!);
  }
}