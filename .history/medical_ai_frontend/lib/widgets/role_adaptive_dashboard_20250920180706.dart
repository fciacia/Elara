import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

import '../utils/app_colors.dart';
import '../providers/auth_provider.dart' as auth;

class RoleAdaptiveDashboard extends StatefulWidget {
  const RoleAdaptiveDashboard({super.key});

  @override
  State<RoleAdaptiveDashboard> createState() => _RoleAdaptiveDashboardState();
}

class _RoleAdaptiveDashboardState extends State<RoleAdaptiveDashboard>
    with TickerProviderStateMixin {
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
    return Consumer<auth.AuthProvider>(
      builder: (context, authProvider, child) {
        final userRole = authProvider.currentUser?.role ?? auth.UserRole.nurse;
        
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(userRole),
                  const SizedBox(height: 32),
                  _buildQuickActions(userRole),
                  const SizedBox(height: 32),
                  _buildRoleSpecificContent(userRole),
                  const SizedBox(height: 32),
                  _buildAnalyticsSection(userRole),
                  const SizedBox(height: 32),
                  _buildRecentActivity(userRole),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHeader(auth.UserRole userRole) {
    return Consumer<auth.AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getWelcomeMessage(userRole),
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      authProvider.currentUser?.name ?? 'User',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getRoleIcon(userRole),
                            size: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getRoleDisplayName(userRole),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getRoleIcon(userRole),
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(auth.UserRole userRole) {
    final actions = _getQuickActions(userRole);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(action);
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(QuickAction action) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                action.color.withValues(alpha: 0.1),
                action.color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                action.title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSpecificContent(auth.UserRole userRole) {
    switch (userRole) {
      case auth.UserRole.nurse:
        return _buildNurseDashboard();
      case auth.UserRole.doctor:
        return _buildDoctorDashboard();
      case auth.UserRole.admin:
        return _buildAdminDashboard();
    }
  }

  Widget _buildNurseDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient Care',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Assigned Patients',
                '12',
                'All stable',
                Colors.green,
                MdiIcons.accountHeart,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Medications Due',
                '5',
                'Next 2 hours',
                Colors.orange,
                MdiIcons.pill,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildNurseTasks(),
      ],
    );
  }

  Widget _buildDoctorDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Patient Management',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Active Patients',
                '24',
                '+3 this week',
                Colors.blue,
                MdiIcons.accountGroup,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Pending Reviews',
                '8',
                '2 urgent',
                Colors.orange,
                MdiIcons.clockAlert,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPatientList(),
      ],
    );
  }

  Widget _buildAdminDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Overview',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Documents',
                '1,247',
                '+12% this month',
                Colors.green,
                MdiIcons.fileDocument,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'AI Processing',
                '98.5%',
                'Success rate',
                Colors.purple,
                MdiIcons.robot,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSystemHealth(),
      ],
    );
  }

  Widget _buildHealthMetricCard(String title, String value, String status, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(
                  Icons.trending_up,
                  color: Colors.green,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Patients',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildPatientItem('Ahmad Ibrahim', 'Diabetes Management', 'Stable', Colors.green),
            _buildPatientItem('Sarah Lee', 'Post-Surgery Care', 'Monitoring', Colors.orange),
            _buildPatientItem('Dr. Rahman', 'Routine Checkup', 'Completed', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientItem(String name, String condition, String status, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(
              name.substring(0, 1),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  condition,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealth() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Health',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildHealthIndicator('AI Processing', 98.5, Colors.green),
            _buildHealthIndicator('Document Storage', 87.2, Colors.blue),
            _buildHealthIndicator('User Activity', 94.8, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${value.toStringAsFixed(1)}%',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildNurseTasks() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Tasks',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildTaskItem('Medication Round - Ward A', '09:00 AM', false),
            _buildTaskItem('Vital Signs Check', '10:30 AM', false),
            _buildTaskItem('Patient Assessment', '02:00 PM', true),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(String task, String time, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.grey.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              task,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isCompleted ? AppColors.textLight : AppColors.textDark,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsSection(auth.UserRole userRole) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics & Insights',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: _buildAnalyticsChart(userRole),
        ),
      ],
    );
  }

  Widget _buildAnalyticsChart(auth.UserRole userRole) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: [
                  const FlSpot(0, 3),
                  const FlSpot(1, 1),
                  const FlSpot(2, 4),
                  const FlSpot(3, 2),
                  const FlSpot(4, 5),
                  const FlSpot(5, 3),
                  const FlSpot(6, 4),
                ],
                isCurved: true,
                color: AppColors.primary,
                barWidth: 3,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(auth.UserRole userRole) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Activity',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildActivityItem(
                  MdiIcons.fileDocument,
                  'New lab report uploaded',
                  '2 minutes ago',
                  Colors.blue,
                ),
                _buildActivityItem(
                  MdiIcons.robot,
                  'AI analysis completed',
                  '5 minutes ago',
                  Colors.green,
                ),
                _buildActivityItem(
                  MdiIcons.chat,
                  'New chat session started',
                  '10 minutes ago',
                  Colors.purple,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getWelcomeMessage(auth.UserRole userRole) {
    switch (userRole) {
      case auth.UserRole.nurse:
        return 'Welcome to Medical AI';
      case auth.UserRole.doctor:
        return 'Good morning, Doctor';
      case auth.UserRole.admin:
        return 'System Overview';
    }
  }

  IconData _getRoleIcon(auth.UserRole userRole) {
    switch (userRole) {
      case auth.UserRole.nurse:
        return MdiIcons.accountHeart;
      case auth.UserRole.doctor:
        return MdiIcons.doctor;
      case auth.UserRole.admin:
        return MdiIcons.shieldAccount;
    }
  }

  String _getRoleDisplayName(auth.UserRole userRole) {
    switch (userRole) {
      case auth.UserRole.nurse:
        return 'Registered Nurse';
      case auth.UserRole.doctor:
        return 'Medical Doctor';
      case auth.UserRole.admin:
        return 'Administrator';
    }
  }

  List<QuickAction> _getQuickActions(auth.UserRole userRole) {
    switch (userRole) {
      case auth.UserRole.nurse:
        return [
          QuickAction(
            title: 'Patient Care',
            icon: MdiIcons.accountHeart,
            color: Colors.blue,
            onTap: () {},
          ),
          QuickAction(
            title: 'Medications',
            icon: MdiIcons.pill,
            color: Colors.green,
            onTap: () {},
          ),
          QuickAction(
            title: 'Vital Signs',
            icon: MdiIcons.heartPulse,
            color: Colors.red,
            onTap: () {},
          ),
          QuickAction(
            title: 'Documentation',
            icon: MdiIcons.fileDocument,
            color: Colors.orange,
            onTap: () {},
          ),
        ];
      case auth.UserRole.doctor:
        return [
          QuickAction(
            title: 'Review Patients',
            icon: MdiIcons.accountGroup,
            color: Colors.blue,
            onTap: () {},
          ),
          QuickAction(
            title: 'AI Analysis',
            icon: MdiIcons.brain,
            color: Colors.purple,
            onTap: () {},
          ),
          QuickAction(
            title: 'Prescriptions',
            icon: MdiIcons.prescription,
            color: Colors.green,
            onTap: () {},
          ),
          QuickAction(
            title: 'Reports',
            icon: MdiIcons.fileChart,
            color: Colors.orange,
            onTap: () {},
          ),
        ];
      case auth.UserRole.admin:
        return [
          QuickAction(
            title: 'System Health',
            icon: MdiIcons.server,
            color: Colors.blue,
            onTap: () {},
          ),
          QuickAction(
            title: 'User Management',
            icon: MdiIcons.accountCog,
            color: Colors.green,
            onTap: () {},
          ),
          QuickAction(
            title: 'Analytics',
            icon: MdiIcons.chartBox,
            color: Colors.purple,
            onTap: () {},
          ),
          QuickAction(
            title: 'Settings',
            icon: MdiIcons.cog,
            color: Colors.orange,
            onTap: () {},
          ),
        ];
    }
  }
}

class QuickAction {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickAction({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
