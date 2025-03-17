import 'dart:async';
import 'package:budgeit/common/bloc/session/session_cubit.dart';
import 'package:budgeit/common/bloc/session/session_state.dart';
import 'package:budgeit/common/helper/navigation/app_navigator.dart';
import 'package:budgeit/presentation/auth_page/page/signin.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityManager extends StatefulWidget {
  final Widget child;

  const ConnectivityManager({required this.child, super.key});

  @override
  _ConnectivityManagerState createState() => _ConnectivityManagerState();
}

class _ConnectivityManagerState extends State<ConnectivityManager> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final newConnectionStatus = results.isNotEmpty && !results.contains(ConnectivityResult.none);
      if (newConnectionStatus != _isConnected) {
        setState(() {
          _isConnected = newConnectionStatus;
        });
        if (_isConnected) {
          _handleReconnection();
        }
      }
    });
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      _isConnected = result.isNotEmpty && !result.contains(ConnectivityResult.none);
    });
  }

  Future<void> _handleReconnection() async {
    final sessionCubit = context.read<SessionCubit>();
    await sessionCubit.loadTokens();
    if (sessionCubit.state is! SessionAuthenticated && mounted) {
      // Delay navigation until the widget tree is fully built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (AppNavigator.navigatorKey.currentState != null) {
          AppNavigator.pushAndRemoveGlobally(const SignInPage());
        }
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_isConnected)
          NoInternetOverlay(onRetry: _checkConnectivity),
      ],
    );
  }
}

class NoInternetOverlay extends StatelessWidget {
  final VoidCallback? onRetry;

  const NoInternetOverlay({this.onRetry, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 10),
              const Text(
                'No Internet Connection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please check your connection and try again.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BF6D),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}