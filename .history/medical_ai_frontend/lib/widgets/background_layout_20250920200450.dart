import 'package:flutter/material.dart';

/// Use this widget as the root of your main screen.
/// It applies the PNG background in dark mode, white background in light mode, overlays the sidebar, and allows home widgets to be transparent.
class BackgroundLayout extends StatelessWidget {
  final Widget sidebar;
  final Widget homeContent;
  final bool isDarkMode;

  const BackgroundLayout({
    Key? key,
    required this.sidebar,
    required this.homeContent,
    this.isDarkMode = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-page background - PNG image for dark mode, white for light mode
        Positioned.fill(
          child: isDarkMode
              ? Image.asset(
                  'lib/assets/background.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                )
              : Container(
                  color: Colors.white,
                ),
        ),
        // Main content row: sidebar + home
        Row(
          children: [
            // Sidebar (let it control its own width)
            if (sidebar is! SizedBox)
              sidebar,
            // Home screen area (expands to fill remaining space)
            Expanded(
              child: Container(
                color: Colors.transparent,
                child: homeContent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Example usage:
/// BackgroundLayout(
///   sidebar: CustomSidebar(...),
///   homeContent: DashboardContent(...),
/// )
