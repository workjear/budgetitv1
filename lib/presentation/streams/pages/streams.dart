import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:budgeit/common/helper/navigation/app_navigator.dart';
import 'package:budgeit/service_locator.dart';
import '../../../core/config/themes/app_theme.dart';
import '../bloc/streams_cubit.dart';
import '../bloc/streams_state.dart';

class StreamViewPage extends StatelessWidget {
  final int streamId;
  final double initialStream;
  final String initialNotes;
  final String accessToken;

  const StreamViewPage({
    super.key,
    required this.streamId,
    required this.initialStream,
    required this.initialNotes,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<EditStreamCubit>(),
      child: StreamViewContent(
        streamId: streamId,
        initialStream: initialStream,
        initialNotes: initialNotes,
        accessToken: accessToken,
      ),
    );
  }
}

class StreamViewContent extends StatelessWidget {
  final int streamId;
  final double initialStream;
  final String initialNotes;
  final String accessToken;

  const StreamViewContent({
    super.key,
    required this.streamId,
    required this.initialStream,
    required this.initialNotes,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    final streamController = TextEditingController(text: initialStream.toStringAsFixed(2));
    final notesController = TextEditingController(text: initialNotes);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Stream', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => AppNavigator.pop(context),
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
          padding: EdgeInsets.all(screenWidth * 0.05), // Responsive padding
          child: BlocListener<EditStreamCubit, EditStreamState>(
            listener: (context, state) {
              if (state is EditStreamSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                );
                AppNavigator.pop(context);
              } else if (state is EditStreamError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.failure.message),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StreamAmountField(
                    controller: streamController,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.05),
                  _NotesField(
                    controller: notesController,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenWidth * 0.075),
                  _SaveButton(
                    streamId: streamId,
                    streamController: streamController,
                    notesController: notesController,
                    accessToken: accessToken,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StreamAmountField extends StatelessWidget {
  final TextEditingController controller;
  final double screenWidth;

  const _StreamAmountField({required this.controller, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CalculatorBottomSheet.show(
          context: context,
          onResult: (double result) {
            controller.text = result.toStringAsFixed(2);
          },
          initialCalculation: controller.text,
        );
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Stream Amount',
            hintText: 'Tap to calculate',
            prefixIcon: Icon(Icons.calculate, color: AppTheme.primaryColor),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Icon(Icons.touch_app, color: AppTheme.primaryColor),
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}

class _NotesField extends StatelessWidget {
  final TextEditingController controller;
  final double screenWidth;

  const _NotesField({required this.controller, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Notes',
        hintText: 'Add some notes...',
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
  final int streamId;
  final TextEditingController streamController;
  final TextEditingController notesController;
  final String accessToken;

  const _SaveButton({
    required this.streamId,
    required this.streamController,
    required this.notesController,
    required this.accessToken,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditStreamCubit, EditStreamState>(
      builder: (context, state) {
        final isLoading = state is EditStreamLoading;
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () {
              final streamValue = double.tryParse(streamController.text) ?? 0.0;
              if (streamValue <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter a valid amount'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
                return;
              }
              sl<EditStreamCubit>().editStream(
                streamId: streamId,
                stream: streamValue,
                notes: notesController.text,
                accessToken: accessToken,
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

class CalculatorBottomSheet {
  static void show({
    required BuildContext context,
    required Function(double) onResult,
    String initialCalculation = '',
  }) {
    String calculation = initialCalculation;
    final calcController = TextEditingController(text: initialCalculation);
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: calcController,
                decoration: InputDecoration(
                  labelText: 'Enter Calculation',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06,
                    vertical: screenWidth * 0.04,
                  ),
                ),
                enabled: false,
              ),
              SizedBox(height: screenWidth * 0.04),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (screenWidth < 400) ? 4 : 5, // Adjust for screen size
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: screenWidth < 400 ? 1.8 : 2.0,
                ),
                itemCount: 17,
                itemBuilder: (context, index) {
                  List<String> buttons = [
                    '7', '8', '9', '/',
                    '4', '5', '6', '*',
                    '1', '2', '3', '-',
                    '0', '.', '=', '+',
                    '⌫',
                  ];

                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                      minimumSize: Size(screenWidth * 0.15, screenWidth * 0.1),
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    onPressed: () {
                      if (index == 14) { // '='
                        try {
                          double result = _evaluateExpression(calculation);
                          calcController.text = result.toStringAsFixed(2);
                          onResult(result);
                          Navigator.pop(context);
                        } catch (e) {
                          calcController.text = 'Error';
                        }
                      } else if (index == 16) { // '⌫'
                        if (calculation.isNotEmpty) {
                          calculation = calculation.substring(0, calculation.length - 1);
                          calcController.text = calculation;
                          setState(() {});
                        }
                      } else {
                        calculation += buttons[index];
                        calcController.text = calculation;
                        setState(() {});
                      }
                    },
                    child: Text(
                      buttons[index],
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: screenWidth * 0.04),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close', style: Theme.of(context).textTheme.labelLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static double _evaluateExpression(String expression) {
    expression = expression.replaceAll(' ', '');
    List<String> parts = expression.split(RegExp(r'([+\-*/])'));
    List<String> operators = expression.split(RegExp(r'[^+\-*/]')).where((s) => s.isNotEmpty).toList();

    double result = double.parse(parts[0]);
    for (int i = 0; i < operators.length; i++) {
      double nextNumber = double.parse(parts[i + 1]);
      switch (operators[i]) {
        case '+':
          result += nextNumber;
          break;
        case '-':
          result -= nextNumber;
          break;
        case '*':
          result *= nextNumber;
          break;
        case '/':
          if (nextNumber != 0) {
            result /= nextNumber;
          } else {
            throw Exception('Division by zero');
          }
          break;
      }
    }
    return result;
  }
}