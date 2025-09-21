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
          'Settings',
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
          'Customize your Medical AI experience',
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
      title: 'Appearance',
      children: [
        _ThemeToggle(appProvider: appProvider),
        _LanguageSelector(appProvider: appProvider),
      ],
    );
  }

  Widget _buildNotificationsSection() {
    return _SettingsSection(
      title: 'Notifications',
      children: [
        _SettingsTile(
          title: 'Document Processing',
          subtitle: 'Get notified when documents are processed',
          icon: Icons.notifications_outlined,
          value: true,
          onChanged: (value) {},
        ),
        _SettingsTile(
          title: 'AI Insights',
          subtitle: 'Receive AI-generated insights and alerts',
          icon: Icons.lightbulb_outlined,
          value: true,
          onChanged: (value) {},
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _SettingsSection(
      title: 'Privacy & Security',
      children: [
        _SettingsTile(
          title: 'Data Encryption',
          subtitle: 'All data is encrypted end-to-end',
          icon: Icons.security_outlined,
          value: true,
          onChanged: null,
        ),
        _SettingsItem(
          title: 'Privacy Policy',
          subtitle: 'Review our privacy practices',
          icon: Icons.privacy_tip_outlined,
          onTap: () {},
        ),
        _SettingsItem(
          title: 'Terms of Service',
          subtitle: 'Read our terms and conditions',
          icon: Icons.description_outlined,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _SettingsSection(
      title: 'Account',
      children: [
        _AccountInfo(authProvider: authProvider),
        _SettingsItem(
          title: 'Export Data',
          subtitle: 'Download your data',
          icon: Icons.download_outlined,
          onTap: () {},
        ),
        Builder(
          builder: (context) => _SettingsItem(
            title: 'Sign Out',
            subtitle: 'Sign out from your account',
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
      title: 'Dark Mode',
      subtitle: 'Toggle between light and dark theme',
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
                  'Language',
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
                  'Choose your preferred language',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
            child: DropdownButton<SupportedLanguage>(
              value: appProvider.currentLanguage,
              underline: const SizedBox.shrink(),
              dropdownColor: Colors.black.withValues(alpha: 0.8),
              items: [
                DropdownMenuItem(
                  value: SupportedLanguage.english,
                  child: Text('🇺🇸 English', 
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: SupportedLanguage.malay,
                  child: Text('🇲🇾 Bahasa Melayu', 
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: SupportedLanguage.mandarin,
                  child: Text('🇨🇳 中文', 
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                ),
                DropdownMenuItem(
                  value: SupportedLanguage.tamil,
                  child: Text('🇮🇳 தமிழ்', 
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                ),
              ],
              onChanged: (language) {
                if (language != null) {
                  appProvider.changeLanguage(language);
                }
              },
            ),
          ),
        ],
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