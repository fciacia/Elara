import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/sso_config.dart';

class SSOService {
  static final SSOService _instance = SSOService._internal();
  factory SSOService() => _instance;
  SSOService._internal();

  SSOConfig? _config;
  bool _isInitialized = false;

  // Initialize SSO configuration
  Future<void> initialize({
    required String hospitalId,
    String? samlEndpoint,
    String? oauthClientId,
    String? redirectUri,
  }) async {
    try {
      _config = SSOConfig(
        hospitalId: hospitalId,
        samlEndpoint: samlEndpoint ?? 'https://sso.hospital.my/saml/login',
        oauthClientId: oauthClientId ?? 'medical-ai-app',
        redirectUri: redirectUri ?? 'https://medical-ai.hospital.my/auth/callback',
        isEnabled: true,
      );
      _isInitialized = true;
      debugPrint('SSO Service initialized for hospital: $hospitalId');
    } catch (e) {
      debugPrint('SSO initialization failed: $e');
      _isInitialized = false;
    }
  }

  // Check if SSO is available and configured
  bool get isAvailable => _isInitialized && _config?.isEnabled == true;

  // Get current SSO configuration
  SSOConfig? get config => _config;

  // Initiate SSO login flow
  Future<SSOLoginResult> initiateLogin() async {
    if (!isAvailable || _config == null) {
      return SSOLoginResult.failure('SSO not configured');
    }

    try {
      // In a real implementation, this would redirect to the SSO provider
      // For demo purposes, we simulate a successful SSO flow
      debugPrint('Initiating SSO login to: ${_config!.samlEndpoint}');
      
      // Simulate SSO authentication delay
      await Future.delayed(const Duration(seconds: 2));
      
      // In demo mode, return success with mock token
      return SSOLoginResult.success(
        token: 'mock_sso_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock_refresh_token',
        expiresIn: 3600,
        userInfo: {
          'sub': '1',
          'email': 'sarah.ahmad@hospital.my',
          'name': 'Dr. Sarah Ahmad',
          'role': 'doctor',
          'hospital_id': _config!.hospitalId,
          'department': 'Cardiology',
        },
      );
    } catch (e) {
      debugPrint('SSO login failed: $e');
      return SSOLoginResult.failure('Authentication failed: ${e.toString()}');
    }
  }

  // Handle SSO callback (for web redirects)
  Future<SSOLoginResult> handleCallback(String callbackUrl) async {
    try {
      debugPrint('Handling SSO callback: $callbackUrl');
      
      // Parse callback URL for tokens/codes
      final uri = Uri.parse(callbackUrl);
      final code = uri.queryParameters['code'];
      final error = uri.queryParameters['error'];

      if (error != null) {
        return SSOLoginResult.failure('SSO error: $error');
      }

      if (code == null) {
        return SSOLoginResult.failure('No authorization code received');
      }

      // Exchange code for tokens (simulated)
      await Future.delayed(const Duration(milliseconds: 500));
      
      return SSOLoginResult.success(
        token: 'exchanged_token_$code',
        refreshToken: 'refresh_token_$code',
        expiresIn: 3600,
        userInfo: {
          'sub': '1',
          'email': 'sarah.ahmad@hospital.my',
          'name': 'Dr. Sarah Ahmad',
          'role': 'doctor',
        },
      );
    } catch (e) {
      return SSOLoginResult.failure('Callback handling failed: ${e.toString()}');
    }
  }

  // Refresh SSO token
  Future<SSOTokenRefreshResult> refreshToken(String refreshToken) async {
    try {
      debugPrint('Refreshing SSO token');
      
      // Simulate token refresh
      await Future.delayed(const Duration(milliseconds: 500));
      
      return SSOTokenRefreshResult.success(
        token: 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'new_refresh_token',
        expiresIn: 3600,
      );
    } catch (e) {
      return SSOTokenRefreshResult.failure('Token refresh failed: ${e.toString()}');
    }
  }

  // Logout from SSO
  Future<void> logout({String? token}) async {
    try {
      debugPrint('Logging out from SSO');
      
      if (_config?.samlEndpoint != null && token != null) {
        // In real implementation, call SSO logout endpoint
        debugPrint('Calling SSO logout endpoint');
      }
      
      // Simulate logout delay
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('SSO logout error: $e');
    }
  }

  // Get hospital-specific login URL
  String getLoginUrl({Map<String, String>? additionalParams}) {
    if (_config == null) return '';
    
    final params = <String, String>{
      'client_id': _config!.oauthClientId,
      'redirect_uri': _config!.redirectUri,
      'response_type': 'code',
      'scope': 'openid profile email',
      'state': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    
    if (additionalParams != null) {
      params.addAll(additionalParams);
    }
    
    final query = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    return '${_config!.samlEndpoint}?$query';
  }
}

// SSO Login Result Classes
class SSOLoginResult {
  final bool isSuccess;
  final String? token;
  final String? refreshToken;
  final int? expiresIn;
  final Map<String, dynamic>? userInfo;
  final String? error;

  SSOLoginResult._({
    required this.isSuccess,
    this.token,
    this.refreshToken,
    this.expiresIn,
    this.userInfo,
    this.error,
  });

  factory SSOLoginResult.success({
    required String token,
    required String refreshToken,
    required int expiresIn,
    Map<String, dynamic>? userInfo,
  }) {
    return SSOLoginResult._(
      isSuccess: true,
      token: token,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      userInfo: userInfo,
    );
  }

  factory SSOLoginResult.failure(String error) {
    return SSOLoginResult._(
      isSuccess: false,
      error: error,
    );
  }
}

class SSOTokenRefreshResult {
  final bool isSuccess;
  final String? token;
  final String? refreshToken;
  final int? expiresIn;
  final String? error;

  SSOTokenRefreshResult._({
    required this.isSuccess,
    this.token,
    this.refreshToken,
    this.expiresIn,
    this.error,
  });

  factory SSOTokenRefreshResult.success({
    required String token,
    required String refreshToken,
    required int expiresIn,
  }) {
    return SSOTokenRefreshResult._(
      isSuccess: true,
      token: token,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
    );
  }

  factory SSOTokenRefreshResult.failure(String error) {
    return SSOTokenRefreshResult._(
      isSuccess: false,
      error: error,
    );
  }
}
