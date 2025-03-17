import 'package:budgeit/domain/categorystream/usecase/delete_stream.dart';
import 'package:budgeit/service_locator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/categorystream/models/category_stream.dart';
import '../../../domain/categorystream/usecase/get_by_date_category_stream.dart';
import '../../../domain/categorystream/usecase/get_by_date_range_category_stream.dart';
import 'calendar_state.dart';

class CategoryStreamCubit extends Cubit<CategoryStreamState> {
  final GetByDateCategoryStreamsByIdUseCase _getStreamsUseCase;
  final GetByDateRangeCategoryStreamUseCase _getDateRangeStreamsUseCase;
  final DeleteStreamUseCase _deleteStreamUseCase;

  Map<DateTime, Map<String, double>> dateAmounts = {};
  DateTime? selectedDate;

  CategoryStreamCubit()
      : _getStreamsUseCase = sl<GetByDateCategoryStreamsByIdUseCase>(),
        _getDateRangeStreamsUseCase = sl<GetByDateRangeCategoryStreamUseCase>(),
        _deleteStreamUseCase = sl<DeleteStreamUseCase>(),
        super(CategoryStreamInitial());

  Future<void> deleteStream({
    required int userId,
    required int streamId,
    required String accessToken,
  }) async {
    if (isClosed) return;

    emit(CategoryStreamLoading());

    DateTime? streamDate;
    if (state is CategoryStreamLoaded) {
      final currentState = state as CategoryStreamLoaded;
      try {
        final streamToDelete = currentState.streams.firstWhere(
              (stream) => stream.categoryStreamId == streamId,
        );
        streamDate = DateTime(
          streamToDelete.createdDate.year,
          streamToDelete.createdDate.month,
          streamToDelete.createdDate.day,
        );
      } catch (e) {
        print('Stream not found in current state: $e');
      }
    }

    final result = await _deleteStreamUseCase.call(
      params: DeleteStreamParams(streamId: streamId, accessToken: accessToken),
    );

    await result.fold(
          (failure) async {
        emit(CategoryStreamError(failure.message));
      },
          (successMessage) async {
        final refreshDate = selectedDate ?? streamDate ?? DateTime.now();
        try {
          await refreshStreams(
            userId: userId,
            date: refreshDate,
            accessToken: accessToken,
          );

          if (streamDate != null) {
            await _clearDateAmountsIfEmpty(userId, streamDate, accessToken);
          }
        } catch (e) {
          emit(CategoryStreamError('Failed to refresh after deletion: $e'));
        }
      },
    );
  }

  Future<void> refreshStreams({
    required int userId,
    required DateTime date,
    required String accessToken,
  }) async {
    if (isClosed) return;

    emit(CategoryStreamLoading());

    final now = date;
    final firstDay = DateTime(now.year, now.month, 1);
    final lastDay = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final dailyResult = await _getStreamsUseCase.call(
      params: GetByDateCategoryStreamsByIdParams(
        userId: userId,
        date: date.toUtc().add(const Duration(hours: 8)),
        accessToken: accessToken,
      ),
    );

    final rangeResult = await _getDateRangeStreamsUseCase.call(
      params: GetByDateRangeCategoryStreamsByIdParams(
        userId: userId,
        start: firstDay.toUtc().add(const Duration(hours: 8)),
        end: lastDay.toUtc().add(const Duration(hours: 8)),
        accessToken: accessToken,
      ),
    );

    if (isClosed) return;

    dailyResult.fold(
          (failure) => emit(CategoryStreamError(failure.message)),
          (dailyStreams) {
        dailyStreams.sort((a, b) => b.createdDate.compareTo(a.createdDate));
        rangeResult.fold(
              (failure) => emit(CategoryStreamError(failure.message)),
              (rangeStreams) {
            _processDateRangeStreams(rangeStreams, firstDay, lastDay);
            emit(CategoryStreamLoaded(
              streams: dailyStreams,
              dateAmounts: dateAmounts,
              selectedDate: date,
              focusedDay: date, // Set focusedDay to the refreshed date
            ));
          },
        );
      },
    );
  }

  Future<void> _clearDateAmountsIfEmpty(
      int userId,
      DateTime date,
      String accessToken,
      ) async {
    final philippineDate = date.toUtc().add(const Duration(hours: 8));

    final result = await _getStreamsUseCase.call(
      params: GetByDateCategoryStreamsByIdParams(
        userId: userId,
        date: philippineDate,
        accessToken: accessToken,
      ),
    );

    result.fold(
          (failure) => print('Failed to check streams: ${failure.message}'),
          (streams) {
        if (streams.isEmpty) {
          final normalizedDate = DateTime(date.year, date.month, date.day);
          dateAmounts.remove(normalizedDate);

          if (state is CategoryStreamLoaded) {
            final currentState = state as CategoryStreamLoaded;
            emit(
              CategoryStreamLoaded(
                streams: currentState.streams,
                dateAmounts: dateAmounts,
                selectedDate: selectedDate,
                focusedDay: currentState.focusedDay, // Preserve focusedDay
              ),
            );
          }
        }
      },
    );
  }

