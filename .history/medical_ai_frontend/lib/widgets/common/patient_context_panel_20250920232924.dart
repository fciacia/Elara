import 'package:flutter/material.dart';import 'package:flutter/material.dart';import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../utils/app_colors.dart';import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';



class PatientContextPanel extends StatefulWidget {import '../../utils/app_colors.dart';import '../../utils/app_theme.dart';

  final String patientId;

  import '../common/app_components.dart';

  const PatientContextPanel({

    Key? key,class PatientContextPanel extends StatefulWidget {

    required this.patientId,

  }) : super(key: key);  final String patientId;class PatientContextPanel extends StatefulWidget {



  @override    final String patientId;

  State<PatientContextPanel> createState() => _PatientContextPanelState();

}  const PatientContextPanel({  



class _PatientContextPanelState extends State<PatientContextPanel>    Key? key,  const PatientContextPanel({

    with SingleTickerProviderStateMixin {

  late TabController _tabController;    required this.patientId,    Key? key,

  

  @override  }) : super(key: key);    required this.patientId,

  void initState() {

    super.initState();  }) : super(key: key);

    _tabController = TabController(length: 4, vsync: this);

  }  @override



  @override  State<PatientContextPanel> createState() => _PatientContextPanelState();  @override

  void dispose() {

    _tabController.dispose();}  State<PatientContextPanel> createState() => _PatientContextPanelState();

    super.dispose();

  }}



  @overrideclass _PatientContextPanelState extends State<PatientContextPanel>

