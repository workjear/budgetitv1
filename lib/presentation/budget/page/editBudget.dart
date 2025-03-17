import 'package:budgeit/common/bloc/session/session_cubit.dart';
import 'package:budgeit/common/bloc/session/session_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../common/helper/toast/toast.dart';
import '../../../core/config/themes/app_theme.dart';
import '../../../service_locator.dart';
import '../../auth_page/page/signin.dart';
import '../bloc/budget/budget_cubit.dart';
import '../bloc/budget/budget_state.dart';

class EditBudgetPage extends StatelessWidget {
  final int budgetId;
  final int categoriesId;
  final double initialAmount;
  final String initialCategoryName;
  final String initialColor;

  const EditBudgetPage({
    super.key,
    required this.budgetId,
    required this.categoriesId,
    required this.initialAmount,
    required this.initialCategoryName,
    required this.initialColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, sessionState) {
        if (sessionState is SessionAuthenticated) {
          final String accessToken = sessionState.accessToken;
          final String userId = sessionState.user.id;
          return BlocProvider.value(
            value: sl<BudgetCubit>(),
            child: EditBudgetContent(
              budgetId: budgetId,
              categoriesId: categoriesId,
              initialAmount: initialAmount,
              initialCategoryName: initialCategoryName,
              initialColor: initialColor,
              accessToken: accessToken,
              userId: userId,
            ),
          );
        } else if (sessionState is SessionLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return const SignInPage();
        }
      },
    );
  }
}

class EditBudgetContent extends StatefulWidget {
  final int budgetId;
  final int categoriesId;
  final double initialAmount;
  final String initialCategoryName;
  final String initialColor;
  final String accessToken;
  final String userId;

  const EditBudgetContent({
    super.key,
    required this.budgetId,
    required this.categoriesId,
    required this.initialAmount,
    required this.initialCategoryName,
    required this.initialColor,
    required this.accessToken,
    required this.userId
  });

  @override
  _EditBudgetContentState createState() => _EditBudgetContentState();
}

class _EditBudgetContentState extends State<EditBudgetContent> {
  late TextEditingController amountController;
  late TextEditingController nameController;
  late Color pickerColor;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: widget.initialAmount.toStringAsFixed(2));
    nameController = TextEditingController(text: widget.initialCategoryName);
    pickerColor = Color(int.parse(widget.initialColor.replaceAll('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Budget', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: BlocListener<BudgetCubit, BudgetState>(
            listener: (context, state) {
              if (state.error == null && !state.isLoading) {
                ToastHelper.showSuccess(
                  context: context,
                  title: 'Success',
                  description: 'Budget updated successfully',
                );
                Navigator.pop(context);
              } else if (state.error != null) {
                ToastHelper.showError(
                  context: context,
                  title: 'Error',
                  description: state.error!,
                );
              }
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BudgetAmountField(
                    controller: amountController,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  _CategoryNameField(
                    controller: nameController,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  _ColorPickerField(
                    pickerColor: pickerColor,
                    onColorChanged: (color) => setState(() => pickerColor = color),
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.075),
                  _SaveButton(
                    budgetId: widget.budgetId,
                    categoriesId: widget.categoriesId,
                    amountController: amountController,
                    nameController: nameController,
                    color: pickerColor,
                    accessToken: widget.accessToken,
                    userId: widget.userId,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    amountController.dispose();
    nameController.dispose();
    super.dispose();
  }
}

class _BudgetAmountField extends StatelessWidget {
  final TextEditingController controller;
  final double screenWidth;

  const _BudgetAmountField({required this.controller, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Budget Amount',
        hintText: 'Enter budget amount',
        prefixIcon: const Padding(
          padding: EdgeInsets.all(12.0),
          child: Text(
            '₱',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }
}

class _ColorPickerField extends StatelessWidget {
  final Color pickerColor;
  final Function(Color) onColorChanged;
  final double screenWidth;

  const _ColorPickerField({
    required this.pickerColor,
    required this.onColorChanged,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: pickerColor,
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
        ),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showColorPicker(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Select Budget Color'),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: pickerColor,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Select'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _CategoryNameField extends StatelessWidget {
  final TextEditingController controller;
  final double screenWidth;

  const _CategoryNameField({required this.controller, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Category Name',
        hintText: 'Enter category name',
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.04,
          horizontal: screenWidth * 0.05,
        ),
      ),
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final int budgetId;
  final int categoriesId;
  final TextEditingController amountController;
  final TextEditingController nameController;
  final Color color;
  final String accessToken;
  final String userId;

  const _SaveButton({
    required this.budgetId,
    required this.categoriesId,
    required this.amountController,
    required this.nameController,
    required this.color,
    required this.accessToken,
    required this.userId
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, state) {
        final isLoading = state.isLoading;
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount <= 0 || nameController.text.isEmpty) {
                ToastHelper.showError(
                  context: context,
                  title: 'Error',
                  description: 'Please enter a valid amount and category name',
                );
                return;
              }
              final colorHex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
              sl<BudgetCubit>().updateBudget(
                budgetId: budgetId,
                categoriesId: categoriesId,
                amount: amount,
                color: colorHex,
                categoryName: nameController.text,
                accessToken: accessToken,
                userId: userId,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
            ),
            child: isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
                : Text(
              'Save Changes',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}