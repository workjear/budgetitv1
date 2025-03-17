import 'package:budgeit/common/widgets/category.dart';
import 'package:budgeit/presentation/icons/bloc/icons_cubit.dart';
import 'package:budgeit/presentation/icons/bloc/icons_state.dart';
import 'package:budgeit/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../../core/config/themes/app_theme.dart';

class IconsPage extends StatelessWidget {
  final String collection;
  final int userId;
  final String accessToken;
  final int type;

  const IconsPage({
    super.key,
    this.collection = 'material-symbols',
    required this.userId,
    required this.accessToken,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final iconsCubit = sl<IconsCubit>();

    // Load icons only if in initial state
    if (iconsCubit.state is IconsInitial) {
      iconsCubit.loadIcons(collection);
    }

    return BlocProvider.value(
      value: iconsCubit,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          title: Text('Add Category', style: Theme.of(context).textTheme.titleLarge),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60.0),
            child: _SearchBar(),
          ),
        ),
        body: _IconsGridView(
          userId: userId,
          accessToken: accessToken,
          type: type,
          collection: collection,
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Icons',
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenWidth * 0.04,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
        ),
        onChanged: (query) => sl<IconsCubit>().searchIcons(query),
      ),
    );
  }
}

class _IconsGridView extends StatelessWidget {
  final int userId;
  final String accessToken;
  final int type;
  final String collection;

  const _IconsGridView({
    required this.userId,
    required this.accessToken,
    required this.type,
    required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocConsumer<IconsCubit, IconsState>(
      listener: (context, state) {
        if (state is IconsLoaded && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
          Navigator.pop(context, {
            'iconUrl': state.selectedIcon ?? '',
            'categoryName': '', // Name added via bottom sheet
          });
        } else if (state is IconsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is IconsLoading) {
          return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        } else if (state is IconsLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<IconsCubit>().loadIcons(collection);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                screenWidth * 0.04,
                screenWidth * 0.0125,
                screenWidth * 0.04,
                screenWidth * 0.04,
              ),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: (screenWidth / 100).floor().clamp(3, 5), // Responsive columns
                  crossAxisSpacing: screenWidth * 0.025,
                  mainAxisSpacing: screenWidth * 0.025,
                  childAspectRatio: 1.0,
                ),
                itemCount: state.filteredIcons.length,
                itemBuilder: (context, index) {
                  final iconName = state.filteredIcons[index];
                  final iconUrl = "https://api.iconify.design/material-symbols/$iconName.svg";
                  return _IconTile(
                    iconUrl: iconUrl,
                    onTap: () => _showCategoryBottomSheet(context, iconUrl),
                  );
                },
              ),
            ),
          );
        } else if (state is IconsError) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<IconsCubit>().loadIcons(collection);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - kToolbarHeight - 60, // Adjust for AppBar + search
                child: Center(
                  child: Text(
                    'Error: ${state.message}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          );
        }
        return Center(child: Text('Initializing...', style: Theme.of(context).textTheme.bodyMedium));
      },
    );
  }

  void _showCategoryBottomSheet(BuildContext context, String iconUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CategoryBottomSheet(iconUrl: iconUrl),
    ).then((result) {
      if (result != null) {
        final categoryName = result['categoryName'] as String;
        final iconName = iconUrl.split('/').last.replaceAll('.svg', '');
        sl<IconsCubit>().addCategory(
          userId: userId,
          name: categoryName,
          icon: iconName,
          accessToken: accessToken,
          type: type,
        );
      }
    });
  }
}

class _IconTile extends StatelessWidget {
  final String iconUrl;
  final VoidCallback onTap;

  const _IconTile({required this.iconUrl, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: Theme.of(context).colorScheme.surfaceVariant,
        child: Center(
          child: SvgPicture.network(
            iconUrl,
            width: 40,
            height: 40,
            color: AppTheme.primaryColor,
            placeholderBuilder: (context) => CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        ),
      ),
    );
  }
}