import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';
import '../../../common/helper/message/Failure.dart';
import '../../../domain/reports/repositories/ai_repository.dart';
import '../sources/ai_api_service.dart';

class AiRepositoryImpl extends AiRepository {
  @override
  Future<Either<Failure, String>> testAi(String input, String accessToken) async {
    return await sl<AiApiService>().testAi(input, accessToken);
  }

  @override
  Future<Either<Failure, String>> analyzeMoneyFlow(int userId, String accessToken) async {
    return await sl<AiApiService>().analyzeMoneyFlow(userId, accessToken);
  }

  @override
  Future<Either<Failure, String>> analyzeMoneyFlowByDate(int userId, DateTime selectedDate, String accessToken) async {
    return await sl<AiApiService>().analyzeMoneyFlowByDate(userId, selectedDate, accessToken);
  }

  @override
  Future<Either<Failure, String>> analyzeMoneyFlowByDateRange(int userId, DateTime startDate, DateTime endDate, String accessToken) async {
    return await sl<AiApiService>().analyzeMoneyFlowByDateRange(userId, startDate, endDate, accessToken);
  }
}