import 'package:budgeit/common/bloc/session/session_cubit.dart';
import 'package:budgeit/common/bloc/session/session_state.dart';
import 'package:budgeit/common/helper/navigation/app_navigator.dart';
import 'package:budgeit/presentation/streams/pages/streams.dart';
import 'package:budgeit/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/config/themes/app_theme.dart';
import '../bloc/calendar_cubit.dart';
import '../bloc/calendar_state.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, sessionState) {
        if (sessionState is SessionAuthenticated) {
          final String userId = sessionState.user.id;
          final accessToken = sessionState.accessToken;
          final int id = int.tryParse(userId) ?? 0;

          // Fetch initial data
          final cubit = sl<CategoryStreamCubit>();
          final now = DateTime.now();
          final currentState = cubit.state;

          if (currentState is! CategoryStreamLoaded || currentState.streams.isEmpty) {
            cubit.refreshStreams(
              userId: id,
              date: now,
              accessToken: accessToken,
            );
          }

          return CalendarView(userId: id, accessToken: accessToken);
        } else if (sessionState is SessionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text('Please log in to view calendar'));
        }
      },
    );
  }
}

class CalendarView extends StatelessWidget {
  final int userId;
  final String accessToken;

  const CalendarView({super.key, required this.userId, required this.accessToken});

  Future<void> _handleRefresh(BuildContext context) async {
    final cubit = context.read<CategoryStreamCubit>();
    final currentState = cubit.state;
    DateTime currentDate = DateTime.now();

    // If we have a loaded state with streams, use the date from the first stream
    if (currentState is CategoryStreamLoaded && currentState.streams.isNotEmpty) {
      currentDate = currentState.streams.first.createdDate;
    }
    // If we have a selected date, use that instead
    else if (currentState is CategoryStreamLoaded && currentState.selectedDate != null) {
      currentDate = currentState.selectedDate!;
    }

    await cubit.refreshStreams(
      userId: userId,
      date: currentDate,
      accessToken: accessToken,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        OverviewSection(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _handleRefresh(context),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  CalendarSection(userId: userId, accessToken: accessToken),
                  StreamListSection(userId: userId, accessToken: accessToken),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryStreamCubit, CategoryStreamState>(
      builder: (context, state) {
        if (state is CategoryStreamLoaded) {
          double totalIncome = state.streams.where((stream) => stream.type == 2).fold(0, (sum, stream) => sum + stream.stream);
          double totalExpense = state.streams.where((stream) => stream.type == 0 || stream.type == 1).fold(0, (sum, stream) => sum + stream.stream.abs());

          return Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Income', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(symbol: '₱').format(totalIncome),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text('Expense', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      NumberFormat.currency(symbol: '₱').format(totalExpense),
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
          margin: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: 8),
          child: Text('Loading overview...', style: Theme.of(context).textTheme.bodyMedium),
        );
      },
    );
  }
}

class CalendarSection extends StatelessWidget {
  final int userId;
  final String accessToken;

