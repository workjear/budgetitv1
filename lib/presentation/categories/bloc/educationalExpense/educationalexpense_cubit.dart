import 'package:budgeit/core/enums/enums.dart';
import 'package:budgeit/domain/categories/usecase/get_category_by_id.dart';
import 'package:budgeit/domain/categories/usecase/delete_category.dart';
import 'package:budgeit/domain/categorystream/usecase/add_stream.dart';
import 'package:budgeit/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../budget/bloc/budget/budget_cubit.dart';
import '../../../calendar/bloc/calendar_cubit.dart';
import 'educationalexpense_state.dart';

class EducationalExpenseCubit extends Cubit<EducationalExpenseState> {
  final GetCategoriesByIdUseCase _getCategoriesById;
  final CategoryStreamCubit _categoryStreamCubit; // Add CategoryStreamCubit
  final BudgetCubit _budgetCubit; // Add BudgetCubit

  EducationalExpenseCubit({
    GetCategoriesByIdUseCase? getCategoriesById,
    CategoryStreamCubit? categoryStreamCubit, // Optional injection
    BudgetCubit? budgetCubit, // Optional injection
  })  : _getCategoriesById = getCategoriesById ?? sl<GetCategoriesByIdUseCase>(),
        _categoryStreamCubit = categoryStreamCubit ?? sl<CategoryStreamCubit>(),
        _budgetCubit = budgetCubit ?? sl<BudgetCubit>(),
        super(EducationalExpenseInitial());

  Future<void> fetchCategories(String userId, String accessToken) async {
    if (isClosed) return;
    emit(EducationalExpenseLoading());

    final result = await _getCategoriesById(
      params: GetCategoriesByIdParams(
        userId: int.tryParse(userId) ?? 0,
        accessToken: accessToken,
      ),
    );

    result.fold(
          (failure) {
        if (!isClosed) emit(EducationalExpenseError(failure.message));
      },
          (categories) {
        if (!isClosed) {
          final educationalExpense = categories
              .where((cat) => cat.type == CategoryType.educationalExpense)
              .toList();
          emit(EducationalExpenseLoaded(
              educationalExpenseCategories: educationalExpense));
        }
      },
    );
  }

  void setSelectedCategory(String? category) {
    if (isClosed) return;
    if (state is EducationalExpenseLoaded) {
      final currentState = state as EducationalExpenseLoaded;
      emit(currentState.copyWith(selectedCategory: category));
    }
  }

  Future<void> submitExpense(
      String description,
      double amount,
      String accessToken,
      String userId,
      ) async {
    if (state is EducationalExpenseLoaded) {
      final currentState = state as EducationalExpenseLoaded;
      if (currentState.selectedCategory != null) {
        emit(EducationalExpenseLoading());

        final selectedCategory = currentState.educationalExpenseCategories
            .firstWhere((cat) => cat.name == currentState.selectedCategory);

        final result = await sl<AddStreamUseCase>().call(
          params: AddStreamParams(
            categoryId: selectedCategory.categoriesId,
            stream: amount,
            notes: description,
            accessToken: accessToken,
          ),
        );

        result.fold(
              (failure) => emit(EducationalExpenseError(failure.message)),
              (success) async {
            emit(EducationalExpenseSuccess(
              category: currentState.selectedCategory!,
              description: description,
              amount: amount,
              message: success.toString(),
            ));
            await fetchCategories(userId, accessToken);
            await _categoryStreamCubit.refreshStreams(
              userId: int.tryParse(userId) ?? 0,
              date: DateTime.now(),
              accessToken: accessToken,
            );
            await _budgetCubit.refreshData(DateTime.now(), userId,  accessToken);
          },
        );
      } else {
        emit(EducationalExpenseError('No category selected'));
      }
    }
  }

  void toggleEditMode() {
    if (state is EducationalExpenseLoaded) {
      final currentState = state as EducationalExpenseLoaded;
      emit(currentState.copyWith(isEditing: !currentState.isEditing));
    }
  }

  Future<void> deleteCategory(
      int categoryId,
      String accessToken,
      String userId,
      ) async {
    if (state is EducationalExpenseLoaded) {
      emit(EducationalExpenseLoading());

      final result = await sl<DeleteCategoryUseCase>().call(
        params: DeleteCategoryParams(
          accessToken: accessToken,
          categoryId: categoryId,
        ),
      );

      result.fold(
            (failure) => emit(EducationalExpenseError(failure.message)),
            (_) => fetchCategories(userId, accessToken),
      );
    }
  }
}