class ComplianceInfo {
  final String summaryText;
  final List<String> dataCollectionInfo;
  final List<String> dataUsageInfo;
  final List<String> dataProtectionInfo;
  final List<String> userRights;
  final List<String> certifications;
  final String jurisdiction;
  final String contactEmail;
  final String? dpoContact; // Data Protection Officer
  final DateTime lastUpdated;

  const ComplianceInfo({
    required this.summaryText,
    required this.dataCollectionInfo,
    required this.dataUsageInfo,
    required this.dataProtectionInfo,
    required this.userRights,
    required this.certifications,
    required this.jurisdiction,
    required this.contactEmail,
    this.dpoContact,
    required this.lastUpdated,
  });

  // Default Malaysian compliance information
  factory ComplianceInfo.defaultMalaysian() {
    return ComplianceInfo(
      summaryText: 
          'This medical AI system processes healthcare data in compliance with '
          'Malaysian Personal Data Protection Act (PDPA) 2010 and healthcare regulations. '
          'Your data is encrypted, access-controlled, and used only for authorized '
          'medical purposes within your healthcare institution.',
      
      dataCollectionInfo: [
        'User authentication and profile information',
        'Medical queries and AI-generated responses',
        'System interaction logs for audit purposes',
        'Performance metrics (anonymized)',
        'Error reports and system diagnostics',
        'Session data for security monitoring',
      ],
      
      dataUsageInfo: [
        'Provide AI-assisted medical information and recommendations',
        'Maintain audit trails for regulatory compliance',
        'Improve AI model accuracy and system performance',
        'Generate anonymized analytics for research',
        'Ensure system security and prevent unauthorized access',
        'Comply with healthcare quality assurance requirements',
      ],
      
      dataProtectionInfo: [
        'AES-256 encryption for data at rest',
        'TLS 1.3 encryption for data in transit',
        'Multi-factor authentication for user access',
        'Role-based access control (RBAC)',
        'Regular security audits and penetration testing',
        'Data backup with encryption and access controls',
        'Automatic data retention policy enforcement',
      ],
      
      userRights: [
        'Right to access your personal data',
        'Right to correct inaccurate information',
        'Right to delete your account and data',
        'Right to data portability where applicable',
        'Right to withdraw consent for data processing',
        'Right to lodge complaints with regulatory authorities',
        'Right to be informed about data breaches',
      ],
      
      certifications: [
        'PDPA 2010 Compliant',
        'ISO 27001 Certified',
        'SOC 2 Type II',
        'HIPAA Aligned',
        'MOH Malaysia Approved',
      ],
      
      jurisdiction: 'Malaysia',
      contactEmail: 'privacy@medical-ai.my',
      dpoContact: 'dpo@medical-ai.my',
      lastUpdated: DateTime(2025, 9, 1),
    );
  }

  // Hospital-specific compliance (for different institutions)
  factory ComplianceInfo.forHospital({
    required String hospitalName,
    required String hospitalEmail,
    String? customSummary,
    List<String>? additionalCertifications,
  }) {
    final defaultInfo = ComplianceInfo.defaultMalaysian();
    
    return ComplianceInfo(
      summaryText: customSummary ?? 
          'This medical AI system at $hospitalName processes healthcare data '
          'in compliance with Malaysian PDPA 2010 and institutional data governance policies. '
          'Your data is protected according to the highest healthcare security standards.',
      
      dataCollectionInfo: defaultInfo.dataCollectionInfo,
      dataUsageInfo: [
        ...defaultInfo.dataUsageInfo,
        'Support $hospitalName clinical decision-making processes',
        'Integrate with $hospitalName electronic health records',
      ],
      dataProtectionInfo: defaultInfo.dataProtectionInfo,
      userRights: defaultInfo.userRights,
      
      certifications: [
        ...defaultInfo.certifications,
        ...additionalCertifications ?? [],
        '$hospitalName Data Governance Approved',
      ],
      
      jurisdiction: defaultInfo.jurisdiction,
      contactEmail: hospitalEmail,
      dpoContact: 'dpo@${hospitalEmail.split('@').last}',
      lastUpdated: defaultInfo.lastUpdated,
    );
  }

