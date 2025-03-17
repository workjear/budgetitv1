import 'dart:async';
import 'package:budgeit/common/helper/message/Failure.dart';
import 'package:budgeit/data/auth/models/auth_response.dart';
import 'package:budgeit/domain/auth/repositories/auth.dart';
import 'package:budgeit/domain/auth/usecases/refresh_token.dart';
import 'package:budgeit/service_locator.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:logger/logger.dart';
import 'session_state.dart';

class SessionCubit extends Cubit<SessionState> with WidgetsBindingObserver {
  final RefreshTokenUseCase _refreshToken = sl<RefreshTokenUseCase>();
  final AuthRepository _authRepository = sl<AuthRepository>();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  Timer? _expirationTimer;
  Timer? _proactiveRefreshTimer;

  // Flags and state tracking
  bool _isRefreshing = false;
  bool _isInForeground = true;
  DateTime? _lastBackgroundTime;
  // Configuration constants
  static const _proactiveRefreshInterval = Duration(minutes: 5); // Refresh 5 min before expiry
  static const _tokenExpiryThreshold = Duration(minutes: 1); // Refresh if < 1 min left
  static const _maxBackgroundIdleTime = Duration(minutes: 15); // Logout after 15 min in background
  static const _backgroundExpiryGrace = Duration(minutes: 5);

  SessionCubit() : super(SessionInitial()) {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  /// Initialize session by loading tokens and device ID
  Future<void> _initialize() async {
    await loadTokens();
  }

  /// Load tokens from secure storage and determine initial state
  Future<void> loadTokens() async {
    try {
      emit(SessionLoading());
      final accessToken = await _storage.read(key: 'accessToken');
      final refreshToken = await _storage.read(key: 'refreshToken');

      if (accessToken == null || refreshToken == null) {
        _logger.i('No tokens found, initializing unauthenticated state');
        emit(SessionInitial());
        return;
      }

      // Check if token is expired or will expire soon
      if (_isTokenExpired(accessToken)) {
        _logger.i('Access token expired, attempting refresh');
        await refresh(refreshToken);
      } else {
        _startTokenManagement(accessToken, refreshToken);
        emit(SessionAuthenticated(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: _authRepository.mapToEntity(accessToken),
        ));
        _logger.i('Session restored successfully');
      }
    } catch (e) {
      _logger.e('Error loading tokens: $e');
      emit(SessionExpired('Failed to load session: $e'));
      await clearSession();
    }
  }

  /// Save new tokens to secure storage
  Future<void> saveTokens(AuthResponse response) async {
    try {
      await _storage.write(key: 'accessToken', value: response.accessToken);
      await _storage.write(key: 'refreshToken', value: response.refreshToken);

      await _storage.write( key: 'accessTokenExpiresAt',value: response.accessTokenExpiresAt);
      await _storage.write(key: 'refreshTokenExpiresAt', value: response.refreshTokenExpiresAt);

      _logger.i('Tokens saved successfully');
    } catch (e) {
      _logger.e('Error saving tokens: $e');
      throw Exception('Failed to save tokens');
    }
  }

  Future<void> refresh(String refreshToken, {int retries = 3}) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    int attempt = 0;

    while (attempt < retries) {
      try {
        final result = await _refreshToken.call(params: RefreshTokenParams(refreshToken: refreshToken));
        result.fold(
              (failure) => throw Exception(failure.message),
              (response) {
            saveTokens(response);
            _startTokenManagement(response.accessToken, response.refreshToken);
            emit(SessionAuthenticated(
              accessToken: response.accessToken,
              refreshToken: response.refreshToken,
              user: _authRepository.mapToEntity(response.accessToken),
            ));
          },
        );
        break; // Success, exit loop
      } catch (e) {
        attempt++;
        if (attempt == retries) {
          _logger.e('Refresh failed after $retries attempts: $e');
          emit(SessionExpired('Session expired: $e'));
          await clearSession();
        } else {
          await Future.delayed(Duration(seconds: 2 * attempt)); // Exponential backoff
        }
      }
    }
    _isRefreshing = false;
  }

  /// Manage token lifecycle with timers
  void _startTokenManagement(String accessToken, String refreshToken) {
    _cancelTimers();

    final expirationTime = JwtDecoder.getExpirationDate(accessToken);
    final timeToExpiry = expirationTime.difference(DateTime.now());

    if (timeToExpiry.inSeconds <= 0) {
      _logger.i('Token already expired, triggering refresh');
      refresh(refreshToken);
      return;
    }

    // Proactive refresh only in foreground
    if (_isInForeground && timeToExpiry > _proactiveRefreshInterval) {
      final proactiveRefreshTime = timeToExpiry - _proactiveRefreshInterval;
      _proactiveRefreshTimer = Timer(proactiveRefreshTime, () async {
        if (state is SessionAuthenticated && _isInForeground) {
          await refresh(refreshToken);
        }
      });
      _logger.i('Proactive refresh scheduled in ${proactiveRefreshTime.inMinutes} minutes');
    }

    // Expiration timer always runs as a fallback
    _expirationTimer = Timer(timeToExpiry, () async {
      if (state is SessionAuthenticated) {
        if (_isInForeground) {
          await refresh(refreshToken);
        } else {
          // Only expire session in background if more than grace period has passed
          final lastBackTime = _lastBackgroundTime;
          if (lastBackTime != null &&
              DateTime.now().difference(lastBackTime) > _backgroundExpiryGrace) {
            _logger.i('Token expired in background with grace period passed, logging out');
            await clearSession();
            emit(SessionExpired('Session expired in background'));
          } else {
            _logger.i('Token expired in background but within grace period, will refresh on resume');
          }
        }
      }
    });
    _logger.i('Expiration timer set for ${timeToExpiry.inMinutes} minutes');
  }



