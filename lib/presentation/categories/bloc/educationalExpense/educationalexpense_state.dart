import '../../../../common/widgets/category_grid.dart';
import '../../../../data/categories/models/category.dart';

abstract class EducationalExpenseState {}

class EducationalExpenseInitial extends EducationalExpenseState {}

class EducationalExpenseLoading extends EducationalExpenseState implements LoadingState {}

class EducationalExpenseLoaded extends EducationalExpenseState {
  final List<Category> educationalExpenseCategories;
  final String? selectedCategory;
  final bool isEditing;

  EducationalExpenseLoaded({
    required this.educationalExpenseCategories,
    this.selectedCategory,
    this.isEditing = false,
  });

  EducationalExpenseLoaded copyWith({
    List<Category>? educationalExpenseCategories,
    String? selectedCategory,
    bool? isEditing,
  }) {
    return EducationalExpenseLoaded(
      educationalExpenseCategories: educationalExpenseCategories ?? this.educationalExpenseCategories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isEditing: isEditing ?? this.isEditing,
    );
  }
}

class EducationalExpenseError extends EducationalExpenseState implements ErrorState {
  @override
  final String message;

  EducationalExpenseError(this.message);
}

class EducationalExpenseSuccess extends EducationalExpenseState implements SuccessState {
  final String category;
  final String description;
  @override
  final String message;
  final double amount;

  EducationalExpenseSuccess({
    required this.category,
    required this.description,
    required this.amount,
    required this.message,
  });

}