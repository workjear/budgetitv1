// lib/data/budgets/models/budget.dart
import '../../../data/categories/models/category.dart';

class Budget {
  final int budgetId;
  final int categoriesId;
  final double amount;
  final double? remainingBudget;
  final String categoryName;
  final String? createdBy;
  final String color;
  final DateTime? createdDate;
  final String icon;
  final String? modifiedBy;
  final double totalSpent;
  final DateTime? modifiedDate;

  Budget({
    required this.budgetId,
    required this.categoriesId,
    required this.amount,
    this.remainingBudget,
    required this.categoryName,
    this.createdBy,
    required this.color,
    required this.totalSpent,
    required this.icon,
    this.createdDate,
    this.modifiedBy,
    this.modifiedDate,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      budgetId: json['categoryBudgetId'] as int,
      categoriesId: json['categoriesId'] as int,
      amount: json['amount'] as double,
      color: json['color'] as String,
      createdBy: json['createdBy'] as String,
      createdDate: DateTime.parse(json['createdDate'] as String),
      modifiedBy: json['modifiedBy'] as String?,
      modifiedDate: json['modifiedDate'] != null ? DateTime.parse(json['modifiedDate'] as String) : null,
      categoryName: json['categoryName'] as String,
      totalSpent: json['totalSpent'] as double,
      remainingBudget: json['remainingBudget'] as double,
      icon:  json['categoryIcon'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'BudgetId': budgetId,
      'CategoriesId': categoriesId,
      'Amount': amount,
      'RemainingBudget': remainingBudget,
      'CategoryName': categoryName,
      'Color': color,
      'TotalSpent': totalSpent,
      'Icon': icon,
      'CreatedBy': createdBy,
      'CreatedDate': createdDate?.toIso8601String(),
      'ModifiedBy': modifiedBy,
      'ModifiedDate': modifiedDate?.toIso8601String(),
    };
  }

}