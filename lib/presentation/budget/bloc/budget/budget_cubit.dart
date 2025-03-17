import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgeit/data/budget/models/delete_budget_params.dart';
import 'package:budgeit/data/budget/models/get_budget_by_userId_params.dart';
import 'package:budgeit/data/budget/models/update_budget_params.dart';
import 'package:budgeit/domain/budget/usecase/getBudgetsByUserId.dart';
import 'package:budgeit/service_locator.dart';
import '../../../../domain/budget/usecase/deleteBudget.dart';
import '../../../../domain/budget/usecase/updateBudget.dart';
import 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final GetBudgetsByUserIdUseCase _getBudgetsByUserIdUseCase;
  final DeleteBudgetUseCase _deleteBudgetUseCase;
  final UpdateBudgetUseCase _updateBudgetUseCase;

  DateTime? selectedDate;

  BudgetCubit({
    GetBudgetsByUserIdUseCase? getBudgetsByUserIdUseCase,
    DeleteBudgetUseCase? deleteBudgetUseCase,
    UpdateBudgetUseCase? updateBudgetUseCase,
  })  : _getBudgetsByUserIdUseCase = getBudgetsByUserIdUseCase ?? sl<GetBudgetsByUserIdUseCase>(),
        _deleteBudgetUseCase = deleteBudgetUseCase ?? sl<DeleteBudgetUseCase>(),
        _updateBudgetUseCase = updateBudgetUseCase ?? sl<UpdateBudgetUseCase>(),
        super(BudgetState.initial());

  Future<void> refreshData(DateTime? selectedDate, String userId, String accessToken) async {
    if (isClosed) return;
    final currentSuccessMessage = state.successMessage;
    emit(state.copyWith(isLoading: true, successMessage: currentSuccessMessage));

    try {
      final dateToFetch = selectedDate ?? this.selectedDate ?? DateTime.now();
      this.selectedDate = dateToFetch;

      final params = GetBudgetByUserIdParams(
        userId: int.parse(userId),
        accessToken: accessToken,
        date: dateToFetch,
      );

      final budgetsResult = await _getBudgetsByUserIdUseCase.call(params: params);

      budgetsResult.fold(
            (failure) {
          print('Failed to load budgets: ${failure.message}');
          emit(state.copyWith(isLoading: false, error: failure.message, successMessage: null));
        },
            (budgets) {
          print('Received ${budgets.length} budgets');
          final updatedBudgets = {for (var b in budgets) b.categoryName: b};
          print('Mapped ${updatedBudgets.length} budgets');
          if (!isClosed) {
            emit(state.copyWith(budgets: updatedBudgets, isLoading: false, successMessage: currentSuccessMessage));
          }
        },
      );
    } catch (e) {
      if (!isClosed) {
        print('Error in refreshData: $e');
        emit(state.copyWith(isLoading: false, error: e.toString(), successMessage: null));
      }
    }
  }

  Future<void> setDateFilter(DateTime? selectedDate, String userId, String accessToken) async {
    if (isClosed) return;
    await refreshData(selectedDate, userId, accessToken);
  }

  Future<void> deleteBudget({required int budgetId, required String accessToken, required String userId}) async {
    if (isClosed) return;

    emit(state.copyWith(isLoading: true, error: null, successMessage: null));

    try {
      final result = await _deleteBudgetUseCase.call(
        params: DeleteBudgetParams(
          budgetId: budgetId,
          accessToken: accessToken,
        ),
      );

      result.fold(
            (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
            (successMessage) {
          emit(state.copyWith(
            successMessage: successMessage,
            isLoading: false,
          ));

          Future.delayed(Duration(milliseconds: 100), () {
            if (!isClosed) {
              refreshData(selectedDate, userId, accessToken);
            }
          });
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to delete budget: $e',
      ));
    }
  }

  void clearSuccessMessage() {
    if (isClosed) return;
    emit(state.copyWith(successMessage: null));
  }

  void clearError() {
    if (isClosed) return;
    emit(state.copyWith(error: null));
  }

  Future<void> updateBudget({
    required int budgetId,
    required int categoriesId,
    required double amount,
    required String color,
    required String accessToken,
    required String userId,
    String? categoryName,
  }) async {
    if (isClosed) return;

    emit(state.copyWith(isLoading: true));

    final result = await _updateBudgetUseCase.call(
      params: UpdateBudgetParams(
        budgetId: budgetId,
        categoriesId: categoriesId,
        amount: amount,
        color: color,
        accessToken: accessToken,
      ),
    );

    result.fold(
          (failure) => emit(state.copyWith(isLoading: false, error: failure.message)),
          (successMessage) {
        if (selectedDate != null) {
          Future.delayed(Duration(milliseconds: 100), () {
            if (!isClosed) {
              refreshData(selectedDate, userId, accessToken);
            }
          });
        }
      },
    );
  }
}