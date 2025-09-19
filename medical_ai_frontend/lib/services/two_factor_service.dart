import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

class TwoFactorService {
  static final TwoFactorService _instance = TwoFactorService._internal();
  factory TwoFactorService() => _instance;
  TwoFactorService._internal();

  final Map<String, TwoFactorSession> _sessions = {};
  final Map<String, List<String>> _backupCodes = {};

  // Generate and send OTP via SMS
  Future<TwoFactorResult> sendSMSOTP({
    required String userId,
    required String phoneNumber,
  }) async {
    try {
      // Generate 6-digit OTP
      final otp = _generateOTP();
      
      // Create session
      final session = TwoFactorSession(
        userId: userId,
        method: TwoFactorMethod.sms,
        otp: otp,
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        attempts: 0,
        maxAttempts: 3,
      );
      
      _sessions[userId] = session;
      
      // Simulate SMS sending delay
      await Future.delayed(const Duration(seconds: 1));
      
      // In demo mode, we'll print the OTP to console
      debugPrint('SMS OTP sent to $phoneNumber: $otp');
      
      return TwoFactorResult.success(
        message: 'OTP telah dihantar ke $phoneNumber',
        sessionId: userId,
      );
    } catch (e) {
      debugPrint('SMS OTP sending failed: $e');
      return TwoFactorResult.failure('Failed to send SMS: ${e.toString()}');
    }
  }

  // Generate TOTP QR code for authenticator apps
  Future<TwoFactorSetupResult> setupTOTP({
    required String userId,
    required String userEmail,
    String? issuer,
  }) async {
    try {
      // Generate secret key for TOTP
      final secret = _generateTOTPSecret();
      
      // Create TOTP URI for QR code
      final uri = _generateTOTPUri(
        secret: secret,
        userEmail: userEmail,
        issuer: issuer ?? 'Medical AI System',
      );
      
      // Generate backup codes
      final backupCodes = _generateBackupCodes();
      _backupCodes[userId] = backupCodes;
      
      return TwoFactorSetupResult.success(
        secret: secret,
        qrCodeUri: uri,
        backupCodes: backupCodes,
      );
    } catch (e) {
      debugPrint('TOTP setup failed: $e');
      return TwoFactorSetupResult.failure('Failed to setup TOTP: ${e.toString()}');
    }
  }

  // Verify OTP (SMS or TOTP)
  Future<TwoFactorResult> verifyOTP({
    required String userId,
    required String otp,
    TwoFactorMethod? method,
  }) async {
    try {
      final session = _sessions[userId];
      
      if (session == null) {
        return TwoFactorResult.failure('Invalid session. Please request a new OTP.');
      }
      
      // Check if session expired
      if (DateTime.now().isAfter(session.expiresAt)) {
        _sessions.remove(userId);
        return TwoFactorResult.failure('OTP has expired. Please request a new one.');
      }
      
      // Check max attempts
      if (session.attempts >= session.maxAttempts) {
        _sessions.remove(userId);
        return TwoFactorResult.failure('Too many attempts. Please request a new OTP.');
      }
      
      // Increment attempts
      session.attempts++;
      
      // Verify OTP
      bool isValid = false;
      
      if (session.method == TwoFactorMethod.sms) {
        isValid = otp == session.otp;
      } else if (session.method == TwoFactorMethod.totp) {
        // In a real implementation, verify TOTP using the secret
        // For demo, we'll accept any 6-digit number
        isValid = otp.length == 6 && int.tryParse(otp) != null;
      }
      
      if (!isValid) {
        // Check if it's a backup code
        final backupCodes = _backupCodes[userId];
        if (backupCodes != null && backupCodes.contains(otp)) {
          // Use backup code (remove it after use)
          backupCodes.remove(otp);
          isValid = true;
        }
      }
      
      if (isValid) {
        _sessions.remove(userId);
        return TwoFactorResult.success(
          message: 'Authentication successful',
          sessionId: userId,
        );
      } else {
        final attemptsLeft = session.maxAttempts - session.attempts;
        return TwoFactorResult.failure(
          'Invalid OTP. $attemptsLeft attempts remaining.'
        );
      }
    } catch (e) {
      debugPrint('OTP verification failed: $e');
      return TwoFactorResult.failure('Verification failed: ${e.toString()}');
    }
  }

