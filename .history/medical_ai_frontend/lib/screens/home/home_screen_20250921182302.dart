import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:get/get.dart';

import '../../providers/auth_provider.dart' as auth;
import '../../providers/document_provider.dart';
import '../../providers/chat_provider_aws.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_sidebar.dart';
import '../../widgets/dashboard_content_clean.dart' as dashboard;
import '../../widgets/futuristic_medical_chat.dart';
import '../../widgets/multimodal_document_manager.dart';
import '../../widgets/enhanced_analytics_page.dart';
import '../../widgets/settings_panel.dart';
import '../../widgets/background_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isCollapsed = false;

  List<NavItem> get _navItems => [
    NavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'dashboard'.tr,
      route: '/dashboard',
    ),
    NavItem(
      icon: MdiIcons.fileDocumentOutline,
      selectedIcon: MdiIcons.fileDocument,
      label: 'documents'.tr,
      route: '/documents',
    ),
    NavItem(
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble,
      label: 'ai_chat'.tr,
      route: '/chat',
    ),
    NavItem(
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics,
      label: 'analytics'.tr,
      route: '/analytics',
    ),
    NavItem(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'settings'.tr,
      route: '/settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  void _initializeProviders() {
    context.read<DocumentProvider>().initialize();
    // ChatProvider AWS doesn't require initialization
  }

  Widget _getSelectedContent() {
    switch (_selectedIndex) {
      case 0:
        return dashboard.DashboardContent(
          onNavigateToChat: () => setState(() => _selectedIndex = 2),
        );
      case 1:
        return const MultimodalDocumentManager();
      case 2:
        return const CleanChatInterface(); // Enhanced futuristic medical chat with advanced features
      case 3:
        return const EnhancedAnalyticsPage(); // Enhanced analytics with comprehensive insights
      case 4:
        return const SettingsPanel();
      default:
        return dashboard.DashboardContent(
          onNavigateToChat: () => setState(() => _selectedIndex = 2),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 768;

    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        Widget sidebar = !isMobile
            ? CustomSidebar(
                selectedIndex: _selectedIndex,
                onItemSelected: (index) => setState(() => _selectedIndex = index),
                navItems: _navItems,
                isCollapsed: _isCollapsed,
                onToggleCollapse: () => setState(() => _isCollapsed = !_isCollapsed),
                isDarkMode: appProvider.isDarkMode,
              )
            : SizedBox.shrink();

        Widget homeContent = Column(
          children: [
            _buildTopAppBar(),
            Expanded(child: _getSelectedContent()),
            ],
          );

          Widget backgroundLayout = BackgroundLayout(
            sidebar: sidebar,
            homeContent: homeContent,
            isDarkMode: appProvider.isDarkMode,
          );

          return Scaffold(
            body: backgroundLayout,
            bottomNavigationBar: isMobile ? _buildBottomNavigation() : null,
            floatingActionButton: isMobile && _selectedIndex == 2
                ? FloatingActionButton(
                    onPressed: () {
                      context.read<ChatProvider>().startNewSession(
                        context.read<auth.AuthProvider>().currentUser?.role ?? auth.UserRole.nurse,
                        null,
                      );
                    },
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.add_comment_outlined, color: Colors.white),
                  )
                : null,
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          );
      },
    );
  }

  Widget _buildTopAppBar() {
    return Container(
      constraints: const BoxConstraints(minHeight: 80),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Page Title with Medical Context
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _navItems[_selectedIndex].label,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (_selectedIndex == 2) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'AI Active',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Consumer<auth.AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Flexible(
                      child: Text(
                        '${'welcome_back_user'.tr} ${authProvider.currentUser?.name ?? 'User'} • ${_getRoleDisplayName(authProvider.currentUser?.role)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Enhanced Global Search Bar
          if (MediaQuery.of(context).size.width > 768) ...[
            Container(
              width: 400,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search patients, documents, or ask AI...',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 1,
                        height: 20,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        MdiIcons.robotOutline,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ),
              ),
            ),
          ],

          // Simple Notifications Button
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'No new notifications',
                    style: GoogleFonts.inter(),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: Stack(
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Simple User Profile
          _buildSimpleUserProfile(),
        ],
      ),
    );
  }

  Widget _buildSimpleUserProfile() {
    return Consumer<auth.AuthProvider>(
      builder: (context, authProvider, child) {
        return PopupMenuButton<String>(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  (authProvider.currentUser?.name.substring(0, 1) ?? 'U').toUpperCase(),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                authProvider.currentUser?.name ?? 'User',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 20),
                  SizedBox(width: 12),
                  Text('Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Settings'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout_outlined, size: 20, color: AppColors.accent),
                  SizedBox(width: 12),
                  Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'logout') {
              authProvider.logout();
            }
            // Handle other menu items as needed
          },
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        items: _navItems.take(5).map((item) => BottomNavigationBarItem(
          icon: Icon(item.icon, size: 24),
          activeIcon: Icon(item.selectedIcon, size: 24),
          label: item.label,
        )).toList(),
      ),
    );
  }

  String _getRoleDisplayName(auth.UserRole? role) {
    switch (role) {
      case auth.UserRole.nurse:
        return 'registered_nurse'.tr;
      case auth.UserRole.doctor:
        return 'medical_doctor'.tr;
      case auth.UserRole.admin:
        return 'administrator'.tr;
      default:
        return 'user'.tr;
    }
  }
}
