import 'package:budgeit/common/bloc/session/session_cubit.dart';
import 'package:budgeit/common/bloc/session/session_state.dart';
import 'package:budgeit/common/helper/navigation/app_navigator.dart';
import 'package:budgeit/core/config/assets/app_images.dart';
import 'package:budgeit/presentation/auth_page/bloc/auth/auth_cubit.dart';
import 'package:budgeit/presentation/auth_page/page/signin.dart';
import 'package:budgeit/presentation/budget/bloc/budget/budget_cubit.dart';
import 'package:budgeit/presentation/budget/bloc/setBudget/set_budget_cubit.dart';
import 'package:budgeit/presentation/budget/page/budget.dart';
import 'package:budgeit/presentation/budget/page/setBudget.dart';
import 'package:budgeit/presentation/calendar/bloc/calendar_cubit.dart';
import 'package:budgeit/presentation/calendar/pages/calendar.dart';
import 'package:budgeit/presentation/categories/pages/educational_expense.dart';
import 'package:budgeit/presentation/categories/pages/income.dart';
import 'package:budgeit/presentation/categories/pages/personal_expense.dart';
import 'package:budgeit/presentation/profile/page/profile.dart';
import 'package:budgeit/presentation/reports/bloc/reports_cubit.dart';
import 'package:budgeit/presentation/reports/pages/report.dart';
import 'package:budgeit/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'core/config/themes/app_theme.dart';

class AppNavigation extends StatelessWidget {
  const AppNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: AppNavigator.canPop(context),
      onPopInvokedWithResult: (bool didPop, Object? result) {
        debugPrint('Pop invoked, didPop: $didPop');
        if (!didPop && AppNavigator.canPop(context)) {
          AppNavigator.pop(context);
        }
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => sl<SessionCubit>()..loadTokens()),
          BlocProvider(create: (context) => sl<CategoryStreamCubit>()),
          BlocProvider(create: (context) => sl<BudgetCubit>()),
          BlocProvider(create: (context) => sl<ReportsCubit>()),
          BlocProvider(create: (context) => sl<SetBudgetCubit>())
        ],
        child: BlocListener<SessionCubit, SessionState>(
          listener: (context, state) {
            if (state is SessionExpired) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              AppNavigator.pushAndRemove(context, const SignInPage());
            }
          },
          child: BlocBuilder<SessionCubit, SessionState>(
            builder: (context, state) {
              debugPrint('SessionCubit state: $state');
              if (state is SessionAuthenticated) {
                return const AppNavigationView();
              } else if (state is SessionLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else {
                if (state is SessionExpired || state is SessionInitial) {
                  return const SignInPage();
                }
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class AppNavigationView extends StatelessWidget {
  const AppNavigationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Builder(
        builder: (context) => const ActionButtons(), // Use a new context inside MultiBlocProvider
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
      body: SafeArea(
        child: Obx(
              () => Get.find<NavigationController>()
              .screen[Get.find<NavigationController>().selectedIndex.value],
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      automaticallyImplyLeading: false,
      elevation: 2,
      flexibleSpace: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 70,  // Size of the image container
                height: 70, // Size of the image container
                child: ClipRRect(
                  child: Image.asset(
                    AppImages.icon,
                    fit: BoxFit.contain,  // BoxFit.cover ensures the image covers the area without stretching
                  ),
                ),
              ),

              const SizedBox(width: 5),
              BlocBuilder<SessionCubit, SessionState>(
                builder: (context, state) {
                  return Text(
                    state is SessionAuthenticated ? state.user.fullName : 'Guest',
                    style: Theme.of(context).textTheme.bodyLarge,
                  );
                },
              ),
              const Spacer(),
              IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.brightness_7 : Icons.brightness_4),
                onPressed: themeProvider.toggleTheme,
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.005),
              PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
                onSelected: (value) {
                  final sessionState = context.read<SessionCubit>().state;
                  if (sessionState is! SessionAuthenticated) return;

                  switch (value) {
                    case 'Profile':
                      AppNavigator.push(
                        context,
                        ProfilePage(accessToken: sessionState.accessToken, userData: sessionState.user,),
                      );
                      break;
                    case 'Logout':
                      sl<AuthCubit>().logout();
                      sl<SessionCubit>().clearSession();
                      AppNavigator.pushAndRemove(context, const SignInPage());
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Profile',
                    child: Text('Profile'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Logout',
                    child: Text('Logout'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavigationController>();
    return Obx(() {
      final isOnBudgetPage = navController.selectedIndex.value == 1;

      return BlocBuilder<SessionCubit, SessionState>(
        builder: (context, state) {
          if (state is! SessionAuthenticated) return const SizedBox.shrink();

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isOnBudgetPage)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: FloatingActionButton(
                    heroTag: 'budgetActionButton',
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: AppTheme.primaryColor,
                    child: Icon(MdiIcons.fileDocumentEdit),
                    onPressed: () {
                      AppNavigator.push(
                        context, // This context is now inside MultiBlocProvider
                        SetBudgetPage(
                          accessToken: state.accessToken,
                          userId: state.user.id,
                        ),
                      );
                    },
                  ),
                ),
              SpeedDial(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                foregroundColor: AppTheme.primaryColor,
                animatedIcon: AnimatedIcons.add_event,
                children: [
                  SpeedDialChild(
                    child: Icon(MdiIcons.school, color: AppTheme.primaryColor),
                    labelBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    label: 'Educational Expense',
                    onTap: () => _handleNavigation(
                      context,
                      EducationalExpense(
                        accessToken: state.accessToken,
                        userId: state.user.id,
                      ),
                    ),
                  ),
                  SpeedDialChild(
                    child: Icon(MdiIcons.bagPersonal, color: AppTheme.primaryColor),
                    labelBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    label: 'Personal Expense',
                    onTap: () => _handleNavigation(
                      context,
                      PersonalExpense(
                        accessToken: state.accessToken,
                        userId: state.user.id,
                      ),
                    ),
                  ),
                  SpeedDialChild(
                    child: Icon(MdiIcons.cashPlus, color: AppTheme.primaryColor),
                    labelBackgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    label: 'Income',
                    onTap: () => _handleNavigation(
                      context,
                      AddIncome(
                        accessToken: state.accessToken,
                        userId: state.user.id,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    });
  }

  void _handleNavigation(BuildContext context, Widget page) {
    AppNavigator.push(context, page);
  }
}

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.find<NavigationController>();

    return Obx(
          () => NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        indicatorColor: AppTheme.primaryColor,
        height: 80,
        elevation: 0,
        selectedIndex: navController.selectedIndex.value,
        onDestinationSelected: (i) => navController.selectedIndex.value = i,
        destinations: [
          NavigationDestination(icon: Icon(MdiIcons.calendar), label: 'Calendar'),
          NavigationDestination(icon: Icon(MdiIcons.file), label: 'Budget'),
          NavigationDestination(icon: Icon(MdiIcons.chartBar), label: 'Reports'),
        ],
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screen = [
    const CalendarPage(),
    const BudgetPage(),
    const ReportsPage(),
  ];
}