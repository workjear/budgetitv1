// lib/utils/toast_helper.dart
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

enum ToastType {
  success,
  error,
  warning,
}

class ToastHelper {
  static void showToast({
    required BuildContext? context, // Optional context, null for context-less
    required String title,
    String? description,
    required ToastType type,
    int durationSeconds = 3,
    Alignment alignment = Alignment.topRight,
  }) {
    // Determine the style based on type
    ToastificationType toastType;
    Color primaryColor;
    Color backgroundColor;

    switch (type) {
      case ToastType.success:
        toastType = ToastificationType.success;
        primaryColor = Colors.green;
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        break;
      case ToastType.error:
        toastType = ToastificationType.error;
        primaryColor = Colors.red;
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        break;
      case ToastType.warning:
        toastType = ToastificationType.warning;
        primaryColor = Colors.orange;
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        break;
    }

    toastification.show(
      context: context, // Use provided context or fallback to navigatorKey
      type: toastType,
      style: ToastificationStyle.flatColored,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black, // Explicit text color
        ),
      ),
      description: description != null
          ? Text(
        description,
        style: const TextStyle(color: Colors.black), // Explicit text color
      )
          : null,
      alignment: alignment,
      autoCloseDuration: Duration(seconds: durationSeconds),
      primaryColor: primaryColor,
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
      showProgressBar: true,
      closeButton: ToastCloseButton(),
      closeOnClick: false,
      pauseOnHover: true,
    );
  }

  // Convenience methods for each type
  static void showSuccess({
    required BuildContext? context,
    required String title,
    String? description,
    int durationSeconds = 3,
    Alignment alignment = Alignment.topRight,
  }) {
    showToast(
      context: context,
      title: title,
      description: description,
      type: ToastType.success,
      durationSeconds: durationSeconds,
      alignment: alignment,
    );
  }

  static void showError({
    required BuildContext? context,
    required String title,
    String? description,
    int durationSeconds = 3,
    Alignment alignment = Alignment.topRight,
  }) {
    showToast(
      context: context,
      title: title,
      description: description,
      type: ToastType.error,
      durationSeconds: durationSeconds,
      alignment: alignment,
    );
  }

  static void showWarning({
    required BuildContext? context,
    required String title,
    String? description,
    int durationSeconds = 3,
    Alignment alignment = Alignment.topRight,
  }) {
    showToast(
      context: context,
      title: title,
      description: description,
      type: ToastType.warning,
      durationSeconds: durationSeconds,
      alignment: alignment,
    );
  }

  // Dismiss all toasts
  static void dismissAll() {
    toastification.dismissAll();
  }
}