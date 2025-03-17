import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/core/usecase/usecase.dart';
import 'package:budgeit/data/budget/models/get_budget_by_userId_params.dart';
import 'package:dartz/dartz.dart';

import '../../../service_locator.dart';
import '../entities/budget.dart';
import '../repositories/budget.dart';

class GetBudgetsByUserIdUseCase extends UseCase<Either<Failure, List<Budget>>, GetBudgetByUserIdParams>{

  @override
  Future<Either<Failure, List<Budget>>> call({GetBudgetByUserIdParams? params}) async {
    if (params == null) {
      return Left(Failure('Invalid Params'));
    }
    return await sl<BudgetRepository>().getBudgetsByUserId(params.userId, params.accessToken, params.date);
  }
}