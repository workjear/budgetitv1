import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgeit/service_locator.dart';
import '../bloc/income/income_cubit.dart';
import '../bloc/income/income_state.dart';
import '../../../common/widgets/category_grid.dart';
import '../../../core/enums/enums.dart';

class AddIncome extends StatelessWidget {
  final String accessToken;
  final String userId;

  const AddIncome({super.key, required this.accessToken, required this.userId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AddIncomeCubit>(
      create: (context) => AddIncomeCubit()..fetchIncomeCategories(userId, accessToken),
      child: Builder(
        builder: (context) {
          final cubit = context.read<AddIncomeCubit>();
          return CategoryGridPage<AddIncomeCubit, AddIncomeState>(
            title: 'Add Income',
            emptyMessage: 'No income categories available',
            successMessage: 'Income added',
            cubit: cubit,
            accessToken: accessToken,
            userId: userId,
            categoryType: CategoryType.income.value,
            fetchCategories: (cubit, userId, token) =>
                cubit.fetchIncomeCategories(userId, token),
            getCategories: (state) =>
            state is AddIncomeLoaded ? state.incomeCategories : [],
            isEditing: (state) => state is AddIncomeLoaded && state.isEditing,
            toggleEditMode: (cubit) => cubit.toggleEditMode(),
            setSelectedCategory: (cubit, category) =>
                cubit.setSelectedCategory(category),
            submitAction: (cubit, description, amount, token) =>
                cubit.submitIncome(description, amount, token, userId),
            deleteAction: (cubit, id, token, userId) =>
                cubit.deleteCategory(id, token, userId),
          );
        },
      ),
    );
  }
}