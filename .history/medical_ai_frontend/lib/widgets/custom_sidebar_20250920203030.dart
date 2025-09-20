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
      constraints: BoxConstraints(
        minWidth: isCollapsed ? 80 : 280,
        maxWidth: isCollapsed ? 80 : 300,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.95),
          border: Border(
            right: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), width: 1),
          ),
          // Add shadow to make sidebar stand out against background
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(2, 0),
            ),
          ],
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
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: onToggleCollapse,
                          icon: Icon(
                            Icons.menu,
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
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

            // Footer
            if (!isCollapsed)
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Divider(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'v1.0.0',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
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

  Widget _buildNavItem(BuildContext context, NavItem item, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
            color: isSelected 
                ? AppColors.primary.withValues(alpha: 0.15) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1)
                : null,
          ),
          child: isCollapsed
              ? Center(
                  child: Icon(
                    isSelected ? item.selectedIcon : item.icon,
                    color: isSelected 
                        ? AppColors.primary 
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    size: 22,
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
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      size: 22,
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
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}