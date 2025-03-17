// setbudget_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SetBudgetState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SetBudgetInitial extends SetBudgetState {}

class SetBudgetLoading extends SetBudgetState {}

class SetBudgetLoaded extends SetBudgetState {
  final String? selectedCategoryId;
  final Color? selectedColor;

  SetBudgetLoaded({
    this.selectedCategoryId,
    this.selectedColor,
  });

  SetBudgetLoaded copyWith({
    String? selectedCategoryId,
    Color? selectedColor,
  }) {
    return SetBudgetLoaded(
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  @override
  List<Object?> get props => [selectedCategoryId, selectedColor];
}

class SetBudgetSuccess extends SetBudgetState {}

class SetBudgetError extends SetBudgetState {
  final String message;

  SetBudgetError(this.message);

  @override
  List<Object?> get props => [message];
}