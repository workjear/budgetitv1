import 'package:budgeit/core/enums/enums.dart';
import 'package:budgeit/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/widgets/category_grid.dart';
import '../bloc/personalExpense/myexpense_cubit.dart';
import '../bloc/personalExpense/myexpense_state.dart';

class PersonalExpense extends StatelessWidget {
  final String accessToken;
  final String userId;

  const PersonalExpense({
    super.key,
    required this.accessToken,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PersonalExpenseCubit>(
      create:
          (context) =>
              PersonalExpenseCubit()
                ..fetchPersonalExpenseCategories(userId, accessToken),
      child: Builder(
        builder: (context) {
          final cubit = context.read<PersonalExpenseCubit>();
          return CategoryGridPage<PersonalExpenseCubit, PersonalExpenseState>(
            title: 'Add Personal Expense',
            emptyMessage: 'No expense categories available',
            successMessage: 'Personal Expense added',
            cubit: cubit,
            accessToken: accessToken,
            userId: userId,
            categoryType: CategoryType.personalExpense.value,
            fetchCategories:
                (cubit, userId, token) =>
                    cubit.fetchPersonalExpenseCategories(userId, token),
            getCategories:
                (state) =>
                    state is PersonalExpenseLoaded
                        ? state.personalExpenseCategories
                        : [],
            isEditing:
                (state) => state is PersonalExpenseLoaded && state.isEditing,
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
