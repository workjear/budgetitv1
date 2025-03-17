import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/data/budget/models/delete_budget_params.dart';
import 'package:dartz/dartz.dart';

import '../../../service_locator.dart';
import '../repositories/budget.dart';

class DeleteBudgetUseCase extends UseCase<Either<Failure, String>, DeleteBudgetParams>{

  @override
  Future<Either<Failure, String>> call({DeleteBudgetParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<BudgetRepository>().deleteBudget(params.budgetId, params.accessToken);
  }
}