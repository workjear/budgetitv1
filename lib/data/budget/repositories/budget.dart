import 'package:budgeit/common/helper/message/Failure.dart';

import 'package:budgeit/domain/budget/entities/budget.dart';

import 'package:dartz/dartz.dart';

import '../../../domain/budget/repositories/budget.dart';
import '../../../service_locator.dart';
import '../services/budget_api_service.dart';

class BudgetRepositoryImpl extends BudgetRepository{
  @override
  Future<Either<Failure, List<Budget>>> getBudgetsByUserId(int userId, String accessToken, DateTime? date) async {
    return await sl<BudgetApiService>().getBudgetsByUserId(userId, accessToken, date);
  }

  @override
  Future<Either<Failure, String>> setBudget(int categoriesId, double amount, String color, String accessToken) async {
    return await sl<BudgetApiService>().setBudget(categoriesId, amount, color, accessToken);
  }

  @override
  Future<Either<Failure, String>> updateBudget(int budgetId, int categoriesId, double amount, String color, String accessToken) async {
    return await sl<BudgetApiService>().updateBudget(budgetId, categoriesId, amount, color, accessToken);
  }

  @override
  Future<Either<Failure, String>> deleteBudget(int budgetId, String accessToken) async {
    return await sl<BudgetApiService>().deleteBudget(budgetId, accessToken);
  }
}