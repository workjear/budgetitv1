import 'package:budgeit/common/bloc/session/session_cubit.dart';
import 'package:budgeit/common/bloc/session/session_state.dart';
import 'package:budgeit/common/helper/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgeit/common/widgets/loading.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/helper/toast/toast.dart';
import '../../../core/config/themes/app_theme.dart';
import '../../auth_page/page/signin.dart';
import '../bloc/budget/budget_cubit.dart';
import '../bloc/budget/budget_state.dart';
import 'editBudget.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, sessionState) {
        if (sessionState is SessionAuthenticated) {
          final String userId = sessionState.user.id;
          final String accessToken = sessionState.accessToken;

          final budgetCubit = context.read<BudgetCubit>();

          if (budgetCubit.state.budgets.isEmpty) {
            budgetCubit.refreshData(DateTime.now(), userId, accessToken);
          }

          return BudgetView(userId: userId, accessToken: accessToken);
        } else if (sessionState is SessionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const SignInPage();
        }
      },
    );
  }
}

class BudgetView extends StatelessWidget {
  final String userId;
  final String accessToken;

  const BudgetView({super.key, required this.userId, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BudgetCubit, BudgetState>(
      listenWhen: (previous, current) {
        return (previous.successMessage == null && current.successMessage != null) ||
            (previous.error == null && current.error != null);
      },
      listener: (context, state) {
        if (state.error != null) {
          ToastHelper.showError(
            context: context,
            title: 'Error',
            description: state.error!,
          );
          context.read<BudgetCubit>().clearError();
        } else if (state.successMessage != null && !state.isLoading) {
          ToastHelper.showSuccess(
            context: context,
            title: 'Success',
            description: state.successMessage!,
          );
          context.read<BudgetCubit>().clearSuccessMessage();
        }
      },
      builder: (context, state) {
        print('BudgetView builder called with ${state.budgets.length} budgets');
        if (state.error != null) {
          return Center(child: Text(state.error!));
        }
        return LoadingOverlay(
          isLoading: state.isLoading,
          child: RefreshIndicator(
            onRefresh: () async {
              final cubit = context.read<BudgetCubit>(); // Use provided instance
              await cubit.refreshData(cubit.selectedDate ?? DateTime.now(), userId, accessToken);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildDateFilter(context),
                  _buildSummaryCard(context, state),
                  _buildBudgetList(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[100],
              foregroundColor: Colors.purple,
            ),
            onPressed: () async {
              final cubit = context.read<BudgetCubit>(); // Use provided instance
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: cubit.selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                cubit.setDateFilter(pickedDate, userId, accessToken);
              }
            },
            child: const Text('Select Date'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.purple),
            onPressed: () {
              final cubit = context.read<BudgetCubit>(); // Use provided instance
              cubit.setDateFilter(DateTime.now(), userId, accessToken);
            },
            child: const Text('Today'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, BudgetState state) {
    final totalRemaining = state.budgets.values.fold<double>(
      0,
          (sum, budget) => sum + (budget.remainingBudget ?? budget.amount),
    );
    final remainingCategories = state.budgets.values.where(
          (budget) => (budget.remainingBudget ?? budget.amount) > 0,
    ).toList();
    final totalRemainingPositive = remainingCategories.fold<double>(
      0,
          (sum, budget) => sum + (budget.remainingBudget ?? budget.amount),
    );
    final totalBudget = state.budgets.values.fold<double>(0, (sum, b) => sum + b.amount);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: totalRemaining < 0
              ? [Colors.redAccent.shade200, Colors.redAccent.shade700]
              : [Colors.greenAccent.shade200, Colors.greenAccent.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Remaining Budget',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₱${totalRemaining.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                '₱${totalBudget.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Remaining in ${remainingCategories.length} categories: ₱${totalRemainingPositive.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetList(BuildContext context, BudgetState state) {
    final ValueNotifier<bool> isEditMode = ValueNotifier(false);

    print('Building budget list with ${state.budgets.length} items');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Budgets', style: Theme.of(context).textTheme.titleLarge),
              ValueListenableBuilder<bool>(
                valueListenable: isEditMode,
                builder: (context, editMode, _) => IconButton(
                  icon: Icon(editMode ? Icons.check : Icons.edit, color: editMode ? AppTheme.primaryColor : Colors.grey),
                  onPressed: () => isEditMode.value = !isEditMode.value,
                ),
              ),
            ],
          ),
        ),
        state.budgets.isEmpty
            ? const Center(child: Text('No budgets yet'))
            : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: state.budgets.length,
          itemBuilder: (context, index) {
            final budget = state.budgets.values.elementAt(index);
            print('Rendering budget: ${budget.categoryName}');
            return BudgetTile(
              budget: budget,
              isEditMode: isEditMode,
              accessToken: accessToken,
              userId: userId,
            );
          },
        ),
      ],
    );
  }
}

class BudgetTile extends StatelessWidget {
  final dynamic budget;
  final ValueNotifier<bool> isEditMode;
  final String accessToken;
  final String userId;

  const BudgetTile({
    super.key,
    required this.budget,
    required this.isEditMode,
    required this.accessToken,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = budget.remainingBudget ?? budget.amount;
    final percentageRemaining = (remaining / budget.amount * 100).clamp(0, 100).toInt();
    final color = Color(int.parse(budget.color.replaceAll('#', '0xFF')));
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<bool>(
      valueListenable: isEditMode,
      builder: (context, editMode, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 8), // Adjust as needed (e.g., bottom: 8)
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.1),
                child: SvgPicture.network(
                  'https://api.iconify.design/material-symbols/${budget.icon}.svg',
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  placeholderBuilder: (context) => CircularProgressIndicator(
                    color: isDarkMode ? Colors.white : AppTheme.primaryColor,
                  ),
                ),
              ),
              title: Text(
                budget.categoryName,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: remaining / budget.amount,
                    backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    color: _getProgressColor(percentageRemaining, remaining < 0),
                    minHeight: 8,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    remaining < 0 ? 'Overspent' : '$percentageRemaining% remaining',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: editMode
                  ? IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _handleDelete(context, budget.budgetId),
              )
                  : Text(
                '₱${remaining.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: _getProgressColor(percentageRemaining, remaining < 0),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: editMode
                  ? () => AppNavigator.push(
                context,
                EditBudgetPage(
                  budgetId: budget.budgetId,
                  categoriesId: budget.categoriesId,
                  initialAmount: budget.amount,
                  initialCategoryName: budget.categoryName,
                  initialColor: budget.color,
                ),
              )
                  : null,
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleDelete(BuildContext context, int budgetId) async {
    if (budgetId == 0) {
      ToastHelper.showError(
        context: context,
        title: 'Error',
        description: 'Invalid budget ID',
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${budget.categoryName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      context.read<BudgetCubit>().deleteBudget(
        budgetId: budgetId,
        accessToken: accessToken,
        userId: userId,
      );
    }
  }

  Color _getProgressColor(int percentage, bool isOverspent) {
    if (isOverspent) return Colors.red;
    if (percentage >= 75) return Colors.green;
    if (percentage >= 50) return Colors.lightGreen;
    if (percentage >= 25) return Colors.orange;
    return Colors.red;
  }
}