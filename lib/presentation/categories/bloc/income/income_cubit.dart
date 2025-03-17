import 'package:budgeit/domain/categories/usecase/get_category_by_id.dart';
import 'package:budgeit/domain/categorystream/usecase/add_stream.dart';
import 'package:budgeit/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/enums.dart';
import '../../../../domain/categories/usecase/delete_category.dart';
import '../../../calendar/bloc/calendar_cubit.dart';
import 'income_state.dart';

class AddIncomeCubit extends Cubit<AddIncomeState> {
  final GetCategoriesByIdUseCase _getCategoriesById;
  final CategoryStreamCubit _categoryStreamCubit;

  AddIncomeCubit({GetCategoriesByIdUseCase? getCategoriesById,
    CategoryStreamCubit? categoryStreamCubit,})
    : _getCategoriesById = getCategoriesById ?? sl<GetCategoriesByIdUseCase>(), _categoryStreamCubit = categoryStreamCubit ?? sl<CategoryStreamCubit>(),
      super(AddIncomeInitial());

  Future<void> fetchIncomeCategories(String userId, String accessToken) async {
    if (isClosed) return; // Prevent emitting if cubit is closed
    emit(AddIncomeLoading());

    final result = await _getCategoriesById(
      params: GetCategoriesByIdParams(
        userId: int.tryParse(userId) ?? 0,
        accessToken: accessToken,
      ),
    );

    result.fold(
          (failure) {
        if (!isClosed) emit(AddIncomeError(failure.message));
      },
          (categories) {
        if (!isClosed) {
          final incomeCategories =
          categories.where((cat) => cat.type == CategoryType.income).toList();
          emit(AddIncomeLoaded(incomeCategories: incomeCategories));
        }
      },
    );
  }

  void setSelectedCategory(String? category) {
    if (isClosed) return;
    if (state is AddIncomeLoaded) {
      final currentState = state as AddIncomeLoaded;
      emit(currentState.copyWith(selectedCategory: category));
    }
  }

  void submitIncome(
    String description,
    double amount,
    String accessToken,
    String userId,
  ) async {
    if (state is AddIncomeLoaded) {
      final currentState = state as AddIncomeLoaded;
      if (currentState.selectedCategory != null) {
        emit(AddIncomeLoading());

        final selectedCategory = currentState.incomeCategories.firstWhere(
          (cat) => cat.name == currentState.selectedCategory,
        );
        final result = await sl<AddStreamUseCase>().call(
          params: AddStreamParams(
            categoryId: selectedCategory.categoriesId,
            stream: amount,
            notes: description,
            accessToken: accessToken,
          ),
        );

        result.fold(
          (failure) => emit(AddIncomeError(failure.message)),
          (success) async {
            emit(AddIncomeSuccess(
                category: currentState.selectedCategory!,
                description: description,
                amount: amount,
                message: success.toString(),
            ));
            await fetchIncomeCategories(userId, accessToken);
            await _categoryStreamCubit.refreshStreams(
              userId: int.tryParse(userId) ?? 0,
              date: DateTime.now(),
              accessToken: accessToken,
            );
          }
        );
      } else {
        emit(AddIncomeError('No category selected'));
      }
    }
  }

  void toggleEditMode() {
    if (state is AddIncomeLoaded) {
      final currentState = state as AddIncomeLoaded;
      emit(currentState.copyWith(isEditing: !currentState.isEditing));
    }
  }

  Future<void> deleteCategory(
    int categoryId,
    String accessToken,
    String userId,
  ) async {
    if (state is AddIncomeLoaded) {
      final currentState = state as AddIncomeLoaded;
      emit(AddIncomeLoading());

      final result = await sl<DeleteCategoryUseCase>().call(
        params: DeleteCategoryParams(
          accessToken: accessToken,
          categoryId: categoryId,
        ),
      );

      result.fold(
        (failure) {
          emit(AddIncomeError(failure.message));
        },
        (_) {
          // Now userId is available as a parameter
          fetchIncomeCategories(userId, accessToken);
        },
      );
    }
  }
}
