import 'package:budgeit/common/helper/navigation/app_navigator.dart';
import 'package:budgeit/common/widgets/add.dart';
import 'package:budgeit/presentation/icons/pages/icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../data/categories/models/category.dart';
import '../../core/config/themes/app_theme.dart';
import '../helper/toast/toast.dart';

class CategoryGridPage<T extends BlocBase<S>, S> extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final String successMessage;
  final T cubit;
  final String accessToken;
  final String userId;
  final int categoryType;
  final Future<void> Function(T, String, String) fetchCategories;
  final List<Category> Function(S) getCategories;
  final bool Function(S) isEditing;
  final void Function(T) toggleEditMode;
  final void Function(T, String) setSelectedCategory;
  final void Function(T, String, double, String) submitAction;
  final void Function(T, int, String, String) deleteAction;

  const CategoryGridPage({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.successMessage,
    required this.cubit,
    required this.accessToken,
    required this.userId,
    required this.categoryType,
    required this.fetchCategories,
    required this.getCategories,
    required this.isEditing,
    required this.toggleEditMode,
    required this.setSelectedCategory,
    required this.submitAction,
    required this.deleteAction,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: cubit,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          title: Text(title, style: Theme.of(context).textTheme.titleLarge),
          elevation: 2,
          actions: [
            BlocBuilder<T, S>(
              builder: (context, state) {
                if (getCategories(state).isNotEmpty) {
                  return IconButton(
                    icon: Icon(isEditing(state) ? Icons.done : Icons.edit),
                    onPressed: () => toggleEditMode(context.read<T>()),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          foregroundColor: AppTheme.primaryColor,
          onPressed: () => AppNavigator.push(
            context,
            IconsPage(
              userId: int.parse(userId),
              accessToken: accessToken,
              type: categoryType,
            ),
          ),
          child: const Icon(FontAwesomeIcons.plus),
        ),
        body: SafeArea(
          child: CategoryGridView(
            emptyMessage: emptyMessage,
            successMessage: successMessage,
            accessToken: accessToken,
            userId: userId,
            fetchCategories: fetchCategories,
            getCategories: getCategories,
            isEditing: isEditing,
            setSelectedCategory: setSelectedCategory,
            submitAction: submitAction,
            deleteAction: deleteAction,
          ),
        ),
      ),
    );
  }
}

class CategoryGridView<T extends BlocBase<S>, S> extends StatelessWidget {
  final String emptyMessage;
  final String successMessage;
  final String accessToken;
  final String userId;
  final Future<void> Function(T, String, String) fetchCategories;
  final List<Category> Function(S) getCategories;
  final bool Function(S) isEditing;
  final void Function(T, String) setSelectedCategory;
  final void Function(T, String, double, String) submitAction;
  final void Function(T, int, String, String) deleteAction;

  const CategoryGridView({
    super.key,
    required this.emptyMessage,
    required this.successMessage,
    required this.accessToken,
    required this.userId,
    required this.fetchCategories,
    required this.getCategories,
    required this.isEditing,
    required this.setSelectedCategory,
    required this.submitAction,
    required this.deleteAction,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: BlocConsumer<T, S>(
        listener: (context, state) {
          if (state is SuccessState) {
            ToastHelper.showSuccess(
              context: context,
              title: 'Success',
              description: successMessage,
            );
          }
        },
        builder: (context, state) {
          final categories = getCategories(state);
          final isLoading = state is LoadingState;

          return RefreshIndicator(
            onRefresh: () => fetchCategories(context.read<T>(), userId, accessToken),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Category',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.width * 0.04),
                  if (isLoading)
                    Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                  else if (state is ErrorState)
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 100,
                      child: Center(child: Text('Error: ${(state as ErrorState).message}', style: Theme.of(context).textTheme.bodyMedium)),
                    )
                  else if (categories.isEmpty)
                      SizedBox(
                        height: 200,
                        child: Center(child: Text(emptyMessage, style: Theme.of(context).textTheme.bodyMedium)),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: (MediaQuery.of(context).size.width / 100).floor().clamp(2, 4),
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return CategoryTile(
                            category: category,
                            isEditing: isEditing(state),
                            onTap: () => _handleTap(context, category.name),
                            onDelete: () => _showDeleteConfirmation(context, category),
                          );
                        },
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleTap(BuildContext context, String category) {
    if (!isEditing(context.read<T>().state)) {
      setSelectedCategory(context.read<T>(), category);
      _showBottomSheet(context, category);
    }
  }

  void _showBottomSheet(BuildContext context, String category) {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final cubit = context.read<T>();

    AddBottomSheet.show(
      context: context,
      category: category,
      descriptionController: descriptionController,
      amountController: amountController,
      cubit: cubit,
      onSubmit: (description, amount, _) =>
        submitAction(cubit, description, amount, accessToken),
      onCancel: () => setSelectedCategory(cubit, 'User Cancel'), // Fixed 'User Cancel' to null
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"? All related records will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteAction(context.read<T>(), category.categoriesId, accessToken, userId);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class CategoryTile extends StatelessWidget {
  final Category category;
  final bool isEditing;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CategoryTile({
    super.key,
    required this.category,
    required this.isEditing,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String iconUrl = "https://api.iconify.design/material-symbols/";
    final iconPath = category.icon != null && category.icon!.isNotEmpty ? category.icon : 'category';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Card(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  elevation: 1,
                  child: Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: SvgPicture.network(
                        '$iconUrl$iconPath.svg',
                        width: 30,
                        height: 30,
                        color: AppTheme.primaryColor,
                        fit: BoxFit.contain,
                        placeholderBuilder: (context) => CircularProgressIndicator(color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
                ),
                if (isEditing)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: onDelete,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Icon(Icons.close, size: 14, color: Theme.of(context).colorScheme.onError),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6),
          SizedBox(
            width: 80,
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

abstract class LoadingState {}

abstract class ErrorState {
  String get message;
}

abstract class SuccessState {
  String get message;
}