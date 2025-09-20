import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}

class CustomSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<NavItem> navItems;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final bool isDarkMode;

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.navItems,
    this.isCollapsed = false,
    required this.onToggleCollapse,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 80 : 280,
      constraints: BoxConstraints(
        minWidth: isCollapsed ? 80 : 280,
        maxWidth: isCollapsed ? 80 : 300,
      ),
      child: Container(
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('lib/assets/background.png'),
            fit: BoxFit.cover,
            alignment: Alignment.centerLeft,
          ),
          border: Border(
            right: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: _getShadowColor(isDarkMode),
              blurRadius: 10,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Container(
          // Semi-transparent overlay for better readability
          decoration: BoxDecoration(
            gradient: _getOverlayGradient(isDarkMode),
          ),
          child: Column(
            children: [
              // Header with enhanced background
              Container(
                height: 80,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: _getHeaderGradient(isDarkMode),
                ),
                child: isCollapsed
                    ? Center(
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.medical_services_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      )
                    : Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.medical_services_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Medical AI',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: _getDividerColor(isDarkMode),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              textDirection: TextDirection.ltr,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              onPressed: onToggleCollapse,
                              icon: Icon(
                                Icons.menu,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),

              // Collapse/Expand button for collapsed state
              if (isCollapsed)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: onToggleCollapse,
                      icon: Icon(
                        Icons.menu_open,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),

              // Navigation Items
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: navItems.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final isSelected = selectedIndex == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildNavItem(
                          context,
                          item,
                          isSelected,
                          () => onItemSelected(index),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // Footer with enhanced background
              if (!isCollapsed)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: _getHeaderGradient(isDarkMode),
                  ),
                  child: Column(
                    children: [
                      Divider(color: Colors.white.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'v1.0.0',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                          shadows: [
                            Shadow(
                              color: _getDividerColor(isDarkMode),
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
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, NavItem item, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: Colors.white.withValues(alpha: 0.1),
        splashColor: Colors.white.withValues(alpha: 0.15),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: 50,
            minWidth: isCollapsed ? 60 : 220,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isCollapsed ? 14 : 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            gradient: isSelected 
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      AppColors.primary.withValues(alpha: 0.1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 1)
                : null,
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: isCollapsed
              ? Center(
                  child: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    color: isSelected 
                        ? AppColors.primary 
                        : Colors.white.withValues(alpha: 0.9),
                    size: 22,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? item.selectedIcon : item.icon,
                      color: isSelected 
                          ? AppColors.primary 
                          : Colors.white.withValues(alpha: 0.9),
                      size: 22,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        item.label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected 
                              ? AppColors.primary 
                              : Colors.white.withValues(alpha: 0.95),
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        textDirection: TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // Theme helper methods
  static Color _getShadowColor(bool isDarkMode) {
    return isDarkMode ? Colors.black.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2);
  }

  static LinearGradient _getOverlayGradient(bool isDarkMode) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isDarkMode
          ? [
              Colors.black.withValues(alpha: 0.6),
              Colors.black.withValues(alpha: 0.4),
              Colors.black.withValues(alpha: 0.7),
            ]
          : [
              Colors.white.withValues(alpha: 0.8),
              Colors.white.withValues(alpha: 0.6),
              Colors.white.withValues(alpha: 0.9),
            ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  static LinearGradient _getHeaderGradient(bool isDarkMode) {
    return LinearGradient(
      colors: isDarkMode
          ? [
              Colors.black.withValues(alpha: 0.8),
              Colors.black.withValues(alpha: 0.4),
            ]
          : [
              Colors.white.withValues(alpha: 0.9),
              Colors.white.withValues(alpha: 0.6),
            ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  static Color _getDividerColor(bool isDarkMode) {
    return isDarkMode ? Colors.black.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3);
  }

}