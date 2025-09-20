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

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.navItems,
    this.isCollapsed = false,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCollapsed ? 80 : 280,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            right: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: isCollapsed
                  ? Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
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
                              color: AppColors.textDark,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: onToggleCollapse,
                          icon: Icon(
                            Icons.menu,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ],
                    ),
            ),

            // Collapse/Expand button for collapsed state
            if (isCollapsed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: IconButton(
                  onPressed: onToggleCollapse,
                  icon: Icon(
                    Icons.menu_open,
                    color: AppColors.textMedium,
                  ),
                ),
              ),

            // Navigation Items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: navItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    final isSelected = selectedIndex == index;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildNavItem(
                        item,
                        isSelected,
                        () => onItemSelected(index),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Footer
            if (!isCollapsed)
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Divider(color: AppColors.border),
                    const SizedBox(height: 16),
                    Text(
                      'v1.0.0',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(NavItem item, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? item.selectedIcon : item.icon,
              color: isSelected ? AppColors.primary : AppColors.textMedium,
              size: 24,
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.primary : AppColors.textMedium,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}