import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/sso_config.dart';
import '../../services/sso_service.dart';

class SSOLoginButton extends StatefulWidget {
  final String hospitalId;
  final Function(String token, Map<String, dynamic> userInfo)? onSuccess;
  final Function(String error)? onError;
  final bool isEnabled;

  const SSOLoginButton({
    super.key,
    required this.hospitalId,
    this.onSuccess,
    this.onError,
    this.isEnabled = true,
  });

  @override
  State<SSOLoginButton> createState() => _SSOLoginButtonState();
}

class _SSOLoginButtonState extends State<SSOLoginButton> {
  bool _isLoading = false;
  final SSOService _ssoService = SSOService();

  @override
  void initState() {
    super.initState();
    _initializeSSO();
  }

  Future<void> _initializeSSO() async {
    final config = HospitalSSOConfigs.getConfig(widget.hospitalId);
    if (config != null) {
      await _ssoService.initialize(
        hospitalId: config.hospitalId,
        samlEndpoint: config.samlEndpoint,
        oauthClientId: config.oauthClientId,
        redirectUri: config.redirectUri,
      );
    }
  }

  Future<void> _handleSSOLogin() async {
    if (!widget.isEnabled || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await _ssoService.initiateLogin();
      
      if (result.isSuccess && result.token != null) {
        widget.onSuccess?.call(result.token!, result.userInfo ?? {});
      } else {
        widget.onError?.call(result.error ?? 'SSO login failed');
      }
    } catch (e) {
      widget.onError?.call('SSO login error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = HospitalSSOConfigs.getConfig(widget.hospitalId);
    
    if (config == null || !_ssoService.isAvailable) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: widget.isEnabled ? _handleSSOLogin : null,
        icon: _isLoading 
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              ),
            )
          : config.logoUrl != null
            ? Image.network(
                config.logoUrl!,
                width: 24,
                height: 24,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.business,
                  color: theme.primaryColor,
                ),
              )
            : Icon(
                Icons.business,
                color: theme.primaryColor,
              ),
        label: Text(
          _isLoading 
            ? 'Connecting...' 
            : 'Login with ${config.hospitalName ?? 'Hospital SSO'}',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    );
  }
}

class HospitalSelectorDropdown extends StatefulWidget {
  final String? selectedHospitalId;
  final Function(String hospitalId)? onChanged;
  final bool isEnabled;

  const HospitalSelectorDropdown({
    super.key,
    this.selectedHospitalId,
    this.onChanged,
    this.isEnabled = true,
  });

  @override
  State<HospitalSelectorDropdown> createState() => _HospitalSelectorDropdownState();
}

class _HospitalSelectorDropdownState extends State<HospitalSelectorDropdown> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableHospitals = HospitalSSOConfigs.getAvailableHospitals();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: widget.selectedHospitalId,
          hint: Text(
            'Select your hospital',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.hintColor,
            ),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down,
            color: theme.primaryColor,
          ),
          onChanged: widget.isEnabled 
            ? (String? value) => widget.onChanged?.call(value ?? '') 
            : null,
          items: availableHospitals.map((hospitalId) {
            final config = HospitalSSOConfigs.getConfig(hospitalId);
            return DropdownMenuItem<String>(
              value: hospitalId,
              child: Row(
                children: [
                  if (config?.logoUrl != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Image.network(
                        config!.logoUrl!,
                        width: 32,
                        height: 32,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.local_hospital,
                          size: 32,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          config?.hospitalName ?? hospitalId,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'SSO Available',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class LoginMethodSelector extends StatelessWidget {
  final bool useSSO;
  final Function(bool useSSO) onChanged;
  final bool canUseSSO;

  const LoginMethodSelector({
    super.key,
    required this.useSSO,
    required this.onChanged,
    this.canUseSSO = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Login Method',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // SSO Option
            RadioListTile<bool>(
              value: true,
              groupValue: useSSO,
              onChanged: canUseSSO ? (value) => onChanged(value ?? false) : null,
              title: Text('hospital_sso'.tr),
              subtitle: Text(
                canUseSSO 
                  ? 'Use your hospital credentials'
                  : 'Not available for selected hospital',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: canUseSSO ? theme.hintColor : theme.colorScheme.error,
                ),
              ),
              activeColor: theme.primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
            
            // Username/Password Option
            RadioListTile<bool>(
              value: false,
              groupValue: useSSO,
              onChanged: (value) => onChanged(value ?? false),
              title: Text('username_password'.tr),
              subtitle: Text(
                'Use your Medical AI system credentials',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              activeColor: theme.primaryColor,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
