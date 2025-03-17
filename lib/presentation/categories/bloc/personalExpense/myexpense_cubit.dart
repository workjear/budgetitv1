import 'package:budgeit/core/enums/enums.dart';
import 'package:budgeit/domain/categories/usecase/get_category_by_id.dart';
import 'package:budgeit/domain/categories/usecase/delete_category.dart';
import 'package:budgeit/domain/categorystream/usecase/add_stream.dart';
import 'package:budgeit/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../budget/bloc/budget/budget_cubit.dart';
import '../../../calendar/bloc/calendar_cubit.dart';
import 'myexpense_state.dart';

class PersonalExpenseCubit extends Cubit<PersonalExpenseState> {
  final GetCategoriesByIdUseCase _getCategoriesById;
  final CategoryStreamCubit _categoryStreamCubit; // Add CategoryStreamCubit
  final BudgetCubit _budgetCubit;

  PersonalExpenseCubit({
    GetCategoriesByIdUseCase? getCategoriesById,
    CategoryStreamCubit? categoryStreamCubit, // Optional injection
    BudgetCubit? budgetCubit, // Optional injection
  }): _getCategoriesById = getCategoriesById ?? sl<GetCategoriesByIdUseCase>(),
        _categoryStreamCubit = categoryStreamCubit ?? sl<CategoryStreamCubit>(),
        _budgetCubit = budgetCubit ?? sl<BudgetCubit>(),
        super(PersonalExpenseInitial());

  Future<void> fetchPersonalExpenseCategories(String userId, String accessToken) async {
    if (isClosed) return; // Prevent emitting if cubit is closed
    emit(PersonalExpenseLoading());

    final result = await _getCategoriesById(
      params: GetCategoriesByIdParams(
        userId: int.tryParse(userId) ?? 0,
        accessToken: accessToken,
      ),
    );

    result.fold(
          (failure) {
        if (!isClosed) emit(PersonalExpenseError(failure.message));
      },
          (categories) {
        if (!isClosed) {
          final personalCategories =
          categories.where((cat) => cat.type == CategoryType.personalExpense).toList();
          emit(PersonalExpenseLoaded(personalExpenseCategories: personalCategories));
        }
      },
    );
  }

  void setSelectedCategory(String? category) {
    if (isClosed) return;
    if (state is PersonalExpenseLoaded) {
      final currentState = state as PersonalExpenseLoaded;
      emit(currentState.copyWith(selectedCategory: category));
    }
  }

  void submitExpense(String description, double amount, String accessToken, String userId) async {
    if (state is PersonalExpenseLoaded) {
      final currentState = state as PersonalExpenseLoaded;
      if (currentState.selectedCategory != null) {
        emit(PersonalExpenseLoading());

        final selectedCategory = currentState.personalExpenseCategories
            .firstWhere((cat) => cat.name == currentState.selectedCategory);

        final result = await sl<AddStreamUseCase>().call(
          params: AddStreamParams(
            categoryId: selectedCategory.categoriesId,
            stream: amount, // Negate for expenses
            notes: description,
            accessToken: accessToken,
          ),
        );

        result.fold(
              (failure) => emit(PersonalExpenseError(failure.message)),
              (success) async {
            emit(PersonalExpenseSuccess(
              category: currentState.selectedCategory!,
              description: description,
              amount: amount,
              message: success.toString()
            ));
            await fetchPersonalExpenseCategories(userId, accessToken);
            await _categoryStreamCubit.refreshStreams(
              userId: int.tryParse(userId) ?? 0,
              date: DateTime.now(),
              accessToken: accessToken,
            );
            await _budgetCubit.refreshData(DateTime.now(),  userId, accessToken);
          }
        );
      } else {
        emit(PersonalExpenseError('No category selected'));
      }
    }
  }

  void toggleEditMode() {
    if (state is PersonalExpenseLoaded) {
      final currentState = state as PersonalExpenseLoaded;
      emit(currentState.copyWith(isEditing: !currentState.isEditing));
    }
  }

  Future<void> deleteCategory(int categoryId, String accessToken, String userId) async {
    if (state is PersonalExpenseLoaded) {
      emit(PersonalExpenseLoading());

      final result = await sl<DeleteCategoryUseCase>().call(
        params: DeleteCategoryParams(
          accessToken: accessToken,
          categoryId: categoryId,
        ),
      );

      result.fold(
            (failure) => emit(PersonalExpenseError(failure.message)),
            (_) => fetchPersonalExpenseCategories(userId, accessToken),
      );
    }
  }
}