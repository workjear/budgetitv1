import 'package:budgeit/app_navigation.dart';
import 'package:budgeit/common/bloc/session/session_cubit.dart';
import 'package:budgeit/common/bloc/session/session_state.dart';
import 'package:budgeit/common/helper/navigation/app_navigator.dart';
import 'package:budgeit/core/config/assets/app_images.dart';
import 'package:budgeit/presentation/auth_page/page/signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasMinSplashTimePassed = false;
  bool _hasSessionChecked = false;
  SessionState? _sessionState;

  @override
  void initState() {
    super.initState();
    // Start loading the session
    context.read<SessionCubit>().loadTokens();

    // Set minimum splash duration
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _hasMinSplashTimePassed = true;
        });
        _navigateIfReady();
      }
    });
  }

  void _navigateIfReady() {
    if (_hasMinSplashTimePassed && _hasSessionChecked && _sessionState != null) {
      if (_sessionState is SessionAuthenticated) {
        AppNavigator.pushAndRemove(context, const AppNavigation());
      } else {
        AppNavigator.pushAndRemove(context, const SignInPage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<SessionCubit, SessionState>(
        listener: (context, state) {
          // Skip if state is still loading
          if (state is SessionLoading) return;

          if (mounted) {
            setState(() {
              _sessionState = state;
              _hasSessionChecked = true;
            });
            _navigateIfReady();
          }
        },
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  width: 200,
                  AppImages.logo,
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}