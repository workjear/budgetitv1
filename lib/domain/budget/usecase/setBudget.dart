import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/data/budget/models/set_budget_params.dart';
import 'package:dartz/dartz.dart';

import '../../../service_locator.dart';
import '../repositories/budget.dart';

class SetBudgetUseCase extends UseCase<Either<Failure, String>, SetBudgetParams>{

  @override
  Future<Either<Failure, String>> call({SetBudgetParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<BudgetRepository>().setBudget(params.categoriesId, params.amount, params.color, params.accessToken);
  }
}