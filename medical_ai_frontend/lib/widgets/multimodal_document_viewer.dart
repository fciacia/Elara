import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../utils/app_colors.dart';
import '../providers/document_provider.dart';

class MultimodalDocumentViewer extends StatefulWidget {
  final MedicalDocument document;
  
  const MultimodalDocumentViewer({
    super.key,
    required this.document,
  });

  @override
  State<MultimodalDocumentViewer> createState() => _MultimodalDocumentViewerState();
}

class _MultimodalDocumentViewerState extends State<MultimodalDocumentViewer>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  
  bool _isFullscreen = false;
  double _zoomLevel = 1.0;
  
  final List<DocumentAnnotation> _annotations = [];
  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _animationController.forward();

  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: _isFullscreen ? _buildFullscreenView() : _buildNormalView(),
    );
  }

  

  Widget _buildNormalView() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Row(
            children: [
              // Document Viewer
              Expanded(
                flex: 2,
                child: _buildDocumentViewer(),
              ),
              // AI Insights Panel
              Container(
                width: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    left: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                ),
                child: _buildAIInsightsPanel(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFullscreenView() {
    return Stack(
      children: [
        _buildDocumentViewer(),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _isFullscreen = false),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Text(
                  widget.document.name,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _resetZoom,
                  icon: const Icon(Icons.zoom_out_map, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ...existing code...
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.document.name,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  _getDocumentTypeLabel(widget.document.type),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusChip(),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => setState(() => _isFullscreen = !_isFullscreen),
            icon: Icon(_isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen),
          ),
          IconButton(
            onPressed: _shareDocument,
            icon: const Icon(Icons.share),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color;
    String label;
    
    switch (widget.document.processingStatus) {
      case ProcessingStatus.completed:
        color = Colors.green;
        label = 'Processed';
        break;
      case ProcessingStatus.processing:
        color = Colors.blue;
        label = 'Processing';
        break;
      case ProcessingStatus.pending:
        color = Colors.orange;
        label = 'Pending';
        break;
      case ProcessingStatus.failed:
        color = Colors.red;
        label = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentViewer() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Document Content
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              onInteractionUpdate: (details) {
                setState(() {
                  _zoomLevel = details.scale;
                });
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.grey[50],
                child: _buildDocumentContent(),
              ),
            ),
            // Annotations Overlay
            ..._annotations.map((annotation) => _buildReference(annotation)),
            // Zoom Controls
            Positioned(
              bottom: 16,
              right: 16,
              child: _buildZoomControls(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentContent() {
    return Center(
      child: Container(
        width: 600,
        height: 800,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDocumentHeader(),
              const SizedBox(height: 24),
              _buildDocumentBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MEDICAL REPORT',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Patient: Ahmad Ibrahim',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          Text(
            'Date: ${_formatDate(widget.document.uploadDate)}',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentBody() {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('LABORATORY RESULTS', [
              _buildLabResult('White Blood Cells', '7,200/μL', 'Normal'),
              _buildLabResult('Blood Sugar', '5.2 mmol/L', 'Normal'),
              _buildLabResult('Cholesterol', '4.8 mmol/L', 'Normal'),
            ]),
            const SizedBox(height: 24),
            _buildSection('VITAL SIGNS', [
              _buildVitalSign('Heart Rate', '72 bpm', 'Normal'),
              _buildVitalSign('Temperature', '37.2°C', 'Normal'),
              _buildVitalSign('Weight', '75 kg', 'Normal'),
            ]),
            const SizedBox(height: 24),
            _buildSection('MEDICATIONS', [
              _buildMedication('Metformin 500mg', 'Twice daily with meals'),
              _buildMedication('Lisinopril 10mg', 'Once daily in the morning'),
            ]),
            const SizedBox(height: 24),
            _buildSection('RECOMMENDATIONS', [
              _buildRecommendation('Continue current medication regimen'),
              _buildRecommendation('Schedule follow-up in 3 months'),
              _buildRecommendation('Maintain regular exercise routine'),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildLabResult(String test, String value, String status) {
    Color statusColor = status == 'Normal' ? Colors.green : Colors.orange;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              test,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

  Widget _buildVitalSign(String sign, String value, String status) {
    return _buildLabResult(sign, value, status);
  }

  Widget _buildMedication(String medication, String instruction) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  instruction,
                  style: GoogleFonts.inter(
                    fontSize: 11,
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

  Widget _buildRecommendation(String recommendation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              recommendation,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReference(DocumentAnnotation annotation) {
    return Positioned(
      left: annotation.position.dx,
      top: annotation.position.dy,
      child: GestureDetector(
        onTap: () => _showAnnotationDetails(annotation),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: annotation.color.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: annotation.color, width: 2),
            boxShadow: [
              BoxShadow(
                color: annotation.color.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getAnnotationIcon(annotation.type),
                size: 12,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                annotation.text,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoomControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _zoomIn,
            icon: const Icon(Icons.zoom_in),
          ),
          Text(
            '${(_zoomLevel * 100).toInt()}%',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: _zoomOut,
            icon: const Icon(Icons.zoom_out),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsightsPanel() {
    return Column(
      children: [
        _buildInsightsHeader(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildExtractedDataTab(),
              _buildAIAnalysisTab(),
              _buildAnnotationsTab(),
              _buildChatTab(),
            ],
          ),
        ),
        _buildInsightsTabs(),
      ],
    );
  }

  Widget _buildInsightsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              MdiIcons.robot,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Medical Assistant',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Analyzing your document',
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

  Widget _buildInsightsTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMedium,
        indicatorColor: AppColors.primary,
        tabs: const [
          Tab(icon: Icon(Icons.data_object, size: 16), text: 'Data'),
          Tab(icon: Icon(Icons.psychology, size: 16), text: 'Analysis'),
          Tab(icon: Icon(Icons.label, size: 16), text: 'References'),
          Tab(icon: Icon(Icons.chat, size: 16), text: 'Chat'),
        ],
      ),
    );
  }

  Widget _buildExtractedDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Extracted Medical Data',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.document.extractedText.map((text) => 
            _buildDataItem(text)
          ),
          const SizedBox(height: 16),
          _buildDataSummary(),
        ],
      ),
    );
  }

  Widget _buildDataItem(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            MdiIcons.checkCircle,
            color: Colors.green,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(MdiIcons.information, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              Text(
                'Data Summary',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Successfully extracted ${widget.document.extractedText.length} medical data points with 95% confidence.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAnalysisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Medical Analysis',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          _buildAnalysisCard(
            'Health Status',
            'Overall health appears to be good with all vital signs within normal ranges.',
            Colors.green,
            MdiIcons.heartPulse,
          ),
          _buildAnalysisCard(
            'Risk Assessment',
            'Low risk for cardiovascular disease. Continue current lifestyle.',
            Colors.blue,
            MdiIcons.shieldCheck,
          ),
          _buildAnalysisCard(
            'Recommendations',
            'Maintain regular exercise and healthy diet. Schedule annual checkup.',
            Colors.orange,
            MdiIcons.lightbulb,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard(String title, String content, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnotationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'References',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          ..._annotations.map((annotation) => _buildAnnotationItem(annotation)),
        ],
      ),
    );
  }

  Widget _buildAnnotationItem(DocumentAnnotation annotation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: annotation.color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: annotation.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                annotation.text,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: annotation.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(annotation.confidence * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: annotation.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            annotation.description,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildChatMessage(
                  'I\'ve analyzed your medical report. Your test results show all values within normal ranges. Would you like me to explain any specific findings?',
                  false,
                ),
                _buildChatMessage(
                  'What does my cholesterol level indicate?',
                  true,
                ),
                _buildChatMessage(
                  'Your cholesterol level of 4.8 mmol/L is within the recommended range. This indicates good cardiovascular health.',
                  false,
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: InputDecoration(
                    hintText: 'Ask about your medical report...',
                    hintStyle: GoogleFonts.inter(color: AppColors.textLight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: _sendChatMessage,
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatMessage(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: isUser ? Colors.white : AppColors.textDark,
          ),
        ),
      ),
    );
  }

  // Helper methods
  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel * 1.2).clamp(0.5, 3.0);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel / 1.2).clamp(0.5, 3.0);
    });
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
    });
  }

  void _showAnnotationDetails(DocumentAnnotation annotation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          annotation.text,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              annotation.description,
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Confidence: ',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textMedium),
                ),
                Text(
                  '${(annotation.confidence * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: annotation.color,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _sendChatMessage() {
    if (_chatController.text.trim().isNotEmpty) {
      // TODO: Implement chat functionality
      _chatController.clear();
    }
  }

  void _shareDocument() {
    // TODO: Implement document sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Document sharing coming soon!')),
    );
  }

  String _getDocumentTypeLabel(DocumentType type) {
    switch (type) {
      case DocumentType.labReport:
        return 'Lab Report';
      case DocumentType.prescription:
        return 'Prescription';
      case DocumentType.xray:
        return 'X-Ray';
      case DocumentType.discharge:
        return 'Discharge Summary';
      case DocumentType.consultation:
        return 'Consultation';
      case DocumentType.insurance:
        return 'Insurance';
      default:
        return 'General';
    }
  }

  IconData _getAnnotationIcon(AnnotationType type) {
    switch (type) {
      case AnnotationType.medicalTerm:
        return MdiIcons.medicalBag;
      case AnnotationType.value:
        return MdiIcons.numeric;
      case AnnotationType.alert:
        return MdiIcons.alert;
      default:
        return MdiIcons.label;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Data models
class DocumentAnnotation {
  final String id;
  final AnnotationType type;
  final String text;
  final Offset position;
  final double confidence;
  final String description;
  final Color color;

  DocumentAnnotation({
    required this.id,
    required this.type,
    required this.text,
    required this.position,
    required this.confidence,
    required this.description,
    required this.color,
  });
}

enum AnnotationType {
  medicalTerm,
  value,
  alert,
  note,
}
