// lib/data/budgets/services/budget_api_services.dart
import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../domain/budget/entities/budget.dart';
import '../../../service_locator.dart';

abstract class BudgetApiService {
  Future<Either<Failure, List<Budget>>> getBudgetsByUserId(
      int userId,
      String accessToken,
      DateTime? date,
      );

  Future<Either<Failure, String>> setBudget(
      int categoriesId,
      double amount,
      String color,
      String accessToken,
      );

  Future<Either<Failure, String>> updateBudget(
      int budgetId,
      int categoriesId,
      double amount,
      String color,
      String accessToken,
      );
  Future<Either<Failure, String>> deleteBudget(
    int budgetId,
    String accessToken
      );
}

class BudgetApiServiceImpl implements BudgetApiService {
  final DioClient client = sl<DioClient>(instanceName: 'apiUrl');

  @override
  Future<Either<Failure, List<Budget>>> getBudgetsByUserId(
      int userId,
      String accessToken,
        DateTime? date,
      ) async {
    try {
      final queryParameters = {
        'userId': userId,
        'date': date?.toIso8601String().split('T')[0],
      };
      final response = await client.get(
        '/api/Budgets/getbudgetsbyuserid',
        queryParameters: queryParameters,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      final budgets = (response.data as List).map((json) => Budget.fromJson(json)).toList();
      return Right(budgets);
    } on DioException catch (e) {
      return Left(
        Failure(e.response?.data['message'] ?? 'Failed to fetch budgets'),
      );
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> setBudget(
      int categoriesId,
      double amount,
      String color,
      String accessToken,
      ) async {
    try {
      final payload = {'categoriesId': categoriesId, 'amount': amount, 'color': color};
      print('Sending request: $payload');
      final response = await client.post(
        '/api/Budgets/setbudget',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return Right(response.data as String? ?? 'Budget set successfully');
    } on DioException catch (e) {
      print('DioException: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      // Handle both JSON and plain string responses
      String errorMessage;
      if (e.response?.data is String) {
        errorMessage = e.response!.data as String;
      } else if (e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? 'Failed to set budget';
      } else {
        errorMessage = 'Failed to set budget';
      }
      return Left(Failure(errorMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateBudget(
      int budgetId,
      int categoriesId,
      double amount,
      String color,
      String accessToken,
      ) async {
    try {
      final payload = {'categoriesId': categoriesId, 'amount': amount, 'color': color};
      print('Sending request: $payload');
      final response = await client.put(
        '/api/Budgets/updatebudget/$budgetId',
        data: payload,
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      return Right(response.data as String? ?? 'Budget updated successfully');
    } on DioException catch (e) {
      print('DioException: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
      String errorMessage;
      if (e.response?.data is String) {
        errorMessage = e.response!.data as String;
      } else if (e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? 'Failed to update budget';
      } else {
        errorMessage = 'Failed to update budget';
      }
      return Left(Failure(errorMessage));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteBudget(
      int budgetId,
      String accessToken,
      ) async  {
    try {
      final response = await client.delete(
        '/api/Budgets/deletebudget/$budgetId',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      );
      if (response is String) {
        return Right(response);
      }
      else if (response is Response) {
        return Right(response.data.toString());
      }
      else {
        return Right('Budget deleted successfully');
      }
    } catch (e) {
      if (e is DioException) {
        String errorMessage;
        if (e.response?.data is String) {
          errorMessage = e.response!.data;
        } else if (e.response?.data is Map) {
          errorMessage = e.response?.data['message'] ?? 'Failed to delete budget';
        } else {
          errorMessage = 'Failed to delete budget';
        }
        return Left(Failure(errorMessage));
      }
      return Left(Failure(e.toString()));
    }
  }
}