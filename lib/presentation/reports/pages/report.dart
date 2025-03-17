import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:budgeit/common/bloc/session/session_cubit.dart';
import 'package:budgeit/common/bloc/session/session_state.dart';
import 'package:budgeit/presentation/reports/bloc/reports_cubit.dart';
import 'package:budgeit/presentation/reports/bloc/reports_state.dart';
import '../../../data/categorystream/models/category_stream.dart';
import 'package:budgeit/core/enums/enums.dart';
import '../../../service_locator.dart';
import '../../auth_page/page/signin.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, sessionState) {
        if (sessionState is SessionAuthenticated) {
          return const ReportsView();
        } else if (sessionState is SessionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const SignInPage();
        }
      },
    );
  }
}

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionCubit, SessionState>(
      builder: (context, sessionState) {
        if (sessionState is SessionAuthenticated) {
          return ReportsContent(
            userId: int.parse(sessionState.user.id),
            accessToken: sessionState.accessToken,
          );
        } else if (sessionState is SessionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text('Please log in to view reports'));
        }
      },
    );
  }
}

class ReportsContent extends StatefulWidget {
  final int userId;
  final String accessToken;

  const ReportsContent({super.key, required this.userId, required this.accessToken});

  @override
  _ReportsContentState createState() => _ReportsContentState();
}

class _ReportsContentState extends State<ReportsContent> {
  bool _isAiLoading = false;

