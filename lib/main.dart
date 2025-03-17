import 'package:budgeit/presentation/auth_page/bloc/department/department_cubit.dart';
import 'package:budgeit/presentation/splash/page/splash.dart';
import 'package:budgeit/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart'; // Import toastification
import 'app_navigation.dart';
import 'common/bloc/session/session_cubit.dart';
import 'common/helper/navigation/app_navigator.dart';
import 'common/widgets/connectivity.dart';
import 'core/config/themes/app_theme.dart';

void main() {
  setupServiceLocator();
  Get.put(NavigationController());
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ToastificationConfigProvider(
      config: const ToastificationConfig(
        animationDuration: Duration(milliseconds: 300),
        alignment: Alignment.topRight, // Default position for toasts
      ),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<SessionCubit>(create: (_) => sl<SessionCubit>()),
          BlocProvider<DepartmentCubit>(create: (_) => sl<DepartmentCubit>()),
        ],
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              title: 'BudgeIt',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              home: const SplashPage(),
              navigatorKey: AppNavigator.navigatorKey,
              builder: (context, child) {
                return ConnectivityManager(child: child ?? const SizedBox());
              },
            );
          },
        ),
      ),
    );
  }
}