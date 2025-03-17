import 'package:equatable/equatable.dart';
import '../../../data/categorystream/models/category_stream.dart';

abstract class CategoryStreamState extends Equatable {
  const CategoryStreamState();

  @override
  List<Object> get props => [];
}

class CategoryStreamInitial extends CategoryStreamState {}

class CategoryStreamLoading extends CategoryStreamState {}

class CategoryStreamLoaded extends CategoryStreamState {
  final List<CategoryStream> streams;
  final Map<DateTime, Map<String, double>> dateAmounts;
  final DateTime? selectedDate;
  final DateTime focusedDay; // Added focusedDay

  const CategoryStreamLoaded({
    required this.streams,
    this.dateAmounts = const {},
    this.selectedDate,
    required this.focusedDay, // Make it required
  });

  @override
  List<Object> get props => [streams, dateAmounts, selectedDate ?? DateTime.now(), focusedDay];
}

class CategoryStreamError extends CategoryStreamState {
  final String message;

  const CategoryStreamError(this.message);

  @override
  List<Object> get props => [message];
}