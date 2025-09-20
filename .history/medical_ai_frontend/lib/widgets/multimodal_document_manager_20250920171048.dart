import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:io';

import '../utils/app_colors.dart';
import '../providers/document_provider.dart';
import '../providers/app_provider.dart';
import 'multimodal_document_viewer.dart';
import 'background_layout.dart';

class MultimodalDocumentManager extends StatefulWidget {
  const MultimodalDocumentManager({super.key});

  @override
  State<MultimodalDocumentManager> createState() => _MultimodalDocumentManagerState();
}

class _MultimodalDocumentManagerState extends State<MultimodalDocumentManager>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _animationController;
  late Animation<double> _pageTransitionFade;
  late Animation<Offset> _slideAnimation;
  String _searchQuery = '';
  DocumentType? _selectedType;
  MedicalDocument? _selectedDocument;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pageTransitionFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _animationController.forward();
    
    // Initialize document provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentProvider>().initialize();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _uploadDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        final files = result.files
            .where((file) => file.path != null)
            .map((file) => File(file.path!))
            .toList();

        if (files.isNotEmpty) {
          final success = await context.read<DocumentProvider>().uploadDocuments(files);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  success 
                    ? 'Documents uploaded successfully!' 
                    : 'Failed to upload documents',
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: success ? Colors.green : Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading files: $e', style: GoogleFonts.inter()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    }
  }

  void _viewDocument(MedicalDocument document) {
    setState(() {
      _selectedDocument = document;
    });
  }

  void _backToList() {
    setState(() {
      _selectedDocument = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isDarkMode = appProvider.isDarkMode;
        Widget sidebar = SizedBox.shrink(); // No sidebar for document manager
        Widget homeContent = FadeTransition(
          opacity: _pageTransitionFade,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _selectedDocument != null 
                ? _buildDocumentViewer()
                : _buildDocumentManager(),
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

  Widget _buildDocumentViewer() {
    return Column(
      children: [
        // Custom header for back navigation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _backToList,
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back to Documents',
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Document Viewer',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Multimodal viewer content
        Expanded(
          child: MultimodalDocumentViewer(document: _selectedDocument!),
        ),
      ],
    );
  }

  Widget _buildDocumentManager() {
    return Consumer<DocumentProvider>(
      builder: (context, documentProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildUploadSection(documentProvider),
              const SizedBox(height: 32),
              _buildSearchAndFilter(),
              const SizedBox(height: 24),
              Expanded(
                child: _buildDocumentsList(documentProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              MdiIcons.fileDocumentMultipleOutline,
              size: 32,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Multimodal Document Center',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'AI-powered document analysis with advanced multimodal viewing capabilities',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: AppColors.textMedium,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection(DocumentProvider documentProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.secondary.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              MdiIcons.cloudUploadOutline,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Upload Medical Documents',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Experience advanced AI analysis with multimodal viewing',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textMedium,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: documentProvider.isUploading ? null : _uploadDocuments,
            icon: documentProvider.isUploading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.add, size: 20),
            label: Text(
              documentProvider.isUploading ? 'Processing...' : 'Select Files',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              context.read<DocumentProvider>().setSearchQuery(value);
            },
            decoration: InputDecoration(
              hintText: 'Search documents...',
              hintStyle: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<DocumentType?>(
          value: _selectedType,
          hint: Text(
            'Filter by type',
            style: GoogleFonts.inter(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          items: [
            DropdownMenuItem<DocumentType?>(
              value: null,
              child: Text('All Types', style: GoogleFonts.inter()),
            ),
            ...DocumentType.values.map((type) {
              return DropdownMenuItem<DocumentType?>(
                value: type,
                child: Text(
                  type.toString().split('.').last,
                  style: GoogleFonts.inter(),
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedType = value;
            });
            context.read<DocumentProvider>().setTypeFilter(value);
          },
          underline: Container(),
        ),
      ],
    );
  }

  Widget _buildDocumentsList(DocumentProvider documentProvider) {
    if (documentProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (documentProvider.filteredDocuments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.fileDocumentOutline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No documents found',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload your first document to experience multimodal analysis',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: documentProvider.filteredDocuments.length,
      itemBuilder: (context, index) {
        final document = documentProvider.filteredDocuments[index];
        return _buildDocumentCard(document);
      },
    );
  }

  Widget _buildDocumentCard(MedicalDocument document) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _viewDocument(document),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getDocumentTypeColor(document.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getDocumentTypeIcon(document.type),
                    color: _getDocumentTypeColor(document.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        document.name,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${document.fileName} • ${_formatFileSize(document.fileSizeBytes)}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(document.uploadDate),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(document.processingStatus).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getStatusText(document.processingStatus),
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getStatusColor(document.processingStatus),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  MdiIcons.eyeOutline,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getDocumentTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.labReport:
        return MdiIcons.testTube;
      case DocumentType.prescription:
        return MdiIcons.pill;
      case DocumentType.discharge:
        return MdiIcons.hospitalBuilding;
      case DocumentType.xray:
        return MdiIcons.imageBroken;
      case DocumentType.consultation:
        return MdiIcons.stethoscope;
      case DocumentType.insurance:
        return MdiIcons.shieldAccount;
      case DocumentType.general:
        return MdiIcons.fileDocumentOutline;
    }
  }

  Color _getDocumentTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.labReport:
        return Colors.blue;
      case DocumentType.prescription:
        return Colors.green;
      case DocumentType.discharge:
        return Colors.purple;
      case DocumentType.xray:
        return Colors.orange;
      case DocumentType.consultation:
        return Colors.red;
      case DocumentType.insurance:
        return Colors.indigo;
      case DocumentType.general:
        return Colors.grey;
    }
  }

  Color _getStatusColor(ProcessingStatus status) {
    switch (status) {
      case ProcessingStatus.pending:
        return Colors.orange;
      case ProcessingStatus.processing:
        return Colors.blue;
      case ProcessingStatus.completed:
        return Colors.green;
      case ProcessingStatus.failed:
        return Colors.red;
    }
  }

  String _getStatusText(ProcessingStatus status) {
    switch (status) {
      case ProcessingStatus.pending:
        return 'Pending';
      case ProcessingStatus.processing:
        return 'Processing';
      case ProcessingStatus.completed:
        return 'Ready';
      case ProcessingStatus.failed:
        return 'Failed';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
