

import '../../../../domain/budget/entities/budget.dart';

class BudgetState {
  final Map<String, Budget> budgets;
  final bool isLoading;
  final String? error;
  final String? successMessage; // Added

  BudgetState({
    required this.budgets,
    required this.isLoading,
    this.error,
    this.successMessage,
  });

  factory BudgetState.initial() => BudgetState(
    budgets: {},
    isLoading: false,
  );

  BudgetState copyWith({
    Map<String, Budget>? budgets,
    bool? isLoading,
    String? error,  String? successMessage,
  }) {
    return BudgetState(
      budgets: budgets ?? this.budgets,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      successMessage: successMessage ?? this.successMessage,
    );
  }
}