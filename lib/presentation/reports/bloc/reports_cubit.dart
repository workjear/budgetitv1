import 'package:budgeit/presentation/reports/bloc/reports_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/categorystream/usecase/get_by_date_category_stream.dart';
import '../../../domain/categorystream/usecase/get_by_date_range_category_stream.dart';
import '../../../domain/reports/usecase/analyzeMoneyFlowByDate.dart';
import '../../../domain/reports/usecase/analyzeMoneyFlowByDateRange.dart';
import '../../../service_locator.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final AnalyzeMoneyFlowByDateUseCase _analyzeMoneyFlowByDate;
  final AnalyzeMoneyFlowByDateRangeUseCase _analyzeMoneyFlowByDateRange;
  final GetByDateCategoryStreamsByIdUseCase _getByDateCategoryStreams;
  final GetByDateRangeCategoryStreamUseCase _getByDateRangeCategoryStreams;

  ReportsCubit({
    AnalyzeMoneyFlowByDateUseCase? analyzeMoneyFlowByDate,
    AnalyzeMoneyFlowByDateRangeUseCase? analyzeMoneyFlowByDateRange,
    GetByDateCategoryStreamsByIdUseCase? getByDateCategoryStreams,
    GetByDateRangeCategoryStreamUseCase? getByDateRangeCategoryStreams,
  })  : _analyzeMoneyFlowByDate = analyzeMoneyFlowByDate ?? sl<AnalyzeMoneyFlowByDateUseCase>(),
        _analyzeMoneyFlowByDateRange = analyzeMoneyFlowByDateRange ?? sl<AnalyzeMoneyFlowByDateRangeUseCase>(),
        _getByDateCategoryStreams = getByDateCategoryStreams ?? sl<GetByDateCategoryStreamsByIdUseCase>(),
        _getByDateRangeCategoryStreams = getByDateRangeCategoryStreams ?? sl<GetByDateRangeCategoryStreamUseCase>(),
        super(ReportsState(selectedDate: DateTime.now())) {
    updateFilter(ReportFilter.singleDate); // Set initial filter
  }

  Future<void> fetchStreams({
    required int userId,
    required String accessToken,
    DateTime? selectedDate,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (isClosed) return;

    final newSelectedDate = selectedDate ?? state.selectedDate ?? DateTime.now();
    final newStartDate = startDate ?? state.startDate;
    final newEndDate = endDate ?? state.endDate;

    if (state.hasFetchedInitialData &&
        state.selectedDate == newSelectedDate &&
        state.startDate == newStartDate &&
        state.endDate == newEndDate) {
      return;
    }

    emit(state.copyWith(isLoading: true, hasError: false));

    try {
      if (state.filter == ReportFilter.singleDate) {
        final streamsResult = await _getByDateCategoryStreams.call(
          params: GetByDateCategoryStreamsByIdParams(
            date: newSelectedDate,
            accessToken: accessToken,
            userId: userId,
          ),
        );

        streamsResult.fold(
              (failure) {
            emit(state.copyWith(hasError: true, isLoading: false));
            print(failure.message);
          },
              (streams) => emit(
            state.copyWith(
              categoryStreams: streams,
              isLoading: false,
              selectedDate: newSelectedDate,
              startDate: null,
              endDate: null,
              hasFetchedInitialData: true,
            ),
          ),
        );
      } else if (state.filter == ReportFilter.dateRange && newStartDate != null && newEndDate != null) {
        print('Fetching streams for range: $newStartDate to $newEndDate'); // Debug
        final streamsResult = await _getByDateRangeCategoryStreams.call(
          params: GetByDateRangeCategoryStreamsByIdParams(
            start: newStartDate,
            end: newEndDate,
            userId: userId,
            accessToken: accessToken,
          ),
        );

        streamsResult.fold(
              (failure) => emit(state.copyWith(hasError: true, isLoading: false)),
              (streams) {
            print('Received streams: $streams'); // Debug
            emit(
              state.copyWith(
                categoryStreams: streams,
                isLoading: false,
                selectedDate: null,
                startDate: newStartDate,
                endDate: newEndDate,
                hasFetchedInitialData: true,
              ),
            );
          },
        );
      }
    } catch (e) {
      emit(state.copyWith(hasError: true, isLoading: false));
      print('Exception in fetchStreams: $e');
    }
  }

  Future<void> fetchAnalysis({required String accessToken, required int userId}) async {
    if (isClosed) return;

    emit(state.copyWith(isLoading: true, hasError: false));

    try {
      String? aiAnalysis;

      if (state.filter == ReportFilter.singleDate && state.selectedDate != null) {
        final analysisResult = await _analyzeMoneyFlowByDate.call(
          params: ParamsDate(
            selectedDate: state.selectedDate!,
            accessToken: accessToken,
            userId: userId,
          ),
        );
        analysisResult.fold(
              (failure) {
            print('Analysis failed: ${failure.message}');
            emit(state.copyWith(isLoading: false, hasError: true));
          },
              (analysis) => aiAnalysis = analysis,
        );
      } else if (state.filter == ReportFilter.dateRange && state.startDate != null && state.endDate != null) {
        final analysisResult = await _analyzeMoneyFlowByDateRange.call(
          params: ParamsDateRange(
            startDate: state.startDate!,
            endDate: state.endDate!,
            accessToken: accessToken,
            userId: userId,
          ),
        );
        analysisResult.fold(
              (failure) {
            print('Analysis failed: ${failure.message}');
            emit(state.copyWith(isLoading: false, hasError: true));
          },
              (analysis) => aiAnalysis = analysis,
        );
      }

      if (aiAnalysis != null) {
        emit(state.copyWith(aiAnalysis: aiAnalysis, isLoading: false));
      }
    } catch (e) {
      emit(state.copyWith(hasError: true, isLoading: false));
      print('Exception in fetchAnalysis: $e');
    }
  }

  void updateFilter(ReportFilter filter) {
    if (isClosed) return;
    emit(state.copyWith(filter: filter, aiAnalysis: null));
  }

  void reset() {
    if (isClosed) return;
    emit(ReportsState(selectedDate: DateTime.now())); // Reset to today
    updateFilter(ReportFilter.singleDate);
  }

  @override
  Future<void> close() {
    return super.close();
  }
}