  Widget build(BuildContext context) {

    return Container(    with SingleTickerProviderStateMixin {class _PatientContextPanelState extends State<PatientContextPanel>

      width: double.infinity,

      height: double.infinity,  late TabController _tabController;    with SingleTickerProviderStateMixin {

      decoration: BoxDecoration(

        color: Theme.of(context).colorScheme.surface,    late TabController _tabController;

        border: Border(

          left: BorderSide(  @override  

            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), 

            width: 1  void initState() {  @override

          ),

        ),    super.initState();  void initState() {

      ),

      child: Column(    _tabController = TabController(length: 4, vsync: this);    super.initState();

        children: [

          _buildHeader(),  }    _tabController = TabController(length: 4, vsync: this);

          _buildPatientInfo(),

          _buildTabBar(),  }

          Expanded(

            child: TabBarView(  @override

              controller: _tabController,

              children: [  void dispose() {  @override

                _buildOverviewTab(),

                _buildVitalsTab(),    _tabController.dispose();  void dispose() {

                _buildMedicationsTab(),

                _buildNotesTab(),    super.dispose();    _tabController.dispose();

              ],

            ),  }    super.dispose();

          ),

        ],  }

      ),

    );  @override

  }

  Widget build(BuildContext context) {  @override

  Widget _buildHeader() {

    return Container(    return Container(  Widget build(BuildContext context) {

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(      width: double.infinity,    return Container(

        color: Theme.of(context).colorScheme.surface,

        border: Border(      height: double.infinity,      width: 380,

          bottom: BorderSide(

            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),       decoration: BoxDecoration(      height: double.infinity,

            width: 1

          ),        color: Theme.of(context).colorScheme.surface,      decoration: BoxDecoration(

        ),

      ),        border: Border(        color: AppTheme.surfaceColor,

      child: Row(

        children: [          left: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), width: 1),        border: Border(

          Icon(

            MdiIcons.account,        ),          left: BorderSide(color: AppTheme.dividerColor, width: 1),

            size: 20,

            color: AppColors.primary,      ),        ),

          ),

          const SizedBox(width: 8),      child: Column(      ),

          Text(

            'Patient Context',        children: [      child: Column(

            style: Theme.of(context).textTheme.titleMedium?.copyWith(

              fontWeight: FontWeight.w600,          _buildHeader(),        children: [

              color: Theme.of(context).colorScheme.onSurface,

            ),          _buildPatientInfo(),          _buildHeader(),

          ),

        ],          _buildTabBar(),          _buildPatientInfo(),

      ),

    );          Expanded(          _buildTabBar(),

  }

            child: TabBarView(          Expanded(

  Widget _buildPatientInfo() {

    return Container(              controller: _tabController,            child: TabBarView(

      margin: const EdgeInsets.all(16),

      padding: const EdgeInsets.all(16),              children: [              controller: _tabController,

      decoration: BoxDecoration(

        gradient: LinearGradient(                _buildOverviewTab(),              children: [

          colors: [

            AppColors.primary.withValues(alpha: 0.1),                _buildVitalsTab(),                _buildOverviewTab(),

            AppColors.primary.withValues(alpha: 0.05),

          ],                _buildMedicationsTab(),                _buildVitalsTab(),

          begin: Alignment.topLeft,

          end: Alignment.bottomRight,                _buildNotesTab(),                _buildMedicationsTab(),

        ),

        borderRadius: BorderRadius.circular(12),              ],                _buildNotesTab(),

      ),

      child: Row(            ),              ],

        children: [

          Container(          ),            ),

            width: 48,

            height: 48,        ],          ),

            decoration: BoxDecoration(

              gradient: LinearGradient(      ),        ],

                colors: [

                  AppColors.primary,     );      ),

                  AppColors.primary.withValues(alpha: 0.8)

                ],  }    );

                begin: Alignment.topLeft,

                end: Alignment.bottomRight,  }

              ),

              borderRadius: BorderRadius.circular(12),  Widget _buildHeader() {

            ),

            child: const Center(    return Container(  Widget _buildHeader() {

              child: Text(

                'EC',      padding: const EdgeInsets.all(16),    return Container(

                style: TextStyle(

                  color: Colors.white,      decoration: BoxDecoration(      padding: const EdgeInsets.all(16),

                  fontWeight: FontWeight.w600,

                  fontSize: 16,        color: Theme.of(context).colorScheme.surface,      decoration: BoxDecoration(

                ),

              ),        border: Border(        border: Border(

            ),

          ),          bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), width: 1),          bottom: BorderSide(color: AppTheme.dividerColor, width: 1),

          const SizedBox(width: 12),

          Expanded(        ),        ),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,      ),      ),

              children: [

                Text(      child: Row(      child: Row(

                  'Emily Chen',

                  style: Theme.of(context).textTheme.titleMedium?.copyWith(        children: [        children: [

                    color: Theme.of(context).colorScheme.onSurface,

                    fontWeight: FontWeight.w600,          Icon(          Icon(

                  ),

                ),            MdiIcons.account,            MdiIcons.account,

                Text(

                  'ID: P12345 • Age: 34',            size: 20,            size: 20,

                  style: Theme.of(context).textTheme.bodySmall?.copyWith(

                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),            color: AppColors.primary,            color: AppTheme.primaryColor,

                  ),

                ),          ),          ),

              ],

            ),          const SizedBox(width: 8),          const SizedBox(width: 8),

          ),

          Container(          Text(          Text(

            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

            decoration: BoxDecoration(            'Patient Context',            'Patient Context',

              color: Colors.green.withValues(alpha: 0.2),

              borderRadius: BorderRadius.circular(8),            style: Theme.of(context).textTheme.titleMedium?.copyWith(            style: AppTheme.titleSmall.copyWith(

            ),

            child: Text(              fontWeight: FontWeight.w600,              color: AppTheme.textPrimary,

              'Stable',

              style: Theme.of(context).textTheme.labelSmall?.copyWith(              color: Theme.of(context).colorScheme.onSurface,              fontWeight: FontWeight.w600,

                color: Colors.green[700],

                fontWeight: FontWeight.w500,            ),            ),

              ),

            ),          ),          ),

          ),

        ],        ],          const Spacer(),

      ),

    );      ),          IconButton(

  }

    );            onPressed: () {},

