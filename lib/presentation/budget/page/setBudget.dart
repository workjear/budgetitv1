import 'package:budgeit/core/enums/enums.dart';
import 'package:budgeit/data/categories/models/category.dart';
import 'package:budgeit/domain/categories/usecase/get_category_by_id.dart';
import 'package:budgeit/presentation/budget/bloc/budget/budget_cubit.dart';
import 'package:budgeit/presentation/budget/bloc/setBudget/set_budget_cubit.dart';
import 'package:budgeit/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../common/widgets/addbudget.dart';
import '../../../core/config/themes/app_theme.dart';
import '../../../domain/budget/usecase/setBudget.dart';

class SetBudgetPage extends StatefulWidget {
  final String accessToken;
  final String userId;

  const SetBudgetPage({
    super.key,
    required this.accessToken,
    required this.userId,
  });

  @override
  State<SetBudgetPage> createState() => _SetBudgetPageState();
}

class _SetBudgetPageState extends State<SetBudgetPage> {
  late final GetCategoriesByIdUseCase _getCategoriesUseCase;
  List<Category> personalCategories = [];
  List<Category> educationalCategories = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _getCategoriesUseCase = sl<GetCategoriesByIdUseCase>();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final result = await _getCategoriesUseCase(
      params: GetCategoriesByIdParams(
        userId: int.tryParse(widget.userId) ?? 0,
        accessToken: widget.accessToken,
      ),
    );

    result.fold(
          (failure) => setState(() {
        errorMessage = failure.message;
        isLoading = false;
      }),
          (categories) => setState(() {
        personalCategories = categories
            .where((cat) => cat.type == CategoryType.personalExpense)
            .toList();
        educationalCategories = categories
            .where((cat) => cat.type == CategoryType.educationalExpense)
            .toList();
        isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      create: (_) => SetBudgetCubit(
        budgetCubit: context.read<BudgetCubit>(),
        setBudgetUseCase: sl<SetBudgetUseCase>(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Set Budget',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          centerTitle: true,
        ),
        body: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              const TabBar(
                tabs: [
                  Tab(text: 'Personal'),
                  Tab(text: 'Educational'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildCategoryGrid(context, personalCategories),
                    _buildCategoryGrid(context, educationalCategories),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<Category> categories) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[400],
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $errorMessage',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchCategories,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No categories available',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchCategories,
      color: Theme.of(context).primaryColor,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
          childAspectRatio: 0.8,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];

          return GestureDetector(
            onTap: () => _showBudgetBottomSheet(context, category),
            child: Column(
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: SvgPicture.network(
                          'https://api.iconify.design/material-symbols/${category.icon}.svg',
                          width: 32,
                          height: 32,
                          color: AppTheme.primaryColor,
                          placeholderBuilder: (context) => CircularProgressIndicator(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  category.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Set Budget',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBudgetBottomSheet(BuildContext context, Category category) {
    final setBudgetCubit = sl<SetBudgetCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlocProvider.value(
          value: setBudgetCubit,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.only(top: 8),
            child: BudgetBottomSheet(
              category: category,
              accessToken: widget.accessToken,
              userId: widget.userId,
            ),
          ),
        );
      },
    );
  }

}