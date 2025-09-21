import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/gestures.dart';
import '../../models/compliance_info.dart';

class PrivacyNotice extends StatefulWidget {
  final Function(bool accepted)? onAcceptanceChanged;
  final ComplianceInfo? complianceInfo;
  final bool isRequired;
  final TextStyle? textStyle;

  const PrivacyNotice({
    super.key,
    this.onAcceptanceChanged,
    this.complianceInfo,
    this.isRequired = true,
    this.textStyle,
  });

  @override
  State<PrivacyNotice> createState() => _PrivacyNoticeState();
}

class _PrivacyNoticeState extends State<PrivacyNotice> {
  bool _isAccepted = false;
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compliance = widget.complianceInfo ?? ComplianceInfo.defaultMalaysian();
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy Header
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Data Privacy & Security',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _showDetails = !_showDetails),
                  icon: Icon(
                    _showDetails ? Icons.expand_less : Icons.expand_more,
                  ),
                  tooltip: _showDetails ? 'Hide details' : 'Show details',
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Summary Notice
            Text(
              compliance.summaryText,
              style: widget.textStyle ?? theme.textTheme.bodyMedium,
            ),
            
            // Detailed Information (Collapsible)
            if (_showDetails) ...[
              const SizedBox(height: 16),
              _buildDetailedInfo(context, compliance),
            ],
            
            const SizedBox(height: 16),
            
            // Acceptance Checkbox
            CheckboxListTile(
              value: _isAccepted,
              onChanged: (bool? value) {
                setState(() {
                  _isAccepted = value ?? false;
                });
                widget.onAcceptanceChanged?.call(_isAccepted);
              },
              title: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    TextSpan(
                      text: 'I acknowledge that I have read and agree to the ',
                    ),
                    TextSpan(
                      text: 'Terms of Service',
                      style: TextStyle(
                        color: theme.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _showTermsDialog(context),
                    ),
                    TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TextStyle(
                        color: theme.primaryColor,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _showPrivacyDialog(context),
                    ),
                    TextSpan(text: '.'),
                    if (widget.isRequired)
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                  ],
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            
            // Compliance Badges
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: compliance.certifications.map((cert) {
                return Chip(
                  label: Text(
                    cert,
                    style: theme.textTheme.bodySmall,
                  ),
                  backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                  side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.3)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedInfo(BuildContext context, ComplianceInfo compliance) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            context,
            'Data Collection',
            compliance.dataCollectionInfo,
            Icons.data_usage,
          ),
          const SizedBox(height: 12),
          _buildInfoSection(
            context,
            'Data Usage',
            compliance.dataUsageInfo,
            Icons.analytics,
          ),
          const SizedBox(height: 12),
          _buildInfoSection(
            context,
            'Data Protection',
            compliance.dataProtectionInfo,
            Icons.shield,
          ),
          const SizedBox(height: 12),
          _buildInfoSection(
            context,
            'Your Rights',
            compliance.userRights,
            Icons.account_balance,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<String> items,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: theme.primaryColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(left: 22, top: 2),
          child: Text(
            '• $item',
            style: theme.textTheme.bodySmall,
          ),
        )),
      ],
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('terms_of_service'.tr),
        content: const SingleChildScrollView(
          child: Text(
            'Terms of Service for Medical AI System\n\n'
            '1. Acceptance of Terms\n'
            'By accessing and using this medical AI system, you agree to be bound by these Terms of Service.\n\n'
            '2. Medical Disclaimer\n'
            'This system provides AI-assisted medical information for healthcare professionals. It is not a substitute for professional medical judgment.\n\n'
            '3. User Responsibilities\n'
            '• Verify all AI-generated information before clinical use\n'
            '• Maintain patient confidentiality\n'
            '• Use system only for authorized medical purposes\n\n'
            '4. Limitation of Liability\n'
            'The system providers are not liable for any medical decisions made based on AI-generated information.\n\n'
            '5. Compliance\n'
            'Users must comply with all applicable Malaysian healthcare regulations including PDPA 2010.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('privacy_policy'.tr),
        content: const SingleChildScrollView(
          child: Text(
            'Privacy Policy for Medical AI System\n\n'
            '1. Information We Collect\n'
            '• User authentication data\n'
            '• Medical queries and responses\n'
            '• System usage analytics\n'
            '• Audit logs for compliance\n\n'
            '2. How We Use Information\n'
            '• Provide AI-assisted medical information\n'
            '• Improve system accuracy and performance\n'
            '• Ensure regulatory compliance\n'
            '• Maintain security audit trails\n\n'
            '3. Information Sharing\n'
            'We do not share personal information except as required by Malaysian law or with your explicit consent.\n\n'
            '4. Data Security\n'
            '• End-to-end encryption\n'
            '• Regular security audits\n'
            '• Compliance with ISO 27001\n'
            '• PDPA 2010 compliance\n\n'
            '5. Your Rights\n'
            'Under PDPA 2010, you have rights to access, correct, and delete your personal data.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class CompactPrivacyNotice extends StatefulWidget {
  final Function(bool accepted)? onAcceptanceChanged;
  final bool isRequired;

  const CompactPrivacyNotice({
    super.key,
    this.onAcceptanceChanged,
    this.isRequired = true,
  });

  @override
  State<CompactPrivacyNotice> createState() => _CompactPrivacyNoticeState();
}

class _CompactPrivacyNoticeState extends State<CompactPrivacyNotice> {
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CheckboxListTile(
      value: _isAccepted,
      onChanged: (bool? value) {
        setState(() {
          _isAccepted = value ?? false;
        });
        widget.onAcceptanceChanged?.call(_isAccepted);
      },
      title: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(text: 'I agree to the '),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(
                color: theme.primaryColor,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => _showFullPrivacyNotice(context),
            ),
            TextSpan(text: ' and data processing terms'),
            if (widget.isRequired)
              TextSpan(
                text: ' *',
                style: TextStyle(color: theme.colorScheme.error),
              ),
          ],
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  void _showFullPrivacyNotice(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
          child: Column(
            children: [
              AppBar(
                title: Text('privacy_compliance'.tr),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: PrivacyNotice(
                    onAcceptanceChanged: (accepted) {
                      setState(() {
                        _isAccepted = accepted;
                      });
                      widget.onAcceptanceChanged?.call(accepted);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
