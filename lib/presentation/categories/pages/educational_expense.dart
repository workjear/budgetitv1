import 'package:budgeit/core/enums/enums.dart';
import 'package:budgeit/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/widgets/category_grid.dart';
import '../bloc/educationalExpense/educationalexpense_cubit.dart';
import '../bloc/educationalExpense/educationalexpense_state.dart';

class EducationalExpense extends StatelessWidget {
  final String accessToken;
  final String userId;

  const EducationalExpense({
    super.key,
    required this.accessToken,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EducationalExpenseCubit>(
      create:(context) =>EducationalExpenseCubit()..fetchCategories(userId, accessToken),
      child: Builder(
        builder: (context) {
          final cubit = context.read<EducationalExpenseCubit>();
          return CategoryGridPage<
            EducationalExpenseCubit,
            EducationalExpenseState
          >(
            title: 'Add Educational Expense',
            emptyMessage: 'No expense categories available',
            successMessage: 'Educational Expense added',
            cubit: cubit,
            accessToken: accessToken,
            userId: userId,
            categoryType: CategoryType.educationalExpense.value,
            fetchCategories:
                (cubit, userId, token) => cubit.fetchCategories(userId, token),
            getCategories:
                (state) =>
                    state is EducationalExpenseLoaded
                        ? state.educationalExpenseCategories
                        : [],
            isEditing:
                (state) => state is EducationalExpenseLoaded && state.isEditing,
            toggleEditMode: (cubit) => cubit.toggleEditMode(),
            setSelectedCategory:
                (cubit, category) => cubit.setSelectedCategory(category),
            submitAction:
                (cubit, description, amount, token) =>
                    cubit.submitExpense(description, amount, token, userId),
            deleteAction:
                (cubit, id, token, userId) =>
                    cubit.deleteCategory(id, token, userId),
          );
        },
      ),
    );
  }
}
