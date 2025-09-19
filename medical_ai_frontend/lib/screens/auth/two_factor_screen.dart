import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/two_factor_service.dart';

class TwoFactorScreen extends StatefulWidget {
  final String userId;
  final String userEmail;
  final TwoFactorMethod method;

  const TwoFactorScreen({
    super.key,
    required this.userId,
    required this.userEmail,
    required this.method,
  });

  @override
  State<TwoFactorScreen> createState() => _TwoFactorScreenState();
}

class _TwoFactorScreenState extends State<TwoFactorScreen>
    with TickerProviderStateMixin {
  final _otpController = TextEditingController();
  final TwoFactorService _twoFactorService = TwoFactorService();
  
  bool _isVerifying = false;
  bool _isResending = false;
  int _remainingTime = 300; // 5 minutes
  late AnimationController _timerController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startTimer();
    
    if (widget.method == TwoFactorMethod.sms) {
      _sendSMSOTP();
    }
  }

  void _setupAnimations() {
    _timerController = AnimationController(
      duration: Duration(seconds: _remainingTime),
      vsync: this,
    );
    
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
  }

  void _startTimer() {
    _timerController.forward();
    
    const duration = Duration(seconds: 1);
    Timer.periodic(duration, (timer) {
      if (_remainingTime <= 0) {
        timer.cancel();
      } else {
        setState(() {
          _remainingTime--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    _shakeController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendSMSOTP() async {
    setState(() => _isResending = true);

    try {
      // Extract phone number from user data or use placeholder
      final phoneNumber = '+60123456789'; // In real app, get from user profile
      
      final result = await _twoFactorService.sendSMSOTP(
        userId: widget.userId,
        phoneNumber: phoneNumber,
      );

      if (result.isSuccess) {
        _showSuccessSnackBar(result.message);
      } else {
        _showErrorSnackBar(result.error ?? 'Failed to send OTP');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to send OTP: ${e.toString()}');
    } finally {
      setState(() => _isResending = false);
    }
  }

  Future<void> _verifyOTP() async {
    if (_otpController.text.length != 6) {
      _showErrorSnackBar('Please enter a 6-digit code');
      _shakeController.forward().then((_) => _shakeController.reset());
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final result = await _twoFactorService.verifyOTP(
        userId: widget.userId,
        otp: _otpController.text,
        method: widget.method,
      );

      if (result.isSuccess) {
        // Update auth state to authenticated
        if (mounted) {
          // In a real app, you'd get the user from the backend after 2FA verification
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        _showErrorSnackBar(result.message);
        _otpController.clear();
        _shakeController.forward().then((_) => _shakeController.reset());
      }
    } catch (e) {
      _showErrorSnackBar('Verification failed: ${e.toString()}');
      _shakeController.forward().then((_) => _shakeController.reset());
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  void _useBackupCode() {
    showDialog(
      context: context,
      builder: (context) => BackupCodeDialog(
        userId: widget.userId,
        onVerified: () {
          Navigator.of(context).pop();
          Navigator.of(context).pushReplacementNamed('/home');
        },
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withValues(alpha: 0.1),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(theme),
                    const SizedBox(height: 32),
                    _buildOTPInput(theme),
                    const SizedBox(height: 24),
                    _buildTimer(theme),
                    const SizedBox(height: 32),
                    _buildVerifyButton(theme),
                    const SizedBox(height: 16),
                    _buildAlternativeOptions(theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: theme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.method == TwoFactorMethod.sms 
              ? Icons.sms 
              : Icons.smartphone,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          widget.method == TwoFactorMethod.sms 
            ? 'SMS Verification' 
            : 'Authenticator Code',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.method == TwoFactorMethod.sms
            ? 'We sent a verification code to your phone'
            : 'Enter the code from your authenticator app',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.hintColor,
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.method == TwoFactorMethod.sms) ...[
          const SizedBox(height: 4),
          Text(
            widget.userEmail,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOTPInput(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      letterSpacing: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: '000000',
                      hintStyle: TextStyle(color: theme.hintColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.primaryColor, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onChanged: (value) {
                      if (value.length == 6 && !_isVerifying) {
                        _verifyOTP();
                      }
                    },
                    enabled: !_isVerifying,
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Enter the 6-digit verification code',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimer(ThemeData theme) {
    if (_remainingTime <= 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Code Expired',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (widget.method == TwoFactorMethod.sms)
                TextButton(
                  onPressed: _isResending ? null : _sendSMSOTP,
                  child: _isResending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Resend Code'),
                ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Code expires in ${_formatTime(_remainingTime)}',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isVerifying ? null : _verifyOTP,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isVerifying
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              'Verify Code',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
      ),
    );
  }

  Widget _buildAlternativeOptions(ThemeData theme) {
    return Column(
      children: [
        if (widget.method == TwoFactorMethod.sms && _remainingTime > 0)
          TextButton(
            onPressed: _isResending ? null : _sendSMSOTP,
            child: _isResending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Resend SMS Code'),
          ),
        
        TextButton(
          onPressed: _useBackupCode,
          child: const Text('Use Backup Code'),
        ),
        
        TextButton(
          onPressed: () {
            // Contact support
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Need Help?'),
                content: const Text(
                  'If you\'re having trouble with two-factor authentication, please contact your system administrator or IT support team.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
          child: Text(
            'Contact Support',
            style: TextStyle(color: theme.hintColor),
          ),
        ),
      ],
    );
  }
}

class BackupCodeDialog extends StatefulWidget {
  final String userId;
  final Function()? onVerified;

  const BackupCodeDialog({
    super.key,
    required this.userId,
    this.onVerified,
  });

  @override
  State<BackupCodeDialog> createState() => _BackupCodeDialogState();
}

class _BackupCodeDialogState extends State<BackupCodeDialog> {
  final _codeController = TextEditingController();
  final TwoFactorService _twoFactorService = TwoFactorService();
  bool _isVerifying = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyBackupCode() async {
    if (_codeController.text.isEmpty) {
      _showErrorSnackBar('Please enter a backup code');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final result = await _twoFactorService.verifyOTP(
        userId: widget.userId,
        otp: _codeController.text,
        method: TwoFactorMethod.backup,
      );

      if (result.isSuccess) {
        widget.onVerified?.call();
      } else {
        _showErrorSnackBar(result.message);
        _codeController.clear();
      }
    } catch (e) {
      _showErrorSnackBar('Verification failed: ${e.toString()}');
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('Backup Code'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter one of your backup codes to access your account.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codeController,
            decoration: InputDecoration(
              hintText: 'Enter backup code',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            enabled: !_isVerifying,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isVerifying ? null : _verifyBackupCode,
          child: _isVerifying
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Verify'),
        ),
      ],
    );
  }
}