  final Color _incomeColor = Colors.green.shade600;
  final Color _expenseColor = Colors.red.shade600;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reportsCubit = context.read<ReportsCubit>();
      if (!reportsCubit.state.hasFetchedInitialData) {
        _fetchReport(context); // Fetch initial data if not already fetched
      }
    });
  }

  Color _getCategoryColor(int? type) {
    final categoryType = type != null ? CategoryType.fromValue(type) : CategoryType.personalExpense;
    return categoryType == CategoryType.income ? _incomeColor : _expenseColor;
  }

  String _getFilterLabel(ReportsState state) {
    if (state.filter == ReportFilter.singleDate && state.selectedDate != null) {
      return 'Date: ${DateFormat('MMMM dd, yyyy').format(state.selectedDate!)}';
    } else if (state.filter == ReportFilter.dateRange && state.startDate != null && state.endDate != null) {
      return 'Range: ${DateFormat('MMM dd, yyyy').format(state.startDate!)} - ${DateFormat('MMM dd, yyyy').format(state.endDate!)}';
    } else {
      return 'Not selected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        final filterLabel = _getFilterLabel(state); // Compute label here

        Map<String, String> sections = {};
        if (state.aiAnalysis != null && state.aiAnalysis!.isNotEmpty) {
          final parts = state.aiAnalysis!.split(RegExp(r'#{4,5}\s+'));
          for (var part in parts.skip(1)) {
            final lines = part.trim().split('\n');
            final heading = lines[0].trim();
            final content = lines.skip(1).join('\n').trim();
            sections[heading] = content;
          }
        }

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.isLoading && !_isAiLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (state.hasError)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading data',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextButton(
                              onPressed: () => _fetchReport(context),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Money Flow Summary',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.filter_list),
                                      onPressed: () => _showFilterDialog(context),
                                      constraints: const BoxConstraints(minWidth: 40),
                                    ),
                                    Flexible(
                                      child: Text(
                                        filterLabel,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 300,
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  barGroups: _buildBarGroups(state.categoryStreams),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index >= 0 && index < _getUniqueCategories(state.categoryStreams).length) {
                                            final category = _getUniqueCategories(state.categoryStreams)[index];
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                _shortenCategoryName(category),
                                                style: const TextStyle(fontSize: 10),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 60,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            '₱${value.toInt()}',
                                            style: const TextStyle(fontSize: 10),
                                          );
                                        },
                                      ),
                                    ),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: FlGridData(
                                    drawHorizontalLine: true,
                                    drawVerticalLine: false,
                                  ),
                                  borderData: FlBorderData(show: false),
                                  barTouchData: BarTouchData(
                                    enabled: true,
                                    touchTooltipData: BarTouchTooltipData(
                                      tooltipPadding: const EdgeInsets.all(8),
                                      tooltipMargin: 8,
                                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                        if (state.categoryStreams.isEmpty) return null;
                                        final category = _getUniqueCategories(state.categoryStreams)[group.x];
                                        final amount = rod.toY;
                                        final streamForCategory = state.categoryStreams.firstWhere(
                                              (s) => (s.categoryName ?? 'Unknown') == category,
                                          orElse: () => state.categoryStreams.first,
                                        );
                                        final isIncome = CategoryType.fromValue(streamForCategory.type ?? 0) == CategoryType.income;
                                        return BarTooltipItem(
                                          '$category\n${isIncome ? 'Income' : 'Expense'}: ₱${amount.toStringAsFixed(2)}',
                                          TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (state.categoryStreams.isNotEmpty)
                              Text(
                                'Categories',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            if (state.categoryStreams.isNotEmpty) const SizedBox(height: 12),
                            if (state.categoryStreams.isNotEmpty)
                              Card(
                                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                                elevation: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Wrap(
                                    spacing: 16,
                                    runSpacing: 12,
                                    children: _buildCategoryLegend(state.categoryStreams),
                                  ),
                                ),
                              ),
                            if (state.categoryStreams.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20.0),
                                child: Center(
                                  child: Text(
                                    'No data available for this filter',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'AI Analysis & Suggestions',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.auto_awesome, size: 24),
                                tooltip: 'Generate AI Analysis',
                                onPressed: () => _fetchAnalysis(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (sections.isNotEmpty) ...[
                            if (sections.containsKey('Bar Chart Interpretation')) ...[
                              Text(
                                'Bar Chart Interpretation',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              if (sections.containsKey('Interpretation')) ...[
                                Text(
                                  'Interpretation',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(sections['Interpretation']!, style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(height: 12),
                              ],
                              if (sections.containsKey('Total Income vs Total Expenses')) ...[
                                Text(
                                  'Total Income vs Total Expenses',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(sections['Total Income vs Total Expenses']!, style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(height: 12),
                              ],
                              if (sections.containsKey('Budget Usage')) ...[
                                Text(
                                  'Budget Usage',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(sections['Budget Usage']!, style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(height: 12),
                              ],
                              if (sections.containsKey('Unusual Patterns')) ...[
                                Text(
                                  'Unusual Patterns',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(sections['Unusual Patterns']!, style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(height: 16),
                              ],
                            ],
                            if (sections.containsKey('Financial Suggestions')) ...[
                              Text(
                                'Financial Suggestions',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              if (sections.containsKey('Category-Specific Insights')) ...[
                                Text(
                                  'Category-Specific Insights',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(sections['Category-Specific Insights']!, style: Theme.of(context).textTheme.bodyMedium),
                                const SizedBox(height: 12),
                              ],
                              if (sections.containsKey('Personalized Financial Advice')) ...[
                                Text(
                                  'Personalized Financial Advice',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(sections['Personalized Financial Advice']!, style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ],
                          ],
                          if (sections.isEmpty)
                            const Center(
                              child: Text(
                                'Generate AI analysis based on the selected filter',
                                textAlign: TextAlign.center,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_isAiLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'AI is thinking...',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<String> _getUniqueCategories(List<CategoryStream> streams) {
    final categories = <String>{};
    for (var stream in streams) {
      categories.add(stream.categoryName ?? 'Unknown');
    }
    return categories.toList();
  }

  String _shortenCategoryName(String name) {
    if (name.length <= 6) return name;
    return '${name.substring(0, 5)}...';
  }

  List<Widget> _buildCategoryLegend(List<CategoryStream> streams) {
    double incomeTotal = 0;
    double expenseTotal = 0;

    for (var stream in streams) {
      final categoryType = stream.type != null ? CategoryType.fromValue(stream.type!) : CategoryType.personalExpense;
      if (categoryType == CategoryType.income) {
        incomeTotal += stream.stream;
      } else {
        expenseTotal += stream.stream;
      }
    }

    return [
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _incomeColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Income',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(₱${incomeTotal.abs().toStringAsFixed(2)})',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: _expenseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Expense',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(₱${expenseTotal.abs().toStringAsFixed(2)})',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    ];
  }

  List<BarChartGroupData> _buildBarGroups(List<CategoryStream> streams) {
    final Map<String, double> totals = {};

    for (var stream in streams) {
      final category = stream.categoryName ?? 'Unknown';
      totals[category] = (totals[category] ?? 0) + stream.stream;
    }

    final categories = totals.keys.toList();

    return categories.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final value = totals[category]!;
      final streamForCategory = streams.firstWhere(
            (s) => (s.categoryName ?? 'Unknown') == category,
        orElse: () => streams.first,
      );
      final color = _getCategoryColor(streamForCategory.type);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value.abs(),
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            width: 20,
          ),
        ],
      );
    }).toList();
  }

  Future<void> _showFilterDialog(BuildContext context) async {
    final selectedOption = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Filter'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'Today'),
              child: const Text('Today'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'By Date'),
              child: const Text('By Date'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'By Date Range'),
              child: const Text('By Date Range'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'By Month'),
              child: const Text('By Month'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 'By Year'),
              child: const Text('By Year'),
            ),
          ],
        );
      },
    );

    if (selectedOption != null) {
      switch (selectedOption) {
        case 'Today':
          await _pickToday(context);
          break;
        case 'By Date':
          await _pickDate(context, isRange: false);
          break;
        case 'By Date Range':
          await _pickDateRange(context);
          break;
        case 'By Month':
          await _pickMonth(context);
          break;
        case 'By Year':
          await _pickYear(context);
          break;
      }
    }
  }

  Future<void> _pickToday(BuildContext context) async {
    final today = DateTime.now();
    context.read<ReportsCubit>().updateFilter(ReportFilter.singleDate);
    await context.read<ReportsCubit>().fetchStreams(
      selectedDate: today,
      accessToken: widget.accessToken,
      userId: widget.userId,
    );
  }

  Future<void> _pickDate(BuildContext context, {required bool isRange}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: context.read<ReportsCubit>().state.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      context.read<ReportsCubit>().updateFilter(ReportFilter.singleDate);
      await context.read<ReportsCubit>().fetchStreams(
        selectedDate: picked,
        accessToken: widget.accessToken,
        userId: widget.userId,
      );
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final now = DateTime.now();
    final lastAllowedDate = DateTime(now.year, now.month, now.day); // Midnight of current day

    // Use current date as default end, and 7 days prior as default start, but only for initial display
    final defaultStart = now.subtract(const Duration(days: 7));
    final defaultEnd = now;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: lastAllowedDate,
      initialDateRange: DateTimeRange(
        start: context.read<ReportsCubit>().state.startDate ?? defaultStart,
        end: context.read<ReportsCubit>().state.endDate ?? defaultEnd,
      ),
    );

    if (picked != null) {
      context.read<ReportsCubit>().updateFilter(ReportFilter.dateRange);
      // Use exact picked dates, adjusted for full day inclusion
      final adjustedStart = DateTime(
        picked.start.year,
        picked.start.month,
        picked.start.day,
        0,
        0,
        0,
      );
      final adjustedEnd = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
      );

      print('Sending to API: start=$adjustedStart, end=$adjustedEnd'); // Debug
      await context.read<ReportsCubit>().fetchStreams(
        startDate: adjustedStart,
        endDate: adjustedEnd,
        accessToken: widget.accessToken,
        userId: widget.userId,
      );
    }
  }

  Future<void> _pickMonth(BuildContext context) async {
    final DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: DateTime.now(), // Use current date instead of state
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final startOfMonth = DateTime(picked.year, picked.month, 1);
      // Include full last day of month
      final endOfMonth = DateTime(picked.year, picked.month + 1, 0, 23, 59, 59);
      context.read<ReportsCubit>().updateFilter(ReportFilter.dateRange);
      await context.read<ReportsCubit>().fetchStreams(
        startDate: startOfMonth,
        endDate: endOfMonth,
        accessToken: widget.accessToken,
        userId: widget.userId,
      );
    }
  }

  Future<void> _pickYear(BuildContext context) async {
    final int? pickedYear = await showDialog<int>(
      context: context,
      builder: (context) => YearPickerDialog(
        initialYear: DateTime.now().year,
        firstYear: 2020,
        lastYear: 2030,
      ),
    );
    if (pickedYear != null) {
      final startOfYear = DateTime(pickedYear, 1, 1);
      final endOfYear = DateTime(pickedYear, 12, 31);
      context.read<ReportsCubit>().updateFilter(ReportFilter.dateRange);
      await context.read<ReportsCubit>().fetchStreams(
        startDate: startOfYear,
        endDate: endOfYear,
        accessToken: widget.accessToken,
        userId: widget.userId,
      );
    }
  }

  Future<void> _fetchReport(BuildContext context) async {
    setState(() {
      _isAiLoading = true;
    });
    await context.read<ReportsCubit>().fetchStreams(
      selectedDate: context.read<ReportsCubit>().state.selectedDate,
      startDate: context.read<ReportsCubit>().state.startDate,
      endDate: context.read<ReportsCubit>().state.endDate,
      accessToken: widget.accessToken,
      userId: widget.userId,
    );
    setState(() {
      _isAiLoading = false;
    });
  }

  Future<void> _fetchAnalysis(BuildContext context) async {
    setState(() {
      _isAiLoading = true;
    });
    await context.read<ReportsCubit>().fetchAnalysis(
      accessToken: widget.accessToken,
      userId: widget.userId,
    );
    setState(() {
      _isAiLoading = false;
    });
  }
}

class YearPickerDialog extends StatelessWidget {
  final int initialYear;
  final int firstYear;
  final int lastYear;

  const YearPickerDialog({
    super.key,
    required this.initialYear,
    required this.firstYear,
    required this.lastYear,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Year'),
      content: SizedBox(
        width: 300,
        height: 300,
        child: YearPicker(
          firstDate: DateTime(firstYear),
          lastDate: DateTime(lastYear),
          initialDate: DateTime(initialYear),
          selectedDate: DateTime(initialYear),
          onChanged: (DateTime dateTime) {
            Navigator.pop(context, dateTime.year);
          },
        ),
      ),
    );
  }
}

Future<DateTimeRange?> showMonthRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
}) async {
  DateTime? startMonth;
  DateTime? endMonth;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select Month Range'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () async {
              final picked = await showMonthPicker(
                context: context,
                initialDate: initialDateRange?.start ?? DateTime.now(),
                firstDate: firstDate,
                lastDate: lastDate,
              );
              if (picked != null) startMonth = picked;
            },
            child: const Text('Start Month'),
          ),
          ElevatedButton(
            onPressed: () async {
              final picked = await showMonthPicker(
                context: context,
                initialDate: initialDateRange?.end ?? DateTime.now(),
                firstDate: firstDate,
                lastDate: lastDate,
              );
              if (picked != null) endMonth = picked;
            },
            child: const Text('End Month'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (startMonth != null && endMonth != null) {
              Navigator.pop(context);
            }
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );

  if (startMonth != null && endMonth != null) {
    return DateTimeRange(start: startMonth!, end: endMonth!);
  }
  return null;
}

Future<DateTime?> showMonthPicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  return await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    initialEntryMode: DatePickerEntryMode.calendar,
    builder: (context, child) {
      return MonthPicker(child: child!);
    },
  );
}

class MonthPicker extends StatelessWidget {
  final Widget child;

  const MonthPicker({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        datePickerTheme: DatePickerThemeData(
          headerHeadlineStyle: const TextStyle(fontSize: 0), // Hides day
          headerHelpStyle: const TextStyle(fontSize: 0), // Hides year
          dayStyle: const TextStyle(fontSize: 0), // Hides days
        ),
      ),
      child: child,
    );
  }
}