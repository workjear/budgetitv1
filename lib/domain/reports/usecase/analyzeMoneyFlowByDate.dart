import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../../../common/helper/message/Failure.dart';
import '../repositories/ai_repository.dart';

class ParamsDate{
  final int userId;
  final String accessToken;
  final DateTime selectedDate;

  ParamsDate({required this.userId, required this.accessToken, required this.selectedDate});
}
class AnalyzeMoneyFlowByDateUseCase extends UseCase<Either<Failure, String>,ParamsDate> {
  @override
  Future<Either<Failure, String>> call({ParamsDate? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<AiRepository>().analyzeMoneyFlowByDate(
      params.userId,
      params.selectedDate,
      params.accessToken
    );
  }
}