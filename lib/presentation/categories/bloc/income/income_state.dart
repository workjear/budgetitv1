import 'package:budgeit/common/widgets/category_grid.dart';

import '../../../../data/categories/models/category.dart';

abstract class AddIncomeState {}

class AddIncomeInitial extends AddIncomeState {}

class AddIncomeLoading extends AddIncomeState implements LoadingState{}

class AddIncomeLoaded extends AddIncomeState {
  final List<Category> incomeCategories;
  final String? selectedCategory;
  final bool isEditing; // Added for edit mode

  AddIncomeLoaded({
    required this.incomeCategories,
    this.selectedCategory,
    this.isEditing = false, // Default to false
  });

  AddIncomeLoaded copyWith({
    List<Category>? incomeCategories,
    String? selectedCategory,
    bool? isEditing,

  }) {
    return AddIncomeLoaded(
      incomeCategories: incomeCategories ?? this.incomeCategories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class AddIncomeError extends AddIncomeState implements ErrorState {
  @override
  final String message;

  AddIncomeError(this.message);
}

class AddIncomeSuccess extends AddIncomeState implements SuccessState {
  final String category;
  final String description;
  @override
  final String message;
  final double amount;

  AddIncomeSuccess({
    required this.category,
    required this.description,
    required this.amount,
    required this.message
  });
}