import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../providers/auth_provider.dart' as auth;
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600), // Shorter duration
      vsync: this,
    );
    
    // Start animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get providers once at the top level to minimize rebuilds
    final appProvider = Provider.of<AppProvider>(context);
    final authProvider = Provider.of<auth.AuthProvider>(context);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animValue = _animationController.value;
        
        return Transform.translate(
          offset: Offset(0, (1 - animValue) * 30),
          child: Opacity(
            opacity: animValue,
            child: child,
          ),
        );
      },
      child: _SettingsContent(
        appProvider: appProvider,
        authProvider: authProvider,
      ),
    );
  }
}

// Separate widget to prevent rebuilds of the animated wrapper
class _SettingsContent extends StatelessWidget {
  final AppProvider appProvider;
  final auth.AuthProvider authProvider;

  const _SettingsContent({
    required this.appProvider,
    required this.authProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/assets/background.png'),
          fit: BoxFit.cover,
          alignment: Alignment.centerLeft,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: appProvider.isDarkMode 
            ? Colors.black.withValues(alpha: 0.1) 
            : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header - static content
              _buildHeader(),
              const SizedBox(height: 32),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(), // Better scroll physics
                  child: Column(
                    children: [
                      _buildAppearanceSection(),
                      const SizedBox(height: 32),
                      _buildNotificationsSection(),
                      const SizedBox(height: 32),
                      _buildPrivacySection(),
                      const SizedBox(height: 32),
                      _buildAccountSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'settings_title'.tr,
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'customize_experience'.tr,
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white.withValues(alpha: 0.9),
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _SettingsSection(
      title: 'appearance'.tr,
      children: [
        _ThemeToggle(appProvider: appProvider),
        _LanguageSelector(appProvider: appProvider),
        _LanguageButtons(appProvider: appProvider),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _SettingsSection(
      title: 'notifications'.tr,
      children: [
        _SettingsTile(
          title: 'document_processing'.tr,
          subtitle: 'document_processing_desc'.tr,
          icon: Icons.notifications_outlined,
          value: true,
          onChanged: (value) {},
        ),
        _SettingsTile(
          title: 'ai_insights'.tr,
          subtitle: 'ai_insights_desc'.tr,
          icon: Icons.lightbulb_outlined,
          value: true,
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _SettingsSection(
      title: 'privacy_security'.tr,
      children: [
        _SettingsTile(
          title: 'data_encryption'.tr,
          subtitle: 'data_encryption_desc'.tr,
          icon: Icons.security_outlined,
          value: true,
          onChanged: null,
        ),
        _SettingsItem(
          title: 'privacy_policy'.tr,
          subtitle: 'privacy_policy_desc'.tr,
          icon: Icons.privacy_tip_outlined,
          onTap: () {},
        ),
        _SettingsItem(
          title: 'terms_of_service'.tr,
          subtitle: 'terms_of_service_desc'.tr,
          icon: Icons.description_outlined,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _SettingsSection(
      title: 'account'.tr,
      children: [
        _AccountInfo(authProvider: authProvider),
        _SettingsItem(
          title: 'export_data'.tr,
          subtitle: 'export_data_desc'.tr,
          icon: Icons.download_outlined,
          onTap: () {},
        ),
        Builder(
          builder: (context) => _SettingsItem(
            title: 'sign_out'.tr,
            subtitle: 'sign_out_desc'.tr,
            icon: Icons.logout_outlined,
            onTap: () async {
              await authProvider.logout();
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
              Navigator.of(context).pushReplacementNamed('/login');
            },
            textColor: AppColors.accent,
          ),
        ),
      ],
    );
  }
}

// Separate stateless widgets for better performance
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final AppProvider appProvider;

  const _ThemeToggle({required this.appProvider});

  @override
  Widget build(BuildContext context) {
    return _SettingsTile(
      title: appProvider.isDarkMode ? 'dark_mode'.tr : 'light_mode'.tr,
      subtitle: appProvider.isDarkMode 
        ? 'Switch to light theme'.tr
        : 'Switch to dark theme'.tr,
      icon: Icons.dark_mode_outlined,
      value: appProvider.isDarkMode,
      onChanged: (_) => appProvider.toggleTheme(),
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  final AppProvider appProvider;

  const _LanguageSelector({required this.appProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.translate_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'language'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose your preferred language'.tr,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButtons extends StatelessWidget {
  final AppProvider appProvider;

  const _LanguageButtons({required this.appProvider});

  void _changeLanguage(SupportedLanguage language) {
    // Update AppProvider
    appProvider.changeLanguage(language);
    
    // Update GetX locale immediately
    String localeCode = '';
    switch (language) {
      case SupportedLanguage.english:
        localeCode = 'en';
        break;
      case SupportedLanguage.malay:
        localeCode = 'ms';
        break;
      case SupportedLanguage.mandarin:
        localeCode = 'zh';
        break;
      case SupportedLanguage.tamil:
        localeCode = 'ta';
        break;
    }
    
    // Force GetX to change language immediately
    Get.updateLocale(Locale(localeCode));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          // Language buttons row
          Row(
            children: [
              Expanded(
                child: _LanguageButton(
                  flag: '🇺🇸',
                  label: 'EN',
                  isSelected: appProvider.currentLanguage == SupportedLanguage.english,
                  onTap: () => _changeLanguage(SupportedLanguage.english),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LanguageButton(
                  flag: '🇲🇾',
                  label: 'BM',
                  isSelected: appProvider.currentLanguage == SupportedLanguage.malay,
                  onTap: () => _changeLanguage(SupportedLanguage.malay),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LanguageButton(
                  flag: '🇨🇳',
                  label: '中文',
                  isSelected: appProvider.currentLanguage == SupportedLanguage.mandarin,
                  onTap: () => _changeLanguage(SupportedLanguage.mandarin),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColors.primary.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
              ? AppColors.primary
              : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final void Function(bool)? onChanged;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (onChanged != null)
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            )
          else
            Icon(
              value ? Icons.check_circle_outlined : Icons.cancel_outlined,
              color: value ? AppColors.success : Colors.white.withValues(alpha: 0.6),
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingsItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (textColor ?? AppColors.primary).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: textColor ?? Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor ?? Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountInfo extends StatelessWidget {
  final auth.AuthProvider authProvider;

  const _AccountInfo({required this.authProvider});

  @override
  Widget build(BuildContext context) {
    final user = authProvider.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3)
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'User',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'user@example.com',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    authProvider.getRoleDisplayName(),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Edit profile
            },
            icon: Icon(
              Icons.edit_outlined,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}