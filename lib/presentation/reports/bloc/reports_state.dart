import 'package:equatable/equatable.dart';
import 'package:budgeit/data/categorystream/models/category_stream.dart';

enum ReportFilter { singleDate, dateRange }

class ReportsState extends Equatable {
  final List<CategoryStream> categoryStreams;
  final String? aiAnalysis;
  final bool isLoading;
  final bool hasError;
  final DateTime? selectedDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final ReportFilter filter;
  final bool hasFetchedInitialData;

  const ReportsState({
    this.categoryStreams = const [],
    this.aiAnalysis,
    this.isLoading = false,
    this.hasError = false,
    this.selectedDate,
    this.startDate,
    this.endDate,
    this.filter = ReportFilter.singleDate,
    this.hasFetchedInitialData = false,
  });

  ReportsState copyWith({
    List<CategoryStream>? categoryStreams,
    String? aiAnalysis,
    bool? isLoading,
    bool? hasError,
    DateTime? selectedDate,
    DateTime? startDate,
    DateTime? endDate,
    ReportFilter? filter,
    bool? hasFetchedInitialData,
  }) {
    return ReportsState(
      categoryStreams: categoryStreams ?? this.categoryStreams,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      selectedDate: selectedDate ?? this.selectedDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      filter: filter ?? this.filter,
      hasFetchedInitialData: hasFetchedInitialData ?? this.hasFetchedInitialData,
    );
  }

  @override
  List<Object?> get props => [
    categoryStreams,
    aiAnalysis,
    isLoading,
    hasError,
    selectedDate,
    startDate,
    endDate,
    filter,
    hasFetchedInitialData,
  ];
}