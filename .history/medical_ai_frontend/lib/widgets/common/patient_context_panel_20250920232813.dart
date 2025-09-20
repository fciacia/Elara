import 'package:flutter/material.dart';import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../utils/app_colors.dart';import '../../utils/app_theme.dart';

import '../common/app_components.dart';

class PatientContextPanel extends StatefulWidget {

  final String patientId;class PatientContextPanel extends StatefulWidget {

    final String patientId;

  const PatientContextPanel({  

    Key? key,  const PatientContextPanel({

    required this.patientId,    Key? key,

  }) : super(key: key);    required this.patientId,

  }) : super(key: key);

  @override

  State<PatientContextPanel> createState() => _PatientContextPanelState();  @override

}  State<PatientContextPanel> createState() => _PatientContextPanelState();

}

class _PatientContextPanelState extends State<PatientContextPanel>

    with SingleTickerProviderStateMixin {class _PatientContextPanelState extends State<PatientContextPanel>

  late TabController _tabController;    with SingleTickerProviderStateMixin {

    late TabController _tabController;

  @override  

  void initState() {  @override

    super.initState();  void initState() {

    _tabController = TabController(length: 4, vsync: this);    super.initState();

  }    _tabController = TabController(length: 4, vsync: this);

  }

  @override

  void dispose() {  @override

    _tabController.dispose();  void dispose() {

    super.dispose();    _tabController.dispose();

  }    super.dispose();

  }

  @override

  Widget build(BuildContext context) {  @override

    return Container(  Widget build(BuildContext context) {

      width: double.infinity,    return Container(

      height: double.infinity,      width: 380,

      decoration: BoxDecoration(      height: double.infinity,

        color: Theme.of(context).colorScheme.surface,      decoration: BoxDecoration(

        border: Border(        color: AppTheme.surfaceColor,

          left: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), width: 1),        border: Border(

        ),          left: BorderSide(color: AppTheme.dividerColor, width: 1),

      ),        ),

      child: Column(      ),

        children: [      child: Column(

          _buildHeader(),        children: [

          _buildPatientInfo(),          _buildHeader(),

          _buildTabBar(),          _buildPatientInfo(),

          Expanded(          _buildTabBar(),

            child: TabBarView(          Expanded(

              controller: _tabController,            child: TabBarView(

              children: [              controller: _tabController,

                _buildOverviewTab(),              children: [

                _buildVitalsTab(),                _buildOverviewTab(),

                _buildMedicationsTab(),                _buildVitalsTab(),

                _buildNotesTab(),                _buildMedicationsTab(),

              ],                _buildNotesTab(),

            ),              ],

          ),            ),

        ],          ),

      ),        ],

    );      ),

  }    );

  }

  Widget _buildHeader() {

    return Container(  Widget _buildHeader() {

      padding: const EdgeInsets.all(16),    return Container(

      decoration: BoxDecoration(      padding: const EdgeInsets.all(16),

        color: Theme.of(context).colorScheme.surface,      decoration: BoxDecoration(

        border: Border(        border: Border(

          bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), width: 1),          bottom: BorderSide(color: AppTheme.dividerColor, width: 1),

        ),        ),

      ),      ),

      child: Row(      child: Row(

        children: [        children: [

          Icon(          Icon(

            MdiIcons.account,            MdiIcons.account,

            size: 20,            size: 20,

            color: AppColors.primary,            color: AppTheme.primaryColor,

          ),          ),

          const SizedBox(width: 8),          const SizedBox(width: 8),

          Text(          Text(

            'Patient Context',            'Patient Context',

            style: Theme.of(context).textTheme.titleMedium?.copyWith(            style: AppTheme.titleSmall.copyWith(

              fontWeight: FontWeight.w600,              color: AppTheme.textPrimary,

              color: Theme.of(context).colorScheme.onSurface,              fontWeight: FontWeight.w600,

            ),            ),

          ),          ),

        ],          const Spacer(),

      ),          IconButton(

    );            onPressed: () {},

  }            icon: Icon(

              MdiIcons.refresh,

  Widget _buildPatientInfo() {              size: 16,

    return Container(              color: AppTheme.textTertiary,

      margin: const EdgeInsets.all(16),            ),

      padding: const EdgeInsets.all(16),            padding: EdgeInsets.zero,

      decoration: BoxDecoration(            constraints: const BoxConstraints(),

        gradient: LinearGradient(          ),

          colors: [        ],

            AppColors.primary.withValues(alpha: 0.1),      ),

            AppColors.primary.withValues(alpha: 0.05),    );

          ],  }

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,  Widget _buildPatientInfo() {

        ),    return Container(

        borderRadius: BorderRadius.circular(12),      margin: const EdgeInsets.all(16),

      ),      padding: const EdgeInsets.all(16),

      child: Row(      decoration: AppTheme.primaryGradientDecoration,

        children: [      child: Row(

          Container(        children: [

            width: 48,          CircleAvatar(

            height: 48,            radius: 24,

            decoration: BoxDecoration(            backgroundColor: Colors.white.withOpacity(0.2),

              gradient: LinearGradient(            child: Text(

                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],              'ES',

                begin: Alignment.topLeft,              style: AppTheme.titleSmall.copyWith(

                end: Alignment.bottomRight,                color: Colors.white,

              ),                fontWeight: FontWeight.w700,

              borderRadius: BorderRadius.circular(12),              ),

            ),            ),

            child: const Center(          ),

              child: Text(          const SizedBox(width: 12),

                'EC',          Expanded(

                style: TextStyle(            child: Column(

                  color: Colors.white,              crossAxisAlignment: CrossAxisAlignment.start,

                  fontWeight: FontWeight.w600,              children: [

                  fontSize: 16,                Text(

                ),                  'Emily Chen',

              ),                  style: AppTheme.titleMedium.copyWith(

            ),                    color: Colors.white,

          ),                    fontWeight: FontWeight.w600,

          const SizedBox(width: 12),                  ),

          Expanded(                ),

            child: Column(                Text(

              crossAxisAlignment: CrossAxisAlignment.start,                  'ID: P12345 • Age: 34',

              children: [                  style: AppTheme.bodySmall.copyWith(

                Text(                    color: Colors.white.withOpacity(0.9),

                  'Emily Chen',                  ),

                  style: Theme.of(context).textTheme.titleMedium?.copyWith(                ),

                    color: Theme.of(context).colorScheme.onSurface,              ],

                    fontWeight: FontWeight.w600,            ),

                  ),          ),

                ),          StatusBadge(

                Text(            text: 'Active',

                  'ID: P12345 • Age: 34',            color: AppTheme.successColor,

                  style: Theme.of(context).textTheme.bodySmall?.copyWith(            type: BadgeType.success,

                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),          ),

                  ),        ],

                ),      ),

              ],    );

            ),  }

          ),

          Container(  Widget _buildTabBar() {

            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),    return Container(

            decoration: BoxDecoration(      decoration: BoxDecoration(

              color: Colors.green.withValues(alpha: 0.2),        border: Border(

              borderRadius: BorderRadius.circular(8),          bottom: BorderSide(color: AppTheme.dividerColor, width: 1),

            ),        ),

            child: Text(      ),

              'Stable',      child: TabBar(

              style: Theme.of(context).textTheme.labelSmall?.copyWith(        controller: _tabController,

                color: Colors.green[700],        isScrollable: false,

                fontWeight: FontWeight.w500,        labelColor: AppTheme.primaryColor,

              ),        unselectedLabelColor: AppTheme.textTertiary,

            ),        labelStyle: AppTheme.labelMedium.copyWith(fontWeight: FontWeight.w600),

          ),        unselectedLabelStyle: AppTheme.labelMedium,

        ],        indicatorColor: AppTheme.primaryColor,

      ),        indicatorWeight: 2,

    );        tabs: const [

  }          Tab(text: 'Overview'),

          Tab(text: 'Vitals'),

  Widget _buildTabBar() {          Tab(text: 'Meds'),

    return Container(          Tab(text: 'Notes'),

      decoration: BoxDecoration(        ],

        border: Border(      ),

          bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), width: 1),    );

        ),  }

      ),

      child: TabBar(  Widget _buildOverviewTab() {

        controller: _tabController,    return SingleChildScrollView(

        isScrollable: false,      padding: const EdgeInsets.all(16),

        labelColor: AppColors.primary,      child: Column(

        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),        crossAxisAlignment: CrossAxisAlignment.start,

        indicatorColor: AppColors.primary,        children: [

        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),          _buildInfoSection(

        unselectedLabelStyle: Theme.of(context).textTheme.labelMedium,            'Personal Information',

        tabs: const [            [

          Tab(text: 'Overview'),              _buildInfoRow('Gender', 'Female'),

          Tab(text: 'Vitals'),              _buildInfoRow('Date of Birth', 'March 15, 1990'),

          Tab(text: 'Meds'),              _buildInfoRow('Blood Type', 'A+'),

          Tab(text: 'Notes'),              _buildInfoRow('Phone', '+60 12-345 6789'),

        ],              _buildInfoRow('Emergency Contact', 'John Chen (Husband)'),

      ),            ],

    );          ),

  }          const SizedBox(height: 16),

          _buildInfoSection(

  Widget _buildOverviewTab() {            'Medical History',

    return SingleChildScrollView(            [

      padding: const EdgeInsets.all(16),              _buildInfoRow('Allergies', 'Penicillin, Shellfish'),

      child: Column(              _buildInfoRow('Chronic Conditions', 'Hypertension'),

        crossAxisAlignment: CrossAxisAlignment.start,              _buildInfoRow('Previous Surgeries', 'Appendectomy (2018)'),

        children: [              _buildInfoRow('Family History', 'Diabetes, Heart Disease'),

          _buildSectionHeader('Personal Information'),            ],

          const SizedBox(height: 12),          ),

          _buildInfoRow('Date of Birth', 'March 15, 1991'),          const SizedBox(height: 16),

          _buildInfoRow('Gender', 'Female'),          _buildInfoSection(

          _buildInfoRow('Blood Type', 'O+'),            'Insurance & Coverage',

          _buildInfoRow('Emergency Contact', 'John Chen (Husband)'),            [

          const SizedBox(height: 20),              _buildInfoRow('Insurance Provider', 'Great Eastern'),

          _buildSectionHeader('Allergies & Warnings'),              _buildInfoRow('Policy Number', 'GE123456789'),

          const SizedBox(height: 12),              _buildInfoRow('Coverage Type', 'Premium Family'),

          _buildWarningCard('Drug Allergies', 'Penicillin, Sulfa drugs', Colors.red),              _buildInfoRow('Validity', 'Valid until Dec 2024'),

          const SizedBox(height: 8),            ],

          _buildWarningCard('Medical Conditions', 'Mild Asthma', Colors.orange),          ),

          const SizedBox(height: 20),        ],

          _buildSectionHeader('Insurance Information'),      ),

          const SizedBox(height: 12),    );

          _buildInfoRow('Provider', 'Blue Cross Blue Shield'),  }

          _buildInfoRow('Policy Number', 'BC12345678'),

          _buildInfoRow('Group Number', 'GRP001'),  Widget _buildVitalsTab() {

        ],    return SingleChildScrollView(

      ),      padding: const EdgeInsets.all(16),

    );      child: Column(

  }        children: [

          Row(

  Widget _buildVitalsTab() {            children: [

    return SingleChildScrollView(              Expanded(

      padding: const EdgeInsets.all(16),                child: MetricCard(

      child: Column(                  title: 'Heart Rate',

        crossAxisAlignment: CrossAxisAlignment.start,                  value: '72',

        children: [                  unit: 'bpm',

          _buildSectionHeader('Current Vitals'),                  icon: MdiIcons.heart,

          const SizedBox(height: 12),                  trendType: TrendType.stable,

          _buildVitalCard('Blood Pressure', '118/76', 'mmHg', Colors.green, MdiIcons.heart),                  color: AppTheme.successColor,

          const SizedBox(height: 8),                ),

          _buildVitalCard('Heart Rate', '72', 'bpm', Colors.green, MdiIcons.heartPulse),              ),

          const SizedBox(height: 8),              const SizedBox(width: 12),

          _buildVitalCard('Temperature', '98.6', '°F', Colors.green, MdiIcons.thermometer),              Expanded(

          const SizedBox(height: 8),                child: MetricCard(

          _buildVitalCard('Respiratory Rate', '16', 'rpm', Colors.green, MdiIcons.lungs),                  title: 'Temperature',

          const SizedBox(height: 8),                  value: '36.5',

          _buildVitalCard('Oxygen Saturation', '98', '%', Colors.green, MdiIcons.waterPercent),                  unit: '°C',

          const SizedBox(height: 20),                  icon: MdiIcons.thermometer,

          _buildSectionHeader('Recent Trends'),                  trendType: TrendType.stable,

          const SizedBox(height: 12),                  color: AppTheme.infoColor,

          _buildTrendCard('Blood Pressure', 'Stable', 'Last 7 days', Colors.green),                ),

          _buildTrendCard('Weight', '135 lbs', 'No change', Colors.blue),              ),

        ],            ],

      ),          ),

    );          const SizedBox(height: 12),

  }          Row(

            children: [

  Widget _buildMedicationsTab() {              Expanded(

    return SingleChildScrollView(                child: MetricCard(

      padding: const EdgeInsets.all(16),                  title: 'Oxygen',

      child: Column(                  value: '98',

        crossAxisAlignment: CrossAxisAlignment.start,                  unit: '%',

        children: [                  icon: MdiIcons.lungs,

          _buildSectionHeader('Current Medications'),                  trendType: TrendType.up,

          const SizedBox(height: 12),                  color: AppTheme.successColor,

          _buildMedicationCard('Albuterol Inhaler', '90 mcg, 2 puffs as needed', 'Active'),                ),

          const SizedBox(height: 8),              ),

          _buildMedicationCard('Vitamin D3', '1000 IU daily', 'Active'),              const SizedBox(width: 12),

          const SizedBox(height: 8),              Expanded(

          _buildMedicationCard('Birth Control', 'Daily', 'Active'),                child: MetricCard(

          const SizedBox(height: 20),                  title: 'Resp. Rate',

          _buildSectionHeader('Recent Changes'),                  value: '16',

          const SizedBox(height: 12),                  unit: '/min',

          _buildMedicationChangeCard('Added', 'Vitamin D3', '2 weeks ago'),                  icon: MdiIcons.airFilter,

          _buildMedicationChangeCard('Discontinued', 'Ibuprofen', '1 month ago'),                  trendType: TrendType.stable,

        ],                  color: AppTheme.infoColor,

      ),                ),

    );              ),

  }            ],

          ),

  Widget _buildNotesTab() {          const SizedBox(height: 16),

    return SingleChildScrollView(          _buildVitalChart(),

      padding: const EdgeInsets.all(16),          const SizedBox(height: 16),

      child: Column(          _buildVitalHistory(),

        crossAxisAlignment: CrossAxisAlignment.start,        ],

        children: [      ),

          _buildSectionHeader('Recent Notes'),    );

          const SizedBox(height: 12),  }

          _buildNoteCard(

            'Annual Checkup',  Widget _buildMedicationsTab() {

            'Patient reports feeling well. No new concerns. Asthma well controlled with current inhaler. Recommends continuing current care plan.',    return SingleChildScrollView(

            'Dr. Sarah Johnson',      padding: const EdgeInsets.all(16),

            'September 15, 2025',      child: Column(

          ),        crossAxisAlignment: CrossAxisAlignment.start,

          const SizedBox(height: 12),        children: [

          _buildNoteCard(          Text(

            'Lab Results Review',            'Current Medications',

            'All lab values within normal limits. Vitamin D levels improved since starting supplementation.',            style: AppTheme.titleSmall.copyWith(

            'Dr. Sarah Johnson',              fontWeight: FontWeight.w600,

            'September 1, 2025',            ),

          ),          ),

          const SizedBox(height: 12),          const SizedBox(height: 12),

          _buildNoteCard(          _buildMedicationCard(

            'Routine Follow-up',            'Lisinopril',

            'Patient doing well. No acute concerns. Continue current medications. Schedule next routine visit in 6 months.',            '10mg',

            'Dr. Sarah Johnson',            'Once daily',

            'August 10, 2025',            'Hypertension',

          ),            AppTheme.dangerColor,

        ],          ),

      ),          const SizedBox(height: 8),

    );          _buildMedicationCard(

  }            'Metformin',

            '500mg',

  Widget _buildSectionHeader(String title) {            'Twice daily',

    return Text(            'Diabetes prevention',

      title,            AppTheme.warningColor,

      style: Theme.of(context).textTheme.titleSmall?.copyWith(          ),

        fontWeight: FontWeight.w600,          const SizedBox(height: 8),

        color: Theme.of(context).colorScheme.onSurface,          _buildMedicationCard(

      ),            'Vitamin D3',

    );            '1000 IU',

  }            'Once daily',

            'Vitamin deficiency',

  Widget _buildInfoRow(String label, String value) {            AppTheme.successColor,

    return Padding(          ),

      padding: const EdgeInsets.symmetric(vertical: 4),          const SizedBox(height: 24),

      child: Row(          Text(

        crossAxisAlignment: CrossAxisAlignment.start,            'Recent Prescriptions',

        children: [            style: AppTheme.titleSmall.copyWith(

          SizedBox(              fontWeight: FontWeight.w600,

            width: 120,            ),

            child: Text(          ),

              label,          const SizedBox(height: 12),

              style: Theme.of(context).textTheme.bodySmall?.copyWith(          _buildPrescriptionHistory(),

                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),        ],

              ),      ),

            ),    );

          ),  }

          Expanded(

            child: Text(  Widget _buildNotesTab() {

              value,    return SingleChildScrollView(

              style: Theme.of(context).textTheme.bodySmall?.copyWith(      padding: const EdgeInsets.all(16),

                color: Theme.of(context).colorScheme.onSurface,      child: Column(

                fontWeight: FontWeight.w500,        crossAxisAlignment: CrossAxisAlignment.start,

              ),        children: [

            ),          Row(

          ),            children: [

        ],              Text(

      ),                'Clinical Notes',

    );                style: AppTheme.titleSmall.copyWith(

  }                  fontWeight: FontWeight.w600,

                ),

  Widget _buildWarningCard(String title, String content, Color color) {              ),

    return Container(              const Spacer(),

      padding: const EdgeInsets.all(12),              AppButton(

      decoration: BoxDecoration(                text: 'Add Note',

        color: color.withValues(alpha: 0.1),                type: ButtonType.secondary,

        borderRadius: BorderRadius.circular(8),                size: ButtonSize.small,

        border: Border.all(color: color.withValues(alpha: 0.3)),                icon: MdiIcons.plus,

      ),                onPressed: () {},

      child: Row(              ),

        children: [            ],

          Icon(          ),

            MdiIcons.alertCircle,          const SizedBox(height: 16),

            size: 16,          _buildNoteCard(

            color: color,            'Routine Checkup',

          ),            'Patient reports feeling well overall. Blood pressure controlled with current medication...',

          const SizedBox(width: 8),            'Dr. Sarah Johnson',

          Expanded(            'Today, 2:30 PM',

            child: Column(          ),

              crossAxisAlignment: CrossAxisAlignment.start,          const SizedBox(height: 12),

              children: [          _buildNoteCard(

                Text(            'Follow-up Visit',

                  title,            'Blood work results reviewed. All values within normal range. Continue current treatment...',

                  style: Theme.of(context).textTheme.labelMedium?.copyWith(            'Dr. Michael Wong',

                    fontWeight: FontWeight.w600,            'Yesterday, 10:15 AM',

                    color: color,          ),

                  ),          const SizedBox(height: 12),

                ),          _buildNoteCard(

                Text(            'Initial Consultation',

                  content,            'New patient presenting with mild hypertension. Family history of cardiovascular disease...',

                  style: Theme.of(context).textTheme.bodySmall?.copyWith(            'Dr. Sarah Johnson',

                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),            '3 days ago, 4:45 PM',

                  ),          ),

                ),        ],

              ],      ),

            ),    );

          ),  }

        ],

      ),  Widget _buildInfoSection(String title, List<Widget> children) {

    );    return AppCard(

  }      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

  Widget _buildVitalCard(String title, String value, String unit, Color color, IconData icon) {        children: [

    return Container(          SectionHeader(title: title),

      padding: const EdgeInsets.all(12),          const SizedBox(height: 12),

      decoration: BoxDecoration(          ...children,

        color: color.withValues(alpha: 0.1),        ],

        borderRadius: BorderRadius.circular(8),      ),

      ),    );

      child: Row(  }

        children: [

          Container(  Widget _buildInfoRow(String label, String value) {

            padding: const EdgeInsets.all(8),    return Padding(

            decoration: BoxDecoration(      padding: const EdgeInsets.symmetric(vertical: 4),

              color: color.withValues(alpha: 0.2),      child: Row(

              borderRadius: BorderRadius.circular(6),        crossAxisAlignment: CrossAxisAlignment.start,

            ),        children: [

            child: Icon(          SizedBox(

              icon,            width: 100,

              size: 16,            child: Text(

              color: color,              label,

            ),              style: AppTheme.bodySmall.copyWith(

          ),                color: AppTheme.textTertiary,

          const SizedBox(width: 12),              ),

          Expanded(            ),

            child: Column(          ),

              crossAxisAlignment: CrossAxisAlignment.start,          Expanded(

              children: [            child: Text(

                Text(              value,

                  title,              style: AppTheme.bodySmall.copyWith(

                  style: Theme.of(context).textTheme.bodySmall?.copyWith(                color: AppTheme.textPrimary,

                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),                fontWeight: FontWeight.w500,

                  ),              ),

                ),            ),

                Row(          ),

                  children: [        ],

                    Text(      ),

                      value,    );

                      style: Theme.of(context).textTheme.titleMedium?.copyWith(  }

                        fontWeight: FontWeight.w600,

                        color: color,  Widget _buildVitalChart() {

                      ),    return AppCard(

                    ),      child: Column(

                    const SizedBox(width: 4),        crossAxisAlignment: CrossAxisAlignment.start,

                    Text(        children: [

                      unit,          SectionHeader(title: 'Vital Trends (7 days)'),

                      style: Theme.of(context).textTheme.bodySmall?.copyWith(          const SizedBox(height: 16),

                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),          Container(

                      ),            height: 120,

                    ),            decoration: BoxDecoration(

                  ],              color: AppTheme.backgroundColor,

                ),              borderRadius: BorderRadius.circular(8),

              ],            ),

            ),            child: Center(

          ),              child: Column(

        ],                mainAxisAlignment: MainAxisAlignment.center,

      ),                children: [

    );                  Icon(

  }                    MdiIcons.chartLine,

                    size: 32,

  Widget _buildTrendCard(String title, String value, String trend, Color color) {                    color: AppTheme.textTertiary,

    return Container(                  ),

      margin: const EdgeInsets.only(bottom: 8),                  const SizedBox(height: 8),

      padding: const EdgeInsets.all(12),                  Text(

      decoration: BoxDecoration(                    'Vital Trends Chart',

        color: Theme.of(context).colorScheme.surface,                    style: AppTheme.bodySmall.copyWith(

        borderRadius: BorderRadius.circular(8),                      color: AppTheme.textTertiary,

        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),                    ),

      ),                  ),

      child: Row(                ],

        mainAxisAlignment: MainAxisAlignment.spaceBetween,              ),

        children: [            ),

          Column(          ),

            crossAxisAlignment: CrossAxisAlignment.start,        ],

            children: [      ),

              Text(    );

                title,  }

                style: Theme.of(context).textTheme.bodyMedium?.copyWith(

                  fontWeight: FontWeight.w500,  Widget _buildVitalHistory() {

                  color: Theme.of(context).colorScheme.onSurface,    return AppCard(

                ),      child: Column(

              ),        crossAxisAlignment: CrossAxisAlignment.start,

              Text(        children: [

                trend,          SectionHeader(title: 'Recent Readings'),

                style: Theme.of(context).textTheme.bodySmall?.copyWith(          const SizedBox(height: 12),

                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),          _buildVitalHistoryItem('Blood Pressure', '120/80 mmHg', '2 hours ago'),

                ),          _buildVitalHistoryItem('Weight', '65.2 kg', '1 day ago'),

              ),          _buildVitalHistoryItem('Height', '165 cm', '1 week ago'),

            ],        ],

          ),      ),

          Text(    );

            value,  }

            style: Theme.of(context).textTheme.titleSmall?.copyWith(

              fontWeight: FontWeight.w600,  Widget _buildVitalHistoryItem(String type, String value, String time) {

              color: color,    return Container(

            ),      padding: const EdgeInsets.symmetric(vertical: 8),

          ),      decoration: BoxDecoration(

        ],        border: Border(

      ),          bottom: BorderSide(

    );            color: AppTheme.dividerColor.withOpacity(0.5),

  }            width: 0.5,

          ),

  Widget _buildMedicationCard(String name, String dosage, String status) {        ),

    final statusColor = status == 'Active' ? Colors.green : Colors.orange;      ),

          child: Row(

    return Container(        children: [

      margin: const EdgeInsets.only(bottom: 8),          Expanded(

      padding: const EdgeInsets.all(12),            flex: 2,

      decoration: BoxDecoration(            child: Text(

        color: Theme.of(context).colorScheme.surface,              type,

        borderRadius: BorderRadius.circular(8),              style: AppTheme.bodySmall.copyWith(

        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),                color: AppTheme.textPrimary,

      ),              ),

      child: Row(            ),

        children: [          ),

          Container(          Expanded(

            width: 8,            flex: 2,

            height: 8,            child: Text(

            decoration: BoxDecoration(              value,

              color: statusColor,              style: AppTheme.bodySmall.copyWith(

              shape: BoxShape.circle,                color: AppTheme.textPrimary,

            ),                fontWeight: FontWeight.w600,

          ),              ),

          const SizedBox(width: 12),            ),

          Expanded(          ),

            child: Column(          Expanded(

              crossAxisAlignment: CrossAxisAlignment.start,            child: Text(

              children: [              time,

                Text(              style: AppTheme.labelSmall.copyWith(

                  name,                color: AppTheme.textTertiary,

                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(              ),

                    fontWeight: FontWeight.w500,              textAlign: TextAlign.right,

                    color: Theme.of(context).colorScheme.onSurface,            ),

                  ),          ),

                ),        ],

                Text(      ),

                  dosage,    );

                  style: Theme.of(context).textTheme.bodySmall?.copyWith(  }

                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),

                  ),  Widget _buildMedicationCard(

                ),      String name, String dose, String frequency, String indication, Color color) {

              ],    return AppCard(

            ),      padding: const EdgeInsets.all(12),

          ),      child: Row(

          Container(        children: [

            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),          Container(

            decoration: BoxDecoration(            width: 8,

              color: statusColor.withValues(alpha: 0.1),            height: 40,

              borderRadius: BorderRadius.circular(6),            decoration: BoxDecoration(

            ),              color: color,

            child: Text(              borderRadius: BorderRadius.circular(4),

              status,            ),

              style: Theme.of(context).textTheme.labelSmall?.copyWith(          ),

                color: statusColor,          const SizedBox(width: 12),

                fontWeight: FontWeight.w500,          Expanded(

              ),            child: Column(

            ),              crossAxisAlignment: CrossAxisAlignment.start,

          ),              children: [

        ],                Text(

      ),                  name,

    );                  style: AppTheme.bodyMedium.copyWith(

  }                    fontWeight: FontWeight.w600,

                  ),

  Widget _buildMedicationChangeCard(String action, String medication, String date) {                ),

    final actionColor = action == 'Added' ? Colors.green : Colors.red;                Text(

                      '$dose • $frequency',

    return Container(                  style: AppTheme.bodySmall.copyWith(

      margin: const EdgeInsets.only(bottom: 8),                    color: AppTheme.textSecondary,

      padding: const EdgeInsets.all(12),                  ),

      decoration: BoxDecoration(                ),

        color: actionColor.withValues(alpha: 0.05),                Text(

        borderRadius: BorderRadius.circular(8),                  indication,

        border: Border.all(color: actionColor.withValues(alpha: 0.2)),                  style: AppTheme.labelSmall.copyWith(

      ),                    color: AppTheme.textTertiary,

      child: Row(                  ),

        children: [                ),

          Icon(              ],

            action == 'Added' ? MdiIcons.plus : MdiIcons.minus,            ),

            size: 16,          ),

            color: actionColor,        ],

          ),      ),

          const SizedBox(width: 8),    );

          Expanded(  }

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,  Widget _buildPrescriptionHistory() {

              children: [    return Column(

                Text(      children: [

                  '$action: $medication',        _buildPrescriptionItem('Amoxicillin 500mg', 'Dr. Johnson', '5 days ago'),

                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(        _buildPrescriptionItem('Ibuprofen 400mg', 'Dr. Wong', '2 weeks ago'),

                    fontWeight: FontWeight.w500,        _buildPrescriptionItem('Omeprazole 20mg', 'Dr. Johnson', '1 month ago'),

                    color: Theme.of(context).colorScheme.onSurface,      ],

                  ),    );

                ),  }

                Text(

                  date,  Widget _buildPrescriptionItem(String medication, String doctor, String date) {

                  style: Theme.of(context).textTheme.bodySmall?.copyWith(    return Container(

                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),      padding: const EdgeInsets.all(12),

                  ),      margin: const EdgeInsets.only(bottom: 8),

                ),      decoration: BoxDecoration(

              ],        color: AppTheme.backgroundColor,

            ),        borderRadius: BorderRadius.circular(8),

          ),        border: Border.all(color: AppTheme.dividerColor),

        ],      ),

      ),      child: Row(

    );        children: [

  }          Icon(

            MdiIcons.pill,

  Widget _buildNoteCard(String title, String content, String author, String date) {            size: 16,

    return Container(            color: AppTheme.textTertiary,

      margin: const EdgeInsets.only(bottom: 12),          ),

      padding: const EdgeInsets.all(16),          const SizedBox(width: 8),

      decoration: BoxDecoration(          Expanded(

        color: Theme.of(context).colorScheme.surface,            child: Column(

        borderRadius: BorderRadius.circular(8),              crossAxisAlignment: CrossAxisAlignment.start,

        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),              children: [

      ),                Text(

      child: Column(                  medication,

        crossAxisAlignment: CrossAxisAlignment.start,                  style: AppTheme.bodySmall.copyWith(

        children: [                    fontWeight: FontWeight.w500,

          Row(                  ),

            mainAxisAlignment: MainAxisAlignment.spaceBetween,                ),

            children: [                Text(

              Text(                  '$doctor • $date',

                title,                  style: AppTheme.labelSmall.copyWith(

                style: Theme.of(context).textTheme.titleSmall?.copyWith(                    color: AppTheme.textTertiary,

                  fontWeight: FontWeight.w600,                  ),

                  color: Theme.of(context).colorScheme.onSurface,                ),

                ),              ],

              ),            ),

              Text(          ),

                date,        ],

                style: Theme.of(context).textTheme.bodySmall?.copyWith(      ),

                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),    );

                ),  }

              ),

            ],  Widget _buildNoteCard(String title, String content, String author, String date) {

          ),    return AppCard(

          const SizedBox(height: 8),      child: Column(

          Text(        crossAxisAlignment: CrossAxisAlignment.start,

            content,        children: [

            style: Theme.of(context).textTheme.bodySmall?.copyWith(          Row(

              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),            children: [

            ),              Expanded(

          ),                child: Text(

          const SizedBox(height: 8),                  title,

          Text(                  style: AppTheme.bodyMedium.copyWith(

            '— $author',                    fontWeight: FontWeight.w600,

            style: Theme.of(context).textTheme.bodySmall?.copyWith(                  ),

              color: AppColors.primary,                ),

              fontWeight: FontWeight.w500,              ),

            ),              Text(

          ),                date,

        ],                style: AppTheme.labelSmall.copyWith(

      ),                  color: AppTheme.textTertiary,

    );                ),

  }              ),

}            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                MdiIcons.account,
                size: 12,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                author,
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
              const Spacer(),
              Text(
                'View Full Note',
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}