import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';

import '../../../common/helper/message/Failure.dart';
import '../repositories/ai_repository.dart';

class ParamsDateRange {
  final int userId;
  final String accessToken;
  final DateTime startDate;
  final DateTime endDate;

  ParamsDateRange({
    required this.userId,
    required this.accessToken,
    required this.startDate,
    required this.endDate,
  });
}

class AnalyzeMoneyFlowByDateRangeUseCase
    extends UseCase<Either<Failure, String>, ParamsDateRange> {
  @override
  Future<Either<Failure, String>> call({ParamsDateRange? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<AiRepository>().analyzeMoneyFlowByDateRange(
      params.userId,
      params.startDate,
      params.endDate,
      params.accessToken,
    );
  }
}
