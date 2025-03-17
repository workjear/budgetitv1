import 'package:flutter/material.dart';

class CalculatorBottomSheet {
  static void show({
    required BuildContext context,
    required Function(double) onResult,
    String initialCalculation = '',
  }) {
    String calculation = initialCalculation;
    final TextEditingController calcController = TextEditingController(
      text: initialCalculation,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: calcController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Calculation',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      filled: true,
                      fillColor: Color(0xFFF5FCF9),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0 * 1.5, vertical: 16.0),
                    ),
                    enabled: false,
                  ),
                  const SizedBox(height: 16),
                  // Calculator buttons
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 1.8, // Makes the button wider
                        ),
                    itemCount: 17,
                    itemBuilder: (context, index) {
                      List<String> buttons = [
                        '7', '8', '9', '/',
                        '4', '5', '6', '*',
                        '1', '2', '3', '-',
                        '0', '.', '=', '+',
                        '⌫', // Backspace symbol
                      ];

                      return AspectRatio(
                        aspectRatio: 3.5, // Makes the button more pill-shaped
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                30,
                              ), // Pill shape
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            // Reduce padding for height
                            minimumSize: const Size(
                              80,
                              40,
                            ), // Adjust size to prevent square shape
                          ),
                          onPressed: () {
                            if (index == 14) {
                              // '=' button
                              try {
                                double result = _evaluateExpression(
                                  calculation,
                                );
                                calcController.text = result.toString();
                                onResult(result);
                                Navigator.pop(context);
                              } catch (e) {
                                calcController.text = 'Error';
                              }
                            } else if (index == 16) {
                              // Backspace button
                              if (calculation.isNotEmpty) {
                                calculation = calculation.substring(
                                  0,
                                  calculation.length - 1,
                                );
                                calcController.text = calculation;
                              }
                            } else {
                              calculation += buttons[index];
                              calcController.text = calculation;
                            }
                          },
                          child: Text(
                            buttons[index],
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Simple expression evaluator (for basic arithmetic: +, -, *, /)
  static double _evaluateExpression(String expression) {
    // This is a basic implementation. For a real app, use a proper expression parser library.
    expression = expression.replaceAll(' ', '');
    List<String> parts = expression.split(RegExp(r'([+\-*/])'));
    List<String> operators =
        expression
            .split(RegExp(r'[^+\-*/]'))
            .where((s) => s.isNotEmpty)
            .toList();

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