  Widget _buildTabBar() {

    return Container(  }            icon: Icon(

      decoration: BoxDecoration(

        border: Border(              MdiIcons.refresh,

          bottom: BorderSide(

            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),   Widget _buildPatientInfo() {              size: 16,

            width: 1

          ),    return Container(              color: AppTheme.textTertiary,

        ),

      ),      margin: const EdgeInsets.all(16),            ),

      child: TabBar(

        controller: _tabController,      padding: const EdgeInsets.all(16),            padding: EdgeInsets.zero,

        isScrollable: false,

        labelColor: AppColors.primary,      decoration: BoxDecoration(            constraints: const BoxConstraints(),

        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),

        indicatorColor: AppColors.primary,        gradient: LinearGradient(          ),

        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(

          fontWeight: FontWeight.w600          colors: [        ],

        ),

        unselectedLabelStyle: Theme.of(context).textTheme.labelMedium,            AppColors.primary.withValues(alpha: 0.1),      ),

        tabs: const [

          Tab(text: 'Overview'),            AppColors.primary.withValues(alpha: 0.05),    );

          Tab(text: 'Vitals'),

          Tab(text: 'Meds'),          ],  }

          Tab(text: 'Notes'),

        ],          begin: Alignment.topLeft,

      ),

    );          end: Alignment.bottomRight,  Widget _buildPatientInfo() {

  }

        ),    return Container(

  Widget _buildOverviewTab() {

    return SingleChildScrollView(        borderRadius: BorderRadius.circular(12),      margin: const EdgeInsets.all(16),

      padding: const EdgeInsets.all(16),

      child: Column(      ),      padding: const EdgeInsets.all(16),

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [      child: Row(      decoration: AppTheme.primaryGradientDecoration,

          _buildSectionHeader('Personal Information'),

          const SizedBox(height: 12),        children: [      child: Row(

          _buildInfoRow('Date of Birth', 'March 15, 1991'),

          _buildInfoRow('Gender', 'Female'),          Container(        children: [

          _buildInfoRow('Blood Type', 'O+'),

          _buildInfoRow('Emergency Contact', 'John Chen (Husband)'),            width: 48,          CircleAvatar(

          const SizedBox(height: 20),

          _buildSectionHeader('Allergies & Warnings'),            height: 48,            radius: 24,

          const SizedBox(height: 12),

          _buildWarningCard('Drug Allergies', 'Penicillin, Sulfa drugs', Colors.red),            decoration: BoxDecoration(            backgroundColor: Colors.white.withOpacity(0.2),

          const SizedBox(height: 8),

          _buildWarningCard('Medical Conditions', 'Mild Asthma', Colors.orange),              gradient: LinearGradient(            child: Text(

        ],

      ),                colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],              'ES',

    );

  }                begin: Alignment.topLeft,              style: AppTheme.titleSmall.copyWith(



  Widget _buildVitalsTab() {                end: Alignment.bottomRight,                color: Colors.white,

    return SingleChildScrollView(

      padding: const EdgeInsets.all(16),              ),                fontWeight: FontWeight.w700,

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,              borderRadius: BorderRadius.circular(12),              ),

        children: [

          _buildSectionHeader('Current Vitals'),            ),            ),

          const SizedBox(height: 12),

          _buildVitalCard('Blood Pressure', '118/76', 'mmHg', Colors.green, MdiIcons.heart),            child: const Center(          ),

          const SizedBox(height: 8),

          _buildVitalCard('Heart Rate', '72', 'bpm', Colors.green, MdiIcons.heartPulse),              child: Text(          const SizedBox(width: 12),

          const SizedBox(height: 8),

          _buildVitalCard('Temperature', '98.6', '°F', Colors.green, MdiIcons.thermometer),                'EC',          Expanded(

          const SizedBox(height: 8),

          _buildVitalCard('Oxygen Saturation', '98', '%', Colors.green, MdiIcons.waterPercent),                style: TextStyle(            child: Column(

        ],

      ),                  color: Colors.white,              crossAxisAlignment: CrossAxisAlignment.start,

    );

  }                  fontWeight: FontWeight.w600,              children: [



  Widget _buildMedicationsTab() {                  fontSize: 16,                Text(

    return SingleChildScrollView(

      padding: const EdgeInsets.all(16),                ),                  'Emily Chen',

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,              ),                  style: AppTheme.titleMedium.copyWith(

        children: [

          _buildSectionHeader('Current Medications'),            ),                    color: Colors.white,

          const SizedBox(height: 12),

          _buildMedicationCard('Albuterol Inhaler', '90 mcg, 2 puffs as needed', 'Active'),          ),                    fontWeight: FontWeight.w600,

          const SizedBox(height: 8),

          _buildMedicationCard('Vitamin D3', '1000 IU daily', 'Active'),          const SizedBox(width: 12),                  ),

          const SizedBox(height: 8),

          _buildMedicationCard('Birth Control', 'Daily', 'Active'),          Expanded(                ),

        ],

      ),            child: Column(                Text(

    );

  }              crossAxisAlignment: CrossAxisAlignment.start,                  'ID: P12345 • Age: 34',



  Widget _buildNotesTab() {              children: [                  style: AppTheme.bodySmall.copyWith(

    return SingleChildScrollView(

      padding: const EdgeInsets.all(16),                Text(                    color: Colors.white.withOpacity(0.9),

      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,                  'Emily Chen',                  ),

        children: [

          _buildSectionHeader('Recent Notes'),                  style: Theme.of(context).textTheme.titleMedium?.copyWith(                ),

          const SizedBox(height: 12),

          _buildNoteCard(                    color: Theme.of(context).colorScheme.onSurface,              ],

            'Annual Checkup',

            'Patient reports feeling well. No new concerns. Asthma well controlled with current inhaler.',                    fontWeight: FontWeight.w600,            ),

            'Dr. Sarah Johnson',

            'September 15, 2025',                  ),          ),

          ),

          const SizedBox(height: 12),                ),          StatusBadge(

          _buildNoteCard(

            'Lab Results Review',                Text(            text: 'Active',

            'All lab values within normal limits. Vitamin D levels improved since starting supplementation.',

            'Dr. Sarah Johnson',                  'ID: P12345 • Age: 34',            color: AppTheme.successColor,

            'September 1, 2025',

          ),                  style: Theme.of(context).textTheme.bodySmall?.copyWith(            type: BadgeType.success,

        ],

      ),                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),          ),

    );

  }                  ),        ],



  Widget _buildSectionHeader(String title) {                ),      ),

    return Text(

      title,              ],    );

      style: Theme.of(context).textTheme.titleSmall?.copyWith(

        fontWeight: FontWeight.w600,            ),  }

        color: Theme.of(context).colorScheme.onSurface,

      ),          ),

    );

  }          Container(  Widget _buildTabBar() {



  Widget _buildInfoRow(String label, String value) {            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),    return Container(

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 4),            decoration: BoxDecoration(      decoration: BoxDecoration(

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,              color: Colors.green.withValues(alpha: 0.2),        border: Border(

        children: [

          SizedBox(              borderRadius: BorderRadius.circular(8),          bottom: BorderSide(color: AppTheme.dividerColor, width: 1),

            width: 120,

            child: Text(            ),        ),

              label,

              style: Theme.of(context).textTheme.bodySmall?.copyWith(            child: Text(      ),

                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),

              ),              'Stable',      child: TabBar(

            ),

          ),              style: Theme.of(context).textTheme.labelSmall?.copyWith(        controller: _tabController,

          Expanded(

            child: Text(                color: Colors.green[700],        isScrollable: false,

              value,

              style: Theme.of(context).textTheme.bodySmall?.copyWith(                fontWeight: FontWeight.w500,        labelColor: AppTheme.primaryColor,

                color: Theme.of(context).colorScheme.onSurface,

                fontWeight: FontWeight.w500,              ),        unselectedLabelColor: AppTheme.textTertiary,

              ),

            ),            ),        labelStyle: AppTheme.labelMedium.copyWith(fontWeight: FontWeight.w600),

          ),

        ],          ),        unselectedLabelStyle: AppTheme.labelMedium,

      ),

    );        ],        indicatorColor: AppTheme.primaryColor,

  }

      ),        indicatorWeight: 2,

  Widget _buildWarningCard(String title, String content, Color color) {

    return Container(    );        tabs: const [

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(  }          Tab(text: 'Overview'),

        color: color.withValues(alpha: 0.1),

        borderRadius: BorderRadius.circular(8),          Tab(text: 'Vitals'),

        border: Border.all(color: color.withValues(alpha: 0.3)),

      ),  Widget _buildTabBar() {          Tab(text: 'Meds'),

      child: Row(

        children: [    return Container(          Tab(text: 'Notes'),

          Icon(

            MdiIcons.alertCircle,      decoration: BoxDecoration(        ],

            size: 16,

            color: color,        border: Border(      ),

          ),

          const SizedBox(width: 8),          bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), width: 1),    );

          Expanded(

            child: Column(        ),  }

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [      ),

                Text(

                  title,      child: TabBar(  Widget _buildOverviewTab() {

                  style: Theme.of(context).textTheme.labelMedium?.copyWith(

                    fontWeight: FontWeight.w600,        controller: _tabController,    return SingleChildScrollView(

                    color: color,

                  ),        isScrollable: false,      padding: const EdgeInsets.all(16),

                ),

                Text(        labelColor: AppColors.primary,      child: Column(

                  content,

                  style: Theme.of(context).textTheme.bodySmall?.copyWith(        unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),        crossAxisAlignment: CrossAxisAlignment.start,

                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),

                  ),        indicatorColor: AppColors.primary,        children: [

                ),

              ],        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),          _buildInfoSection(

            ),

          ),        unselectedLabelStyle: Theme.of(context).textTheme.labelMedium,            'Personal Information',

        ],

      ),        tabs: const [            [

    );

  }          Tab(text: 'Overview'),              _buildInfoRow('Gender', 'Female'),



  Widget _buildVitalCard(String title, String value, String unit, Color color, IconData icon) {          Tab(text: 'Vitals'),              _buildInfoRow('Date of Birth', 'March 15, 1990'),

    return Container(

      padding: const EdgeInsets.all(12),          Tab(text: 'Meds'),              _buildInfoRow('Blood Type', 'A+'),

      decoration: BoxDecoration(

        color: color.withValues(alpha: 0.1),          Tab(text: 'Notes'),              _buildInfoRow('Phone', '+60 12-345 6789'),

        borderRadius: BorderRadius.circular(8),

      ),        ],              _buildInfoRow('Emergency Contact', 'John Chen (Husband)'),

      child: Row(

        children: [      ),            ],

          Container(

            padding: const EdgeInsets.all(8),    );          ),

            decoration: BoxDecoration(

              color: color.withValues(alpha: 0.2),  }          const SizedBox(height: 16),

              borderRadius: BorderRadius.circular(6),

            ),          _buildInfoSection(

            child: Icon(

              icon,  Widget _buildOverviewTab() {            'Medical History',

              size: 16,

              color: color,    return SingleChildScrollView(            [

            ),

          ),      padding: const EdgeInsets.all(16),              _buildInfoRow('Allergies', 'Penicillin, Shellfish'),

          const SizedBox(width: 12),

          Expanded(      child: Column(              _buildInfoRow('Chronic Conditions', 'Hypertension'),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,        crossAxisAlignment: CrossAxisAlignment.start,              _buildInfoRow('Previous Surgeries', 'Appendectomy (2018)'),

              children: [

                Text(        children: [              _buildInfoRow('Family History', 'Diabetes, Heart Disease'),

                  title,

                  style: Theme.of(context).textTheme.bodySmall?.copyWith(          _buildSectionHeader('Personal Information'),            ],

                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),

                  ),          const SizedBox(height: 12),          ),

                ),

                Row(          _buildInfoRow('Date of Birth', 'March 15, 1991'),          const SizedBox(height: 16),

                  children: [

                    Text(          _buildInfoRow('Gender', 'Female'),          _buildInfoSection(

                      value,

                      style: Theme.of(context).textTheme.titleMedium?.copyWith(          _buildInfoRow('Blood Type', 'O+'),            'Insurance & Coverage',

                        fontWeight: FontWeight.w600,

                        color: color,          _buildInfoRow('Emergency Contact', 'John Chen (Husband)'),            [

                      ),

                    ),          const SizedBox(height: 20),              _buildInfoRow('Insurance Provider', 'Great Eastern'),

                    const SizedBox(width: 4),

                    Text(          _buildSectionHeader('Allergies & Warnings'),              _buildInfoRow('Policy Number', 'GE123456789'),

                      unit,

                      style: Theme.of(context).textTheme.bodySmall?.copyWith(          const SizedBox(height: 12),              _buildInfoRow('Coverage Type', 'Premium Family'),

                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),

                      ),          _buildWarningCard('Drug Allergies', 'Penicillin, Sulfa drugs', Colors.red),              _buildInfoRow('Validity', 'Valid until Dec 2024'),

                    ),

                  ],          const SizedBox(height: 8),            ],

                ),

              ],          _buildWarningCard('Medical Conditions', 'Mild Asthma', Colors.orange),          ),

            ),

          ),          const SizedBox(height: 20),        ],

        ],

      ),          _buildSectionHeader('Insurance Information'),      ),

    );

  }          const SizedBox(height: 12),    );



  Widget _buildMedicationCard(String name, String dosage, String status) {          _buildInfoRow('Provider', 'Blue Cross Blue Shield'),  }

    final statusColor = status == 'Active' ? Colors.green : Colors.orange;

              _buildInfoRow('Policy Number', 'BC12345678'),

    return Container(

      margin: const EdgeInsets.only(bottom: 8),          _buildInfoRow('Group Number', 'GRP001'),  Widget _buildVitalsTab() {

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(        ],    return SingleChildScrollView(

        color: Theme.of(context).colorScheme.surface,

        borderRadius: BorderRadius.circular(8),      ),      padding: const EdgeInsets.all(16),

        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),

      ),    );      child: Column(

      child: Row(

        children: [  }        children: [

          Container(

            width: 8,          Row(

            height: 8,

            decoration: BoxDecoration(  Widget _buildVitalsTab() {            children: [

              color: statusColor,

              shape: BoxShape.circle,    return SingleChildScrollView(              Expanded(

            ),

          ),      padding: const EdgeInsets.all(16),                child: MetricCard(

          const SizedBox(width: 12),

          Expanded(      child: Column(                  title: 'Heart Rate',

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,        crossAxisAlignment: CrossAxisAlignment.start,                  value: '72',

              children: [

                Text(        children: [                  unit: 'bpm',

                  name,

                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(          _buildSectionHeader('Current Vitals'),                  icon: MdiIcons.heart,

                    fontWeight: FontWeight.w500,

                    color: Theme.of(context).colorScheme.onSurface,          const SizedBox(height: 12),                  trendType: TrendType.stable,

                  ),

                ),          _buildVitalCard('Blood Pressure', '118/76', 'mmHg', Colors.green, MdiIcons.heart),                  color: AppTheme.successColor,

                Text(

                  dosage,          const SizedBox(height: 8),                ),

                  style: Theme.of(context).textTheme.bodySmall?.copyWith(

                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),          _buildVitalCard('Heart Rate', '72', 'bpm', Colors.green, MdiIcons.heartPulse),              ),

                  ),

                ),          const SizedBox(height: 8),              const SizedBox(width: 12),

              ],

            ),          _buildVitalCard('Temperature', '98.6', '°F', Colors.green, MdiIcons.thermometer),              Expanded(

          ),

          Container(          const SizedBox(height: 8),                child: MetricCard(

            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

            decoration: BoxDecoration(          _buildVitalCard('Respiratory Rate', '16', 'rpm', Colors.green, MdiIcons.lungs),                  title: 'Temperature',

              color: statusColor.withValues(alpha: 0.1),

              borderRadius: BorderRadius.circular(6),          const SizedBox(height: 8),                  value: '36.5',

            ),

            child: Text(          _buildVitalCard('Oxygen Saturation', '98', '%', Colors.green, MdiIcons.waterPercent),                  unit: '°C',

              status,

              style: Theme.of(context).textTheme.labelSmall?.copyWith(          const SizedBox(height: 20),                  icon: MdiIcons.thermometer,

                color: statusColor,

                fontWeight: FontWeight.w500,          _buildSectionHeader('Recent Trends'),                  trendType: TrendType.stable,

              ),

            ),          const SizedBox(height: 12),                  color: AppTheme.infoColor,

          ),

        ],          _buildTrendCard('Blood Pressure', 'Stable', 'Last 7 days', Colors.green),                ),

      ),

    );          _buildTrendCard('Weight', '135 lbs', 'No change', Colors.blue),              ),

  }

        ],            ],

  Widget _buildNoteCard(String title, String content, String author, String date) {

    return Container(      ),          ),

      margin: const EdgeInsets.only(bottom: 12),

      padding: const EdgeInsets.all(16),    );          const SizedBox(height: 12),

      decoration: BoxDecoration(

        color: Theme.of(context).colorScheme.surface,  }          Row(

        borderRadius: BorderRadius.circular(8),

        border: Border.all(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2)),            children: [

      ),

      child: Column(  Widget _buildMedicationsTab() {              Expanded(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [    return SingleChildScrollView(                child: MetricCard(

          Row(

            mainAxisAlignment: MainAxisAlignment.spaceBetween,      padding: const EdgeInsets.all(16),                  title: 'Oxygen',

            children: [

              Text(      child: Column(                  value: '98',

                title,

                style: Theme.of(context).textTheme.titleSmall?.copyWith(        crossAxisAlignment: CrossAxisAlignment.start,                  unit: '%',

                  fontWeight: FontWeight.w600,

                  color: Theme.of(context).colorScheme.onSurface,        children: [                  icon: MdiIcons.lungs,

                ),

              ),          _buildSectionHeader('Current Medications'),                  trendType: TrendType.up,

              Text(

                date,          const SizedBox(height: 12),                  color: AppTheme.successColor,

                style: Theme.of(context).textTheme.bodySmall?.copyWith(

                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),          _buildMedicationCard('Albuterol Inhaler', '90 mcg, 2 puffs as needed', 'Active'),                ),

                ),

              ),          const SizedBox(height: 8),              ),

            ],

          ),          _buildMedicationCard('Vitamin D3', '1000 IU daily', 'Active'),              const SizedBox(width: 12),

          const SizedBox(height: 8),

          Text(          const SizedBox(height: 8),              Expanded(

            content,

            style: Theme.of(context).textTheme.bodySmall?.copyWith(          _buildMedicationCard('Birth Control', 'Daily', 'Active'),                child: MetricCard(

              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),

            ),          const SizedBox(height: 20),                  title: 'Resp. Rate',

          ),

          const SizedBox(height: 8),          _buildSectionHeader('Recent Changes'),                  value: '16',

          Text(

            '— $author',          const SizedBox(height: 12),                  unit: '/min',

            style: Theme.of(context).textTheme.bodySmall?.copyWith(

              color: AppColors.primary,          _buildMedicationChangeCard('Added', 'Vitamin D3', '2 weeks ago'),                  icon: MdiIcons.airFilter,

              fontWeight: FontWeight.w500,

            ),          _buildMedicationChangeCard('Discontinued', 'Ibuprofen', '1 month ago'),                  trendType: TrendType.stable,

          ),

        ],        ],                  color: AppTheme.infoColor,

      ),

    );      ),                ),

  }

}    );              ),

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