  const CalendarSection({super.key, required this.userId, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<CategoryStreamCubit, CategoryStreamState>(
      builder: (context, streamState) {
        DateTime? selectedDate = streamState is CategoryStreamLoaded ? streamState.selectedDate : null;
        DateTime focusedDay = streamState is CategoryStreamLoaded ? streamState.focusedDay : DateTime.now();
        Map<DateTime, Map<String, double>> dateAmounts =
        streamState is CategoryStreamLoaded ? streamState.dateAmounts : {};

        return Container(
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: focusedDay, // Use the cubit’s focusedDay
            calendarFormat: CalendarFormat.month,
            rowHeight: 70,
            headerStyle: HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              leftChevronIcon: Icon(Icons.chevron_left, color: AppTheme.primaryColor),
              rightChevronIcon: Icon(Icons.chevron_right, color: AppTheme.primaryColor),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              weekendStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
            onDaySelected: (selectedDay, newFocusedDay) {
              context.read<CategoryStreamCubit>().fetchCategoryStreams(
                userId: userId,
                date: selectedDay,
                accessToken: accessToken,
              );
            },
            onPageChanged: (newFocusedDay) {
              final firstDay = DateTime(newFocusedDay.year, newFocusedDay.month, 1);
              final lastDay = DateTime(newFocusedDay.year, newFocusedDay.month + 1, 0, 23, 59, 59);
              context.read<CategoryStreamCubit>().fetchDateRangeStreams(
                userId: userId,
                start: firstDay,
                end: lastDay,
                accessToken: accessToken,
              );
            },
            selectedDayPredicate: (day) => selectedDate != null && isSameDay(day, selectedDate),
            calendarStyle: CalendarStyle(
              cellMargin: const EdgeInsets.all(6),
              defaultDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.5), width: 1),
              ),
              weekendDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1),
              ),
              outsideDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.3), width: 1),
              ),
              selectedDecoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              todayDecoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5), width: 1),
              ),
              defaultTextStyle:
              Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
              weekendTextStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.w600, color: Colors.redAccent),
              selectedTextStyle:
              Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
              todayTextStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final normalizedDay = DateTime(date.year, date.month, date.day);
                final amounts = dateAmounts[normalizedDay] ?? {'income': 0.0, 'expense': 0.0};
                final income = amounts['income'] ?? 0.0;
                final expense = amounts['expense'] ?? 0.0;

                if (income <= 0 && expense <= 0) return null;

                return Positioned(
                  bottom: 2,
                  left: 2,
                  right: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (income > 0) _buildAmountMarker(context, income, AppTheme.primaryColor),
                      if (expense > 0) _buildAmountMarker(context, expense, Colors.redAccent),
                    ],
                  ),
                );
              },
              defaultBuilder: (context, day, focusedDay) {
                return Center(
                  child: Text(
                    '${day.day}',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
                  ),
                );
              },
              todayBuilder: (context, day, focusedDay) {
                return Center(
                  child: Text(
                    '${day.day}',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
              selectedBuilder: (context, day, focusedDay) {
                return Center(
                  child: Text(
                    '${day.day}',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountMarker(BuildContext context, double amount, Color color) {
    return Text(
      amount >= 1000 ? '₱${(amount / 1000).toStringAsFixed(1)}K' : '₱${amount.toStringAsFixed(0)}',
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      ),
    );
  }
}

class StreamListSection extends StatelessWidget {
  final int userId;
  final String accessToken;

  const StreamListSection({super.key, required this.userId, required this.accessToken});

  @override
  Widget build(BuildContext context) {
    final String iconUrl = "https://api.iconify.design/material-symbols/";
    final ValueNotifier<bool> isEditMode = ValueNotifier(false);

    return BlocBuilder<CategoryStreamCubit, CategoryStreamState>(
      builder: (context, state) {
        if (state is CategoryStreamLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is CategoryStreamError) {
          return Center(child: Text(state.message, style: Theme.of(context).textTheme.bodyMedium));
        }
        if (state is CategoryStreamLoaded && state.streams.isEmpty) {
          return Center(child: Text('No streams for this date', style: Theme.of(context).textTheme.bodyMedium));
        }
        if (state is CategoryStreamLoaded) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.04, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Day', style: Theme.of(context).textTheme.titleLarge),
                    ValueListenableBuilder<bool>(
                      valueListenable: isEditMode,
                      builder: (context, editMode, _) => IconButton(
                        icon: Icon(editMode ? Icons.check : Icons.edit, color: editMode ? AppTheme.primaryColor : Colors.grey),
                        onPressed: () => isEditMode.value = !isEditMode.value,
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.streams.length,
                  itemBuilder: (context, index) {
                    final stream = state.streams[index];
                    return StreamTile(
                      stream: stream,
                      userId: userId,
                      accessToken: accessToken,
                      isEditMode: isEditMode,
                    );
                  },
                ),
              ],
            ),
          );
        }
        return Center(child: Text('Select a date to load streams', style: Theme.of(context).textTheme.bodyMedium));
      },
    );
  }
}

class StreamTile extends StatelessWidget {
  final dynamic stream; // Adjust type based on your model
  final int userId;
  final String accessToken;
  final ValueNotifier<bool> isEditMode;

  const StreamTile({super.key, required this.stream, required this.userId, required this.accessToken, required this.isEditMode});

  @override
  Widget build(BuildContext context) {
    final String iconUrl = "https://api.iconify.design/material-symbols/";
    final isIncome = stream.type == 2;
    final amount = stream.stream.abs();

    return ValueListenableBuilder<bool>(
      valueListenable: isEditMode,
      builder: (context, editMode, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.only(bottom: 8),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: isIncome ? AppTheme.primaryColor.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                child: SvgPicture.network(
                  stream.categoryIcon != null ? '$iconUrl${stream.categoryIcon}.svg' : '${iconUrl}category.svg',
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(isIncome ? AppTheme.primaryColor : Colors.red, BlendMode.srcIn),
                  placeholderBuilder: (context) => const CircularProgressIndicator(),
                ),
              ),
              title: Text(stream.categoryName ?? 'Unknown', style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (stream.notes != null)
                      Text('Notes: ${stream.notes}', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(
                      'Created: ${DateFormat('MMM d, yyyy HH:mm').format(stream.createdDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              trailing: editMode
                  ? IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _handleDelete(context, stream.categoryStreamId),
              )
                  : Text(
                '₱${amount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: isIncome ? AppTheme.primaryColor : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: editMode
                  ? () => AppNavigator.push(context, StreamViewPage(
                streamId: stream.categoryStreamId,
                initialStream: stream.stream,
                initialNotes: stream.notes ?? '',
                accessToken: accessToken,
              ))
                  : null,
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleDelete(BuildContext context, int streamId) async {
    if (streamId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid stream ID')));
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete "${stream.categoryName ?? 'Unknown'}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      sl<CategoryStreamCubit>().deleteStream(userId: userId, streamId: streamId, accessToken: accessToken);
    }
  }
}