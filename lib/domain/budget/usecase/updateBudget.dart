import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/data/budget/models/update_budget_params.dart';
import 'package:dartz/dartz.dart';

import '../../../service_locator.dart';
import '../repositories/budget.dart';

class UpdateBudgetUseCase extends UseCase<Either<Failure, String>, UpdateBudgetParams>{

  @override
  Future<Either<Failure, String>> call({UpdateBudgetParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<BudgetRepository>().updateBudget(params.budgetId, params.categoriesId, params.amount, params.color, params.accessToken);
  }
}