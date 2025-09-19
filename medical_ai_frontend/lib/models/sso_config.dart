class SSOConfig {
  final String hospitalId;
  final String samlEndpoint;
  final String oauthClientId;
  final String redirectUri;
  final bool isEnabled;
  final Map<String, String>? customAttributes;
  final int tokenExpiryMinutes;
  final String? logoUrl;
  final String? hospitalName;
  final List<String> supportedLanguages;

  const SSOConfig({
    required this.hospitalId,
    required this.samlEndpoint,
    required this.oauthClientId,
    required this.redirectUri,
    this.isEnabled = true,
    this.customAttributes,
    this.tokenExpiryMinutes = 60,
    this.logoUrl,
    this.hospitalName,
    this.supportedLanguages = const ['en', 'ms'],
  });

  // Create from JSON (for configuration loading)
  factory SSOConfig.fromJson(Map<String, dynamic> json) {
    return SSOConfig(
      hospitalId: json['hospital_id'] ?? '',
      samlEndpoint: json['saml_endpoint'] ?? '',
      oauthClientId: json['oauth_client_id'] ?? '',
      redirectUri: json['redirect_uri'] ?? '',
      isEnabled: json['is_enabled'] ?? true,
      customAttributes: json['custom_attributes'] != null
          ? Map<String, String>.from(json['custom_attributes'])
          : null,
      tokenExpiryMinutes: json['token_expiry_minutes'] ?? 60,
      logoUrl: json['logo_url'],
      hospitalName: json['hospital_name'],
      supportedLanguages: json['supported_languages'] != null
          ? List<String>.from(json['supported_languages'])
          : ['en', 'ms'],
    );
  }

  // Convert to JSON (for configuration saving)
  Map<String, dynamic> toJson() {
    return {
      'hospital_id': hospitalId,
      'saml_endpoint': samlEndpoint,
      'oauth_client_id': oauthClientId,
      'redirect_uri': redirectUri,
      'is_enabled': isEnabled,
      'custom_attributes': customAttributes,
      'token_expiry_minutes': tokenExpiryMinutes,
      'logo_url': logoUrl,
      'hospital_name': hospitalName,
      'supported_languages': supportedLanguages,
    };
  }

  // Copy with modified properties
  SSOConfig copyWith({
    String? hospitalId,
    String? samlEndpoint,
    String? oauthClientId,
    String? redirectUri,
    bool? isEnabled,
    Map<String, String>? customAttributes,
    int? tokenExpiryMinutes,
    String? logoUrl,
    String? hospitalName,
    List<String>? supportedLanguages,
  }) {
    return SSOConfig(
      hospitalId: hospitalId ?? this.hospitalId,
      samlEndpoint: samlEndpoint ?? this.samlEndpoint,
      oauthClientId: oauthClientId ?? this.oauthClientId,
      redirectUri: redirectUri ?? this.redirectUri,
      isEnabled: isEnabled ?? this.isEnabled,
      customAttributes: customAttributes ?? this.customAttributes,
      tokenExpiryMinutes: tokenExpiryMinutes ?? this.tokenExpiryMinutes,
      logoUrl: logoUrl ?? this.logoUrl,
      hospitalName: hospitalName ?? this.hospitalName,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SSOConfig &&
        other.hospitalId == hospitalId &&
        other.samlEndpoint == samlEndpoint &&
        other.oauthClientId == oauthClientId &&
        other.redirectUri == redirectUri &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode {
    return hospitalId.hashCode ^
        samlEndpoint.hashCode ^
        oauthClientId.hashCode ^
        redirectUri.hashCode ^
        isEnabled.hashCode;
  }

  @override
  String toString() {
    return 'SSOConfig(hospitalId: $hospitalId, isEnabled: $isEnabled, hospitalName: $hospitalName)';
  }
}

// Predefined hospital SSO configurations
class HospitalSSOConfigs {
  static const Map<String, SSOConfig> configs = {
    'HKL': SSOConfig(
      hospitalId: 'HKL',
      hospitalName: 'Hospital Kuala Lumpur',
      samlEndpoint: 'https://sso.hkl.gov.my/auth/saml/login',
      oauthClientId: 'medical-ai-hkl',
      redirectUri: 'https://medical-ai.hkl.gov.my/auth/callback',
      logoUrl: 'https://hkl.gov.my/assets/logo.png',
      supportedLanguages: ['en', 'ms'],
    ),
    'PPUKM': SSOConfig(
      hospitalId: 'PPUKM',
      hospitalName: 'Pusat Perubatan Universiti Kebangsaan Malaysia',
      samlEndpoint: 'https://sso.ppukm.ukm.edu.my/auth/saml/login',
      oauthClientId: 'medical-ai-ppukm',
      redirectUri: 'https://medical-ai.ppukm.ukm.edu.my/auth/callback',
      logoUrl: 'https://ppukm.ukm.edu.my/assets/logo.png',
      supportedLanguages: ['en', 'ms'],
    ),
    'UMMC': SSOConfig(
      hospitalId: 'UMMC',
      hospitalName: 'University Malaya Medical Centre',
      samlEndpoint: 'https://sso.ummc.edu.my/auth/saml/login',
      oauthClientId: 'medical-ai-ummc',
      redirectUri: 'https://medical-ai.ummc.edu.my/auth/callback',
      logoUrl: 'https://ummc.edu.my/assets/logo.png',
      supportedLanguages: ['en', 'ms', 'zh'],
    ),
    'SGH': SSOConfig(
      hospitalId: 'SGH',
      hospitalName: 'Serdang Hospital',
      samlEndpoint: 'https://sso.serdanghospital.gov.my/auth/saml/login',
      oauthClientId: 'medical-ai-sgh',
      redirectUri: 'https://medical-ai.serdanghospital.gov.my/auth/callback',
      logoUrl: 'https://serdanghospital.gov.my/assets/logo.png',
      supportedLanguages: ['en', 'ms'],
    ),
  };

  // Get SSO config for a specific hospital
  static SSOConfig? getConfig(String hospitalId) {
    return configs[hospitalId.toUpperCase()];
  }

  // Get all available hospital IDs
  static List<String> getAvailableHospitals() {
    return configs.keys.toList();
  }

  // Check if a hospital has SSO configured
  static bool hasSSO(String hospitalId) {
    return configs.containsKey(hospitalId.toUpperCase());
  }
}
