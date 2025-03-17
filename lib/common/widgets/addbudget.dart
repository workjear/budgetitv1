import 'package:budgeit/data/categories/models/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../presentation/budget/bloc/setBudget/set_budget_cubit.dart';
import '../../presentation/budget/bloc/setBudget/set_budget_state.dart';
import '../helper/toast/toast.dart';

class BudgetBottomSheet extends StatefulWidget {
  final Category category;
  final String accessToken;
  final String userId;

  const BudgetBottomSheet({
    super.key,
    required this.category,
    required this.accessToken,
    required this.userId,
  });

  @override
  State<BudgetBottomSheet> createState() => _BudgetBottomSheetState();
}

class _BudgetBottomSheetState extends State<BudgetBottomSheet> {
  final _amountController = TextEditingController();
  Color _pickerColor = Colors.blue; // Default color

  @override
  void initState() {
    super.initState();
    context.read<SetBudgetCubit>().updateColor(_pickerColor);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 20,
        right: 20,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                  child: SvgPicture.network(
                    'https://api.iconify.design/material-symbols/${widget.category.icon ?? 'category'}.svg',
                    width: 24,
                    height: 24,
                    color: Theme.of(context).colorScheme.primary,
                    placeholderBuilder: (context) => const Icon(Icons.category),
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    widget.category.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Budget Amount',
                hintText: 'Enter amount',
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
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pickerColor,
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
            ),
            const SizedBox(height: 24),
            BlocConsumer<SetBudgetCubit, SetBudgetState>(
              listener: (context, state) {
                if (state is SetBudgetSuccess) {
                  Navigator.pop(context); // Close the bottom sheet
                  ToastHelper.showSuccess(
                    context: context,
                    title: 'Success',
                    description: 'Budget set successfully',
                  );
                } else if (state is SetBudgetError) {
                  ToastHelper.showWarning(
                    context: context,
                    title: 'Warning',
                    description: state.message,
                    durationSeconds: 5,
                  );
                }
              },
              builder: (context, state) {
                return ElevatedButton(
                  onPressed: state is SetBudgetLoading
                      ? null
                      : () {
                    final amount = double.tryParse(_amountController.text) ?? 0;
                    if (amount > 0) {
                      final colorHex =
                          '#${_pickerColor.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                      final categoryId = int.tryParse(widget.category.categoriesId.toString()) ?? 0;
                      context.read<SetBudgetCubit>().setBudget(
                        categoryId: categoryId,
                        amount: amount,
                        color: colorHex,
                        accessToken: widget.accessToken,
                        userId: widget.userId,
                      );
                    } else {
                      ToastHelper.showError(
                        context: context,
                        title: 'Error',
                        description: 'Please enter a valid amount',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: state is SetBudgetLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : const Text(
                    'Set Budget',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    final setBudgetCubit = context.read<SetBudgetCubit>(); // Capture the cubit

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _pickerColor,
            onColorChanged: (color) {
              setState(() => _pickerColor = color);
            },
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(dialogContext),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Select'),
            onPressed: () {
              setBudgetCubit.updateColor(_pickerColor); // Use captured cubit
              Navigator.pop(dialogContext);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}