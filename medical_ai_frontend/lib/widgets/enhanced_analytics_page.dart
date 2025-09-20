import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';
import 'background_layout.dart';

class EnhancedAnalyticsPage extends StatefulWidget {
  const EnhancedAnalyticsPage({super.key});

  @override
  State<EnhancedAnalyticsPage> createState() => _EnhancedAnalyticsPageState();
}

class _EnhancedAnalyticsPageState extends State<EnhancedAnalyticsPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedTimeRange = '7D';
  String _selectedMetric = 'Consultations';

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
        
        Widget sidebar = const SizedBox.shrink(); // No sidebar for analytics page
        Widget homeContent = FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                  _buildMetricsGrid(),
                const SizedBox(height: 32),
                  _buildChartsSection(),
                const SizedBox(height: 32),
                  _buildUserAnalyticsTable(),
                const SizedBox(height: 32),
                  _buildActivityFeed(),
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

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
      child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                'Analytics Dashboard',
                style: GoogleFonts.inter(
                  fontSize: 32,
                      fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                'Comprehensive insights into system performance and user activity',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppColors.textMedium,
                    ),
                  ),
                ],
              ),
        ),
        _buildTimeRangeSelector(),
                  const SizedBox(width: 16),
        _buildMetricSelector(),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<String>(
        value: _selectedTimeRange,
        onChanged: (value) => setState(() => _selectedTimeRange = value!),
        underline: const SizedBox(),
        items: ['7D', '30D', '90D'].map((range) => 
          DropdownMenuItem(value: range, child: Text(range))
        ).toList(),
      ),
    );
  }

  Widget _buildMetricSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButton<String>(
        value: _selectedMetric,
        onChanged: (value) => setState(() => _selectedMetric = value!),
        underline: const SizedBox(),
        items: ['Consultations', 'Accuracy', 'Users', 'Response Time'].map((metric) => 
          DropdownMenuItem(value: metric, child: Text(metric))
        ).toList(),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    final metrics = [
      {'title': 'Total Consultations', 'value': '2,847', 'change': '+12.5%', 'icon': Icons.medical_services, 'color': AppColors.primary},
      {'title': 'AI Accuracy Rate', 'value': '94.2%', 'change': '+2.1%', 'icon': Icons.psychology, 'color': Colors.green},
      {'title': 'Active Users', 'value': '156', 'change': '+8.3%', 'icon': Icons.people, 'color': Colors.blue},
      {'title': 'Avg Response Time', 'value': '1.2s', 'change': '-15.2%', 'icon': Icons.speed, 'color': Colors.orange},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMobile ? 2 : 4,
            childAspectRatio: isMobile ? 1.8 : 2.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: metrics.length,
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return _buildMetricCard(metric);
          },
        );
      },
    );
  }

  Widget _buildMetricCard(Map<String, dynamic> metric) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: (metric['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  metric['icon'] as IconData,
                  color: metric['color'] as Color,
                  size: 14,
              ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  metric['change'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            metric['value'] as String,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            metric['title'] as String,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textMedium,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        if (isMobile) {
          return Column(
        children: [
              _buildLineChart(),
              const SizedBox(height: 16),
              _buildPieChart(),
            ],
          );
        }
        return Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildLineChart(),
              ),
              const SizedBox(width: 16),
              Expanded(
              flex: 1,
                child: _buildPieChart(),
              ),
            ],
        );
      },
    );
  }

  Widget _buildLineChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consultation Trends',
            style: GoogleFonts.inter(
              fontSize: 18,
                  fontWeight: FontWeight.bold,
              color: AppColors.textDark,
                ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
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
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Performance',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: 75,
                    title: 'Accurate',
                    color: Colors.green,
                    radius: 60,
                    titleStyle: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 15,
                    title: 'Review',
                    color: Colors.orange,
                    radius: 60,
                    titleStyle: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                  ),
                  PieChartSectionData(
                    value: 10,
                    title: 'Incorrect',
                    color: Colors.red,
                    radius: 60,
                    titleStyle: GoogleFonts.inter(fontSize: 12, color: Colors.white),
                  ),
                ],
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAnalyticsTable() {
    final users = [
      {'name': 'Dr. Sarah Johnson', 'consultations': 45, 'accuracy': '96.2%', 'lastActive': '2 min ago'},
      {'name': 'Nurse Mike Chen', 'consultations': 38, 'accuracy': '94.1%', 'lastActive': '5 min ago'},
      {'name': 'Dr. Emily Davis', 'consultations': 42, 'accuracy': '97.8%', 'lastActive': '1 min ago'},
      {'name': 'Nurse Lisa Wang', 'consultations': 31, 'accuracy': '93.5%', 'lastActive': '8 min ago'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top Performing Users',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
            },
        children: [
              TableRow(
        decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
          children: [
                  _buildTableHeader('User'),
                  _buildTableHeader('Consultations'),
                  _buildTableHeader('Accuracy'),
                  _buildTableHeader('Last Active'),
                ],
              ),
              ...users.map((user) => TableRow(
      children: [
                  _buildTableCell(user['name'] as String),
                  _buildTableCell(user['consultations'].toString()),
                  _buildTableCell(user['accuracy'] as String),
                  _buildTableCell(user['lastActive'] as String),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.textMedium,
        ),
      ),
    );
  }

  Widget _buildActivityFeed() {
    final activities = [
      {'action': 'New consultation started', 'user': 'Dr. Sarah Johnson', 'time': '2 min ago', 'icon': Icons.medical_services},
      {'action': 'AI model updated', 'user': 'System', 'time': '5 min ago', 'icon': Icons.update},
      {'action': 'Document uploaded', 'user': 'Nurse Mike Chen', 'time': '8 min ago', 'icon': Icons.upload_file},
      {'action': 'Consultation completed', 'user': 'Dr. Emily Davis', 'time': '12 min ago', 'icon': Icons.check_circle},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
            'Real-time Activity Feed',
            style: GoogleFonts.inter(
              fontSize: 18,
                  fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 20),
          ...activities.map((activity) => _buildActivityItem(activity)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: AppColors.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['action'] as String,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  '${activity['user']} • ${activity['time']}',
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
}

