import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/two_factor_service.dart';

class TwoFactorSetupWizard extends StatefulWidget {
  final String userId;
  final String userEmail;
  final Function(bool success)? onComplete;

  const TwoFactorSetupWizard({
    super.key,
    required this.userId,
    required this.userEmail,
    this.onComplete,
  });

  @override
  State<TwoFactorSetupWizard> createState() => _TwoFactorSetupWizardState();
}

class _TwoFactorSetupWizardState extends State<TwoFactorSetupWizard>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final TwoFactorService _twoFactorService = TwoFactorService();
  
  int _currentStep = 0;
  String? _totpSecret;
  List<String> _backupCodes = [];
  bool _isLoading = false;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _setupTOTP() async {
    setState(() => _isLoading = true);

    try {
      final result = await _twoFactorService.setupTOTP(
        userId: widget.userId,
        userEmail: widget.userEmail,
        issuer: 'Medical AI System',
      );

      if (result.isSuccess) {
        setState(() {
          _totpSecret = result.secret;
          _backupCodes = result.backupCodes ?? [];
        });
        _nextStep();
      } else {
        _showErrorSnackBar(result.error ?? 'Failed to setup 2FA');
      }
    } catch (e) {
      _showErrorSnackBar('Setup failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _complete(bool success) {
    widget.onComplete?.call(success);
    Navigator.of(context).pop(success);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Two-Factor Authentication Setup'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildWelcomeStep(),
                _buildSetupStep(),
                _buildVerificationStep(),
                _buildBackupCodesStep(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = index < _currentStep;
          final isActive = index == _currentStep;
          
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
              decoration: BoxDecoration(
                color: isCompleted || isActive 
                  ? theme.primaryColor 
                  : theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWelcomeStep() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 80,
              color: theme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Enhance Your Security',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Two-factor authentication adds an extra layer of security to your medical AI account. '
              'This helps protect sensitive patient data and ensures compliance with healthcare regulations.',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      Icons.smartphone,
                      'Authenticator App',
                      'Use Google Authenticator, Authy, or similar apps',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      Icons.backup,
                      'Backup Codes',
                      'Secure codes for account recovery',
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(
                      Icons.verified_user,
                      'PDPA Compliant',
                      'Meets Malaysian data protection standards',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _setupTOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(icon, color: theme.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSetupStep() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'Scan QR Code',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Scan this QR code with your authenticator app to set up two-factor authentication.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // QR Code Placeholder (In real app, use qr_flutter package)
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.qr_code,
                  size: 80,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 8),
                Text(
                  'QR Code',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Manual entry option
          ExpansionTile(
            title: const Text('Can\'t scan? Enter manually'),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secret Key:',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      _totpSecret ?? 'Loading...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: _totpSecret != null
                            ? () {
                                Clipboard.setData(ClipboardData(text: _totpSecret!));
                                _showSuccessSnackBar('Secret key copied!');
                              }
                            : null,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'I\'ve Added the Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStep() {
    return TwoFactorVerificationStep(
      userId: widget.userId,
      onVerified: _nextStep,
      onError: _showErrorSnackBar,
    );
  }

  Widget _buildBackupCodesStep() {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.backup,
            size: 80,
            color: theme.primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Save Your Backup Codes',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'These backup codes can be used to access your account if you lose your phone. '
            'Keep them safe and secure.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backup Codes:',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 3,
                        ),
                        itemCount: _backupCodes.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                _backupCodes[index],
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              final codesText = _backupCodes.join('\n');
                              Clipboard.setData(ClipboardData(text: codesText));
                              _showSuccessSnackBar('Backup codes copied!');
                            },
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy All'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Implement download functionality
                              _showSuccessSnackBar('Download feature coming soon!');
                            },
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _complete(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Complete Setup',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TwoFactorVerificationStep extends StatefulWidget {
  final String userId;
  final Function()? onVerified;
  final Function(String)? onError;

  const TwoFactorVerificationStep({
    super.key,
    required this.userId,
    this.onVerified,
    this.onError,
  });

  @override
  State<TwoFactorVerificationStep> createState() => _TwoFactorVerificationStepState();
}

class _TwoFactorVerificationStepState extends State<TwoFactorVerificationStep> {
  final _otpController = TextEditingController();
  final TwoFactorService _twoFactorService = TwoFactorService();
  bool _isVerifying = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (_otpController.text.length != 6) {
      widget.onError?.call('Please enter a 6-digit code');
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final result = await _twoFactorService.verifyOTP(
        userId: widget.userId,
        otp: _otpController.text,
        method: TwoFactorMethod.totp,
      );

      if (result.isSuccess) {
        widget.onVerified?.call();
      } else {
        widget.onError?.call(result.message);
        _otpController.clear();
      }
    } catch (e) {
      widget.onError?.call('Verification failed: ${e.toString()}');
    } finally {
      setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.smartphone,
            size: 80,
            color: theme.primaryColor,
          ),
          const SizedBox(height: 24),
          Text(
            'Verify Your Setup',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Enter the 6-digit code from your authenticator app to verify the setup.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              letterSpacing: 8,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: '000000',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.primaryColor, width: 2),
              ),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: (value) {
              if (value.length == 6) {
                _verifyCode();
              }
            },
          ),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
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
          ),
        ],
      ),
    );
  }
}