  // Check if user has 2FA enabled
  bool hasTwoFactorEnabled(String userId) {
    // In a real app, this would check the database
    // For demo, we'll check our backup codes storage
    return _backupCodes.containsKey(userId);
  }

  // Disable 2FA for user
  Future<bool> disable2FA(String userId) async {
    try {
      _backupCodes.remove(userId);
      _sessions.remove(userId);
      return true;
    } catch (e) {
      debugPrint('Failed to disable 2FA: $e');
      return false;
    }
  }

  // Generate new backup codes
  Future<List<String>> generateNewBackupCodes(String userId) async {
    final newCodes = _generateBackupCodes();
    _backupCodes[userId] = newCodes;
    return newCodes;
  }

  // Get remaining backup codes count
  int getRemainingBackupCodes(String userId) {
    return _backupCodes[userId]?.length ?? 0;
  }

  // Private helper methods
  String _generateOTP() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  String _generateTOTPSecret() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final random = Random();
    return List.generate(32, (index) => chars[random.nextInt(chars.length)]).join();
  }

  String _generateTOTPUri({
    required String secret,
    required String userEmail,
    required String issuer,
  }) {
    final encodedIssuer = Uri.encodeComponent(issuer);
    final encodedUser = Uri.encodeComponent(userEmail);
    return 'otpauth://totp/$encodedIssuer:$encodedUser?secret=$secret&issuer=$encodedIssuer';
  }

  List<String> _generateBackupCodes() {
    final random = Random();
    return List.generate(10, (index) {
      // Generate 8-digit backup codes
      return (10000000 + random.nextInt(90000000)).toString();
    });
  }
}

// Enums and Classes
enum TwoFactorMethod { sms, totp, backup }

class TwoFactorSession {
  final String userId;
  final TwoFactorMethod method;
  final String otp;
  final DateTime expiresAt;
  int attempts;
  final int maxAttempts;

  TwoFactorSession({
    required this.userId,
    required this.method,
    required this.otp,
    required this.expiresAt,
    this.attempts = 0,
    this.maxAttempts = 3,
  });
}

class TwoFactorResult {
  final bool isSuccess;
  final String message;
  final String? sessionId;
  final String? error;

  TwoFactorResult._({
    required this.isSuccess,
    required this.message,
    this.sessionId,
    this.error,
  });

  factory TwoFactorResult.success({
    required String message,
    String? sessionId,
  }) {
    return TwoFactorResult._(
      isSuccess: true,
      message: message,
      sessionId: sessionId,
    );
  }

  factory TwoFactorResult.failure(String error) {
    return TwoFactorResult._(
      isSuccess: false,
      message: error,
      error: error,
    );
  }
}

class TwoFactorSetupResult {
  final bool isSuccess;
  final String? secret;
  final String? qrCodeUri;
  final List<String>? backupCodes;
  final String? error;

  TwoFactorSetupResult._({
    required this.isSuccess,
    this.secret,
    this.qrCodeUri,
    this.backupCodes,
    this.error,
  });

  factory TwoFactorSetupResult.success({
    required String secret,
    required String qrCodeUri,
    required List<String> backupCodes,
  }) {
    return TwoFactorSetupResult._(
      isSuccess: true,
      secret: secret,
      qrCodeUri: qrCodeUri,
      backupCodes: backupCodes,
    );
  }

  factory TwoFactorSetupResult.failure(String error) {
    return TwoFactorSetupResult._(
      isSuccess: false,
      error: error,
    );
  }
}
