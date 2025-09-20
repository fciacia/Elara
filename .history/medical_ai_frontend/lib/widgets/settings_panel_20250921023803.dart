import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart' as auth;
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';
import 'background_layout.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({super.key});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isDarkMode = appProvider.isDarkMode;
        
        Widget sidebar = const SizedBox.shrink(); // No sidebar for settings
        Widget homeContent = FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with semi-transparent background for better readability
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: _getBackgroundColor(isDarkMode),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Settings',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Customize your Medical AI experience',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildSettingsSection(
                            'Appearance',
                            [
                              _buildThemeToggle(),
                              _buildLanguageSelector(isDarkMode),
                            ],
                            isDarkMode,
                          ),
                          const SizedBox(height: 32),
                          _buildSettingsSection(
                            'Notifications',
                            [
                              _buildSettingsTile(
                                'Document Processing',
                                'Get notified when documents are processed',
                                Icons.notifications_outlined,
                                true,
                                (value) {},
                              ),
                              _buildSettingsTile(
                                'AI Insights',
                                'Receive AI-generated insights and alerts',
                                Icons.lightbulb_outlined,
                                true,
                                (value) {},
                              ),
                            ],
                            isDarkMode,
                          ),
                          const SizedBox(height: 32),
                          _buildSettingsSection(
                            'Privacy & Security',
                            [
                              _buildSettingsTile(
                                'Data Encryption',
                                'All data is encrypted end-to-end',
                                Icons.security_outlined,
                                true,
                                null, // Non-toggleable
                              ),
                              _buildSettingsItem(
                                'Privacy Policy',
                                'Review our privacy practices',
                                Icons.privacy_tip_outlined,
                                () {},
                              ),
                              _buildSettingsItem(
                                'Terms of Service',
                                'Read our terms and conditions',
                                Icons.description_outlined,
                                () {},
                              ),
                            ],
                            isDarkMode,
                          ),
                          const SizedBox(height: 32),
                          _buildSettingsSection(
                            'Account',
                            [
                              _buildAccountInfo(),
                              _buildSettingsItem(
                                'Export Data',
                                'Download your data',
                                Icons.download_outlined,
                                () {},
                              ),
                              _buildSettingsItem(
                                'Sign Out',
                                'Sign out from your account',
                                Icons.logout_outlined,
                                () async {
                                  final navigator = Navigator.of(context);
                                  await context.read<auth.AuthProvider>().logout();
                                  if (mounted) {
                                    navigator.pushNamedAndRemoveUntil(
                                      '/login',
                                      (route) => false,
                                    );
                                  }
                                },
                                textColor: AppColors.accent,
                              ),
                            ],
                            isDarkMode,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        
        return BackgroundLayout(
          sidebar: sidebar, 
          homeContent: homeContent,
          isDarkMode: isDarkMode,
        );
      },
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Semi-transparent background to blend with background image
        color: _getSectionBackgroundColor(isDarkMode),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: _getBoxShadow(isDarkMode),
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
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return _buildSettingsTile(
          'Dark Mode',
          'Toggle between light and dark theme',
          Icons.dark_mode_outlined,
          appProvider.isDarkMode,
          (_) => appProvider.toggleTheme(),
        );
      },
    );
  }

  Widget _buildLanguageSelector(bool isDarkMode) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Choose your preferred language',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: DropdownButton<SupportedLanguage>(
                  value: appProvider.currentLanguage,
                  underline: const SizedBox.shrink(),
                  dropdownColor: _getDropdownColor(isDarkMode),
                  items: [
                    DropdownMenuItem(
                      value: SupportedLanguage.english,
                      child: Text('🇺🇸 English', style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: SupportedLanguage.malay,
                      child: Text('🇲🇾 Bahasa Melayu', style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: SupportedLanguage.mandarin,
                      child: Text('🇨🇳 中文', style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                    ),
                    DropdownMenuItem(
                      value: SupportedLanguage.tamil,
                      child: Text('🇮🇳 தமிழ்', style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
                    ),
                  ],
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
                  icon: Icon(Icons.arrow_drop_down, color: Colors.white.withValues(alpha: 0.8)),
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
      },
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    void Function(bool)? onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
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
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (onChanged != null)
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color.fromRGBO(124, 58, 237, 1),
              activeTrackColor: const Color.fromRGBO(124, 58, 237, 0.3),
              inactiveThumbColor: Colors.white.withValues(alpha: 0.8),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
            )
          else
            Icon(
              value ? Icons.check_circle_outlined : Icons.cancel_outlined,
              color: value ? Colors.green : Colors.red,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? textColor,
  }) {
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
                color: Colors.white.withValues(alpha: 0.15),
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.8),
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

  Widget _buildAccountInfo() {
    return Consumer<auth.AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
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
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? 'user@example.com',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
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
      },
    );
  }

  // Theme helper methods
  Color _getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.white;
  }

  Color _getSectionBackgroundColor(bool isDarkMode) {
    return isDarkMode ? Colors.black.withValues(alpha: 0.4) : Colors.white;
  }

  Color _getDropdownColor(bool isDarkMode) {
    return isDarkMode ? Colors.black.withValues(alpha: 0.9) : Colors.white;
  }

  List<BoxShadow> _getBoxShadow(bool isDarkMode) {
    return [
      BoxShadow(
        color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.15),
        blurRadius: 10,
        offset: const Offset(0, 5),
      ),
    ];
  }
}