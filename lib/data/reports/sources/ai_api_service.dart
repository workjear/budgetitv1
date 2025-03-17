import 'package:budgeit/core/network/dio_client.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../common/helper/message/Failure.dart';

abstract class AiApiService {
  Future<Either<Failure, String>> testAi(String input, String accessToken);
  Future<Either<Failure, String>> analyzeMoneyFlow(int userId, String accessToken);
  Future<Either<Failure, String>> analyzeMoneyFlowByDate(int userId, DateTime selectedDate, String accessToken);
  Future<Either<Failure, String>> analyzeMoneyFlowByDateRange(int userId, DateTime startDate, DateTime endDate, String accessToken);
}

class AiApiServiceImpl extends AiApiService {
  final _dioClient = sl<DioClient>(instanceName: 'apiUrl');

  @override
  Future<Either<Failure, String>> testAi(String input, String accessToken) async {
    try {
      final response = await _dioClient.post(
        '/api/AI/TestAi',
        data: {'input': input},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return Right(response.data.toString());
    } on DioException catch (e) {
      return Left(Failure(
        e.response?.data['message'] ?? 'Failed to process AI test',
      ));
    }
  }

  @override
  Future<Either<Failure, String>> analyzeMoneyFlow(int userId, String accessToken) async {
    try {
      final response = await _dioClient.post(
        '/api/AI/analyzemoneyflow',
        data: {'userId': userId},
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return Right(response.data.toString());
    } on DioException catch (e) {
      return Left(Failure(
        e.response?.data['message'] ?? 'Failed to analyze money flow',
      ));
    }
  }

  @override
  Future<Either<Failure, String>> analyzeMoneyFlowByDate(int userId, DateTime selectedDate, String accessToken) async {
    try {
      final payload = {
        'UserId': userId,
        'SelectedDate': selectedDate.toIso8601String(),
      };
      print('Sending request: $payload'); // Debug log
      final response = await _dioClient.post(
        '/api/AI/analyzemoneyflowbydate',

        data: {
          'userId': userId,
          'selectedDate': selectedDate.toIso8601String(),
        },
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final extractedText = (response.data['value']['content'] as List)
          .map((item) => item['text'])
          .join('\n');
      return Right(extractedText);
    } on DioException catch (e) {
      print('DioException: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      return Left(
        Failure(e.response?.data['message'] ?? 'Failed to add category'),
      );
    }catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> analyzeMoneyFlowByDateRange(int userId, DateTime startDate, DateTime endDate, String accessToken) async {
    try {
      final payload = {
        'UserId': userId,
        'StartDate': startDate.toIso8601String(),
        'EndDate': endDate.toIso8601String(),
      };
      print('Sending request: $payload'); // Debug log
      final response = await _dioClient.post(
        '/api/AI/analyzemoneyflowbydaterange',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final extractedText = (response.data['value']['content'] as List)
          .map((item) => item['text'])
          .join('\n');
      return Right(extractedText);
    } on DioException catch (e) {
      print('DioException: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      return Left(
        Failure(e.response?.data['message'] ?? 'Failed to add category'),
      );
    }catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}