  // Convert to JSON for storage/transmission
  Map<String, dynamic> toJson() {
    return {
      'summary_text': summaryText,
      'data_collection_info': dataCollectionInfo,
      'data_usage_info': dataUsageInfo,
      'data_protection_info': dataProtectionInfo,
      'user_rights': userRights,
      'certifications': certifications,
      'jurisdiction': jurisdiction,
      'contact_email': contactEmail,
      'dpo_contact': dpoContact,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  // Create from JSON
  factory ComplianceInfo.fromJson(Map<String, dynamic> json) {
    return ComplianceInfo(
      summaryText: json['summary_text'] ?? '',
      dataCollectionInfo: List<String>.from(json['data_collection_info'] ?? []),
      dataUsageInfo: List<String>.from(json['data_usage_info'] ?? []),
      dataProtectionInfo: List<String>.from(json['data_protection_info'] ?? []),
      userRights: List<String>.from(json['user_rights'] ?? []),
      certifications: List<String>.from(json['certifications'] ?? []),
      jurisdiction: json['jurisdiction'] ?? 'Malaysia',
      contactEmail: json['contact_email'] ?? '',
      dpoContact: json['dpo_contact'],
      lastUpdated: DateTime.parse(json['last_updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Copy with modifications
  ComplianceInfo copyWith({
    String? summaryText,
    List<String>? dataCollectionInfo,
    List<String>? dataUsageInfo,
    List<String>? dataProtectionInfo,
    List<String>? userRights,
    List<String>? certifications,
    String? jurisdiction,
    String? contactEmail,
    String? dpoContact,
    DateTime? lastUpdated,
  }) {
    return ComplianceInfo(
      summaryText: summaryText ?? this.summaryText,
      dataCollectionInfo: dataCollectionInfo ?? this.dataCollectionInfo,
      dataUsageInfo: dataUsageInfo ?? this.dataUsageInfo,
      dataProtectionInfo: dataProtectionInfo ?? this.dataProtectionInfo,
      userRights: userRights ?? this.userRights,
      certifications: certifications ?? this.certifications,
      jurisdiction: jurisdiction ?? this.jurisdiction,
      contactEmail: contactEmail ?? this.contactEmail,
      dpoContact: dpoContact ?? this.dpoContact,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComplianceInfo &&
        other.summaryText == summaryText &&
        other.jurisdiction == jurisdiction &&
        other.contactEmail == contactEmail;
  }

  @override
  int get hashCode {
    return summaryText.hashCode ^
        jurisdiction.hashCode ^
        contactEmail.hashCode;
  }

  @override
  String toString() {
    return 'ComplianceInfo(jurisdiction: $jurisdiction, certifications: ${certifications.length})';
  }
}

// Predefined compliance configurations for different regions/hospitals
class ComplianceConfigs {
  static final Map<String, ComplianceInfo> predefined = {
    'MY_DEFAULT': ComplianceInfo(
      summaryText: 'Malaysian PDPA 2010 compliant medical AI system',
      dataCollectionInfo: const ['Standard medical data collection'],
      dataUsageInfo: const ['Medical AI assistance'],
      dataProtectionInfo: const ['Industry-standard encryption'],
      userRights: const ['PDPA 2010 rights'],
      certifications: const ['PDPA 2010', 'ISO 27001'],
      jurisdiction: 'Malaysia',
      contactEmail: 'privacy@medical-ai.my',
      lastUpdated: DateTime(2025, 9, 1),
    ),
  };

  static ComplianceInfo getConfig(String key) {
    return predefined[key] ?? ComplianceInfo.defaultMalaysian();
  }

  static List<String> getAvailableConfigs() {
    return predefined.keys.toList();
  }
}