  /// Cancel all active timers
  void _cancelTimers() {
    _expirationTimer?.cancel();
    _proactiveRefreshTimer?.cancel();
    _expirationTimer = null;
    _proactiveRefreshTimer = null;
    _logger.i('Timers canceled');
  }

  /// Clear session data and reset state
  Future<void> clearSession() async {
    _cancelTimers();
    try {
      // Keep the device identifier but remove all auth tokens
      await _storage.delete(key: 'accessToken');
      await _storage.delete(key: 'refreshToken');
      await _storage.delete(key: 'accessTokenExpiresAt');
      await _storage.delete(key: 'refreshTokenExpiresAt');
      _logger.i('Session cleared');
    } catch (e) {
      _logger.i('Error clearing session: $e');
    }
    emit(SessionInitial());
  }

  void updateUserData({
    required String fullName,
    required String gender,
    required String birthdate,
  }) {
    if (state is SessionAuthenticated) {
      final currentState = state as SessionAuthenticated;
      final updatedUser = currentState.user.copyWith(
        fullName: fullName,
        gender: gender,
        birthdate: DateTime.parse(birthdate), // Assuming UserEntity accepts DateTime
      );
      emit(SessionAuthenticated(
        accessToken: currentState.accessToken,
        refreshToken: currentState.refreshToken,
        user: updatedUser,
      ));
      _logger.i('User data updated in session');
    }
  }

  /// Fetch protected data with token validation
  Future<Either<Failure, String>> getProtectedData() async {
    if (state is! SessionAuthenticated) return Left(Failure('Not authenticated'));

    final currentState = state as SessionAuthenticated;
    if (_shouldRefreshToken(currentState.accessToken)) {
      if (_isRefreshing) {
        await Future.doWhile(() => Future.delayed(Duration(milliseconds: 100)).then((_) => _isRefreshing));
      } else {
        await refresh(currentState.refreshToken);
      }
      if (state is SessionAuthenticated) {
        return await _authRepository.getProtectedData((state as SessionAuthenticated).accessToken);
      }
      return Left(Failure('Session expired during refresh'));
    }
    return await _authRepository.getProtectedData(currentState.accessToken);
  }
  /// Check if token needs refreshing
  bool _shouldRefreshToken(String token) {
    if (JwtDecoder.isExpired(token)) return true;
    final expirationTime = JwtDecoder.getExpirationDate(token);
    final timeToExpiry = expirationTime.difference(DateTime.now());
    return timeToExpiry < _tokenExpiryThreshold;
  }

  /// Check if token is expired
  bool _isTokenExpired(String token) {
    return JwtDecoder.isExpired(token);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (this.state is! SessionAuthenticated) return;
    final currentState = this.state as SessionAuthenticated;

    switch (state) {
      case AppLifecycleState.resumed:
        _isInForeground = true;
        final wasInBackground = _lastBackgroundTime != null;
        _lastBackgroundTime = null;

        if (wasInBackground) {
          _logger.i('App resumed from background');
          if (_shouldRefreshToken(currentState.accessToken)) {
            _logger.i('Token near expiry after resume, refreshing');
            refresh(currentState.refreshToken);
          } else {
            _startTokenManagement(currentState.accessToken, currentState.refreshToken);
          }
        }
        _logger.i('App resumed, session active');
        break;

      case AppLifecycleState.paused:
        _isInForeground = false;
        _lastBackgroundTime = DateTime.now();
        _proactiveRefreshTimer?.cancel();
        Timer(_maxBackgroundIdleTime, () async {
          if (!_isInForeground && state is SessionAuthenticated) {
            _logger.i('Max background idle time exceeded, logging out');
            await clearSession();
            emit(SessionExpired('Session expired due to inactivity'));
          }
        });
        break;

      case AppLifecycleState.inactive:
      // Transition state, no action needed
        break;

      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _isInForeground = false;
        _lastBackgroundTime = DateTime.now();
        _proactiveRefreshTimer?.cancel();

        // Don't immediately log out - let the expiration timer handle it
        // This helps keep the session when switching between apps
        _logger.i('App detached/hidden, monitoring session expiry');
        break;
    }
  }

  @override
  Future<void> close() {
    _cancelTimers();
    WidgetsBinding.instance.removeObserver(this);
    _logger.i('SessionCubit closed');
    return super.close();
  }
}