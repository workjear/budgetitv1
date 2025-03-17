class UpdateBudgetParams{
  final int budgetId;
  final int categoriesId;
  final double amount;
  final String color;
  final String accessToken;

  UpdateBudgetParams({
    required this.categoriesId,
    required this.budgetId,
    required this.amount,
    required this.color,
    required this.accessToken
  });
}