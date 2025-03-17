import 'dart:async';

import 'package:budgeit/presentation/budget/bloc/setBudget/set_budget_state.dart';
import 'package:budgeit/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../../data/budget/models/set_budget_params.dart';
import '../../../../domain/budget/usecase/setBudget.dart';
import '../budget/budget_cubit.dart'; // Import BudgetCubit

class SetBudgetCubit extends Cubit<SetBudgetState> {
  final SetBudgetUseCase _setBudgetUseCase;
  final BudgetCubit _budgetCubit; // Reference to BudgetCubit

  SetBudgetCubit({
    SetBudgetUseCase? setBudgetUseCase,
    BudgetCubit? budgetCubit,
  })  : _setBudgetUseCase = setBudgetUseCase ?? sl<SetBudgetUseCase>(),
        _budgetCubit = budgetCubit ?? sl<BudgetCubit>(),
        super(SetBudgetInitial());

  Future<void> setBudget({
    required int categoryId,
    required double amount,
    required String color,
    required String accessToken,
    required String userId,
  }) async {
    emit(SetBudgetLoading());

    final result = await _setBudgetUseCase(
      params: SetBudgetParams(
        categoriesId: categoryId,
        amount: amount,
        color: color,
        accessToken: accessToken,
      ),
    );

    result.fold(
          (failure) => emit(SetBudgetError(failure.message)),
          (success) {
        emit(SetBudgetSuccess());
        _budgetCubit.refreshData(
          _budgetCubit.selectedDate ?? DateTime.now(),
          userId,
          accessToken,
        );
      },
    );
  }

  void updateSelectedCategory(String? categoryId) {
    if (state is SetBudgetLoaded) {
      final currentState = state as SetBudgetLoaded;
      emit(currentState.copyWith(selectedCategoryId: categoryId));
    }
  }

  void updateColor(Color color) {
    if (state is SetBudgetLoaded) {
      final currentState = state as SetBudgetLoaded;
      emit(currentState.copyWith(selectedColor: color));
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}