  void clearDateAmounts() {
    dateAmounts.clear();

    if (state is CategoryStreamLoaded) {
      final currentState = state as CategoryStreamLoaded;
      emit(
        CategoryStreamLoaded(
          streams: currentState.streams,
          dateAmounts: dateAmounts,
          selectedDate: selectedDate,
          focusedDay: currentState.focusedDay, // Preserve focusedDay
        ),
      );
    }
  }

  Future<void> fetchCategoryStreams({
    required int userId,
    required DateTime date,
    required String accessToken,
    bool isRefresh = false,
  }) async {
    if (isClosed) return;

    if (!isRefresh) {
      emit(CategoryStreamLoading());
    }

    selectedDate = date;

    final philippineDate = date.toUtc().add(const Duration(hours: 8));

    final result = await _getStreamsUseCase.call(
      params: GetByDateCategoryStreamsByIdParams(
        userId: userId,
        date: philippineDate,
        accessToken: accessToken,
      ),
    );

    if (!isClosed) {
      emit(
        result.fold(
              (failure) => CategoryStreamError(failure.message),
              (streams) {
            streams.sort((a, b) => b.createdDate.compareTo(a.createdDate));
            final currentFocusedDay =
            state is CategoryStreamLoaded ? (state as CategoryStreamLoaded).focusedDay : date;
            return CategoryStreamLoaded(
              streams: streams,
              dateAmounts: dateAmounts,
              selectedDate: date,
              focusedDay: currentFocusedDay, // Preserve or set focusedDay
            );
          },
        ),
      );
    }
  }

  Future<void> fetchDateRangeStreams({
    required int userId,
    required DateTime start,
    required DateTime end,
    required String accessToken,
  }) async {
    if (isClosed) return;

    final philippineStart = start.toUtc().add(const Duration(hours: 8));
    final philippineEnd = end.toUtc().add(const Duration(hours: 8));

    final result = await _getDateRangeStreamsUseCase.call(
      params: GetByDateRangeCategoryStreamsByIdParams(
        userId: userId,
        start: philippineStart,
        end: philippineEnd,
        accessToken: accessToken,
      ),
    );

    if (isClosed) return;

    result.fold(
          (failure) {
        if (state is CategoryStreamLoaded) {
          final currentState = state as CategoryStreamLoaded;
          emit(
            CategoryStreamLoaded(
              streams: currentState.streams,
              dateAmounts: dateAmounts,
              selectedDate: selectedDate,
              focusedDay: currentState.focusedDay, // Preserve focusedDay
            ),
          );
        }
      },
          (streams) {
        _processDateRangeStreams(streams, start, end);
        if (state is CategoryStreamLoaded) {
          final currentState = state as CategoryStreamLoaded;
          emit(
            CategoryStreamLoaded(
              streams: currentState.streams,
              dateAmounts: dateAmounts,
              selectedDate: selectedDate,
              focusedDay: DateTime(start.year, start.month, 1), // Set to first day of the month
            ),
          );
        } else {
          emit(CategoryStreamLoaded(
            streams: [],
            dateAmounts: dateAmounts,
            selectedDate: selectedDate,
            focusedDay: DateTime(start.year, start.month, 1), // Set to first day of the month
          ));
        }
      },
    );
  }

  void _processDateRangeStreams(List<CategoryStream> streams, DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    dateAmounts.removeWhere((date, _) =>
    date.isAfter(startDate.subtract(const Duration(days: 1))) &&
        date.isBefore(endDate.add(const Duration(days: 1))));

    final groupedStreams = <DateTime, List<CategoryStream>>{};

    for (final stream in streams) {
      final date = DateTime(
        stream.createdDate.year,
        stream.createdDate.month,
        stream.createdDate.day,
      );

      if (!groupedStreams.containsKey(date)) {
        groupedStreams[date] = [];
      }
      groupedStreams[date]!.add(stream);
    }

    groupedStreams.forEach((date, dateStreams) {
      double income = dateStreams
          .where((stream) => stream.type == 2)
          .fold(0, (sum, stream) => sum + stream.stream);

      double expense = dateStreams
          .where((stream) => stream.type == 0 || stream.type == 1)
          .fold(0, (sum, stream) => sum + stream.stream.abs());

      dateAmounts[date] = {
        'income': income,
        'expense': expense,
      };
    });
  }
}