import 'package:budgeit/common/widgets/category_grid.dart';

import '../../../../data/categories/models/category.dart';

abstract class PersonalExpenseState {}

class PersonalExpenseInitial extends PersonalExpenseState {}

class PersonalExpenseLoading extends PersonalExpenseState implements LoadingState {}

class PersonalExpenseLoaded extends PersonalExpenseState {
  final List<Category> personalExpenseCategories;
  final String? selectedCategory;
  final bool isEditing;

  PersonalExpenseLoaded({
    required this.personalExpenseCategories,
    this.selectedCategory,
    this.isEditing = false,
  });

  PersonalExpenseLoaded copyWith({
    List<Category>? personalExpenseCategories,
    String? selectedCategory,
    bool? isEditing,
  }) {
    return PersonalExpenseLoaded(
      personalExpenseCategories: personalExpenseCategories ?? this.personalExpenseCategories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class PersonalExpenseError extends PersonalExpenseState implements ErrorState {
  @override
  final String message;

  PersonalExpenseError(this.message);
}

class PersonalExpenseSuccess extends PersonalExpenseState implements SuccessState{
  final String category;
  final String description;
  @override
  final String message;
  final double amount;

  PersonalExpenseSuccess({
    required this.category,
    required this.description,
    required this.amount,
    required this.message
  });
}