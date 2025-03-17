import 'package:dartz/dartz.dart';
import '../../../common/helper/message/Failure.dart';

abstract class AiRepository {
  Future<Either<Failure, String>> testAi(String input, String accessToken);
  Future<Either<Failure, String>> analyzeMoneyFlow(int userId, String accessToken);
  Future<Either<Failure, String>> analyzeMoneyFlowByDate(int userId, DateTime selectedDate, String accessToken);
  Future<Either<Failure, String>> analyzeMoneyFlowByDateRange(int userId, DateTime startDate, DateTime endDate, String accessToken);
}