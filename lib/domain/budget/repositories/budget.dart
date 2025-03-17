import 'package:dartz/dartz.dart';

import '../../../common/helper/message/Failure.dart';
import '../entities/budget.dart';

abstract class BudgetRepository{
  Future<Either<Failure, List<Budget>>> getBudgetsByUserId(
      int userId,
      String accessToken,
      DateTime date
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
      String accessToken,
      );
}