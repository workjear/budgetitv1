import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../../../common/helper/message/Failure.dart';
import '../repositories/ai_repository.dart';

class AiParams{
  final int userId;
  final String accessToken;

  AiParams({required this.userId, required this.accessToken});
}

class AnalyzeMoneyFlowUseCase extends UseCase<Either<Failure, String>, AiParams> {
  @override
  Future<Either<Failure, String>> call({AiParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<AiRepository>().analyzeMoneyFlow(params.userId, params.accessToken);
  }
}