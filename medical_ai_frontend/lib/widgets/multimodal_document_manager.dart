import 'package:flutter/foundation.dart'; // for kIsWeb
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
  late AnimationController _staggerController;
  DocumentType? _selectedType;
  MedicalDocument? _selectedDocument;
  int? _hoveredDocumentIndex;


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
    
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // Initialize document provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DocumentProvider>().initialize();
      _staggerController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _animationController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _uploadDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'txt'],
        withData: true, // ensures bytes are loaded for web
      );

      if (result != null && result.files.isNotEmpty) {
        if (kIsWeb) {
          // On web, use bytes
          final files = result.files.where((file) => file.bytes != null).toList();
          final success = await context.read<DocumentProvider>().uploadDocumentsWeb(files);
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
        } else {
          // On mobile/desktop, use File
          final files = result.files.where((file) => file.path != null).map((file) => File(file.path!)).toList();
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
      final screenWidth = MediaQuery.of(context).size.width;
      final isLargeScreen = screenWidth > 1200;
      final isMediumScreen = screenWidth > 800;
      final isSmallScreen = screenWidth < 600;
      
      // Adjust padding based on screen size
      final horizontalPadding = isLargeScreen ? 32.0 : isMediumScreen ? 24.0 : 16.0;
      final verticalPadding = isLargeScreen ? 32.0 : isMediumScreen ? 24.0 : 16.0;
      
      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: isLargeScreen ? 24 : 20),
            _buildUploadSection(documentProvider),
            SizedBox(height: isLargeScreen ? 32 : 24),
            _buildSearchAndFilter(),
            SizedBox(height: isLargeScreen ? 24 : 20),
            SizedBox(
              height: isSmallScreen ? 400 : 600, // Fixed height for scrollable list
              child: _buildDocumentsList(documentProvider), // Fixed: was _buildSearchField
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.fileDocumentMultipleOutline,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                      child: Text(
                        'Document Center',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.8,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Multimodal AI Analysis',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    MdiIcons.brain,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Experience next-generation document analysis with AI-powered insights and multimodal viewing capabilities',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection(DocumentProvider documentProvider) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.03),
            AppColors.secondary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              top: -50,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              left: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.07),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Enhanced upload icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.15),
                          AppColors.secondary.withValues(alpha: 0.15),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      MdiIcons.cloudUploadOutline,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title and subtitle
                  Text(
                    'Upload Medical Documents',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Drag and drop files here or click to browse',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PDF, JPG, PNG, DOC, DOCX, TXT • Max 10MB per file',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Enhanced button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton.icon(
                      onPressed: documentProvider.isUploading ? null : _uploadDocuments,
                      icon: documentProvider.isUploading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(MdiIcons.plus, size: 22),
                      label: Text(
                        documentProvider.isUploading ? 'Processing Files...' : 'Select Documents',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Additional features row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFeatureChip(MdiIcons.brain, 'AI Analysis'),
                      const SizedBox(width: 16),
                      _buildFeatureChip(MdiIcons.eyeOutline, 'Multimodal View'),
                      const SizedBox(width: 16),
                      _buildFeatureChip(MdiIcons.shieldCheckOutline, 'Secure Storage'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
  final screenWidth = MediaQuery.of(context).size.width;
  final isSmallScreen = screenWidth < 600;
  
  return Container(
    padding: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      // Made transparent
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      // Removed border or made it transparent
      border: Border.all(
        color: Colors.transparent,
        width: 1,
      ),
      // Removed or reduced shadow
      boxShadow: [],
    ),
    child: isSmallScreen 
      ? Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 8),
            _buildFilterDropdown(),
          ],
        )
      : Row(
          children: [
            Expanded(flex: 3, child: _buildSearchField()),
            const SizedBox(width: 12),
            _buildFilterDropdown(),
          ],
        ),
  );
}

Widget _buildSearchField() {
  return Container(
    decoration: BoxDecoration(
      // Made background transparent or semi-transparent
      color: Colors.white.withValues(alpha: 0.1), // Very subtle white overlay
      borderRadius: BorderRadius.circular(14),
      // Optional: Add a subtle border for definition
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
    child: TextField(
      onChanged: (value) {
        context.read<DocumentProvider>().setSearchQuery(value);
      },
      decoration: InputDecoration(
        hintText: 'Search documents, types, or content...',
        hintStyle: GoogleFonts.inter(
          color: Colors.white.withValues(alpha: 0.7), // Made hint text lighter for transparency
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Container(
          padding: const EdgeInsets.all(14),
          child: Icon(
            MdiIcons.magnify,
            color: Colors.white.withValues(alpha: 0.8), // Made icon semi-transparent white
            size: 20,
          ),
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      style: GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.white, // Made text white for better contrast on transparent background
      ),
    ),
  );
}

Widget _buildFilterDropdown() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      // Made background transparent with subtle overlay
      color: Colors.white.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.2),
        width: 1,
      ),
    ),
    child: DropdownButton<DocumentType?>(
      value: _selectedType,
      hint: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            MdiIcons.filterOutline,
            size: 18,
            color: Colors.white.withValues(alpha: 0.8), // Made icon semi-transparent white
          ),
          const SizedBox(width: 8),
          Text(
            'All Types',
            style: GoogleFonts.inter(
              color: Colors.white, // Made text white
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
      items: [
        DropdownMenuItem<DocumentType?>(
          value: null,
          child: Row(
            children: [
              Icon(
                MdiIcons.fileDocumentMultipleOutline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'All Types',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        ...DocumentType.values.map((type) {
          return DropdownMenuItem<DocumentType?>(
            value: type,
            child: Row(
              children: [
                Icon(
                  _getDocumentTypeIcon(type),
                  size: 16,
                  color: _getDocumentTypeColor(type),
                ),
                const SizedBox(width: 8),
                Text(
                  _getDocumentTypeDisplayName(type),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
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
      borderRadius: BorderRadius.circular(12),
      dropdownColor: Theme.of(context).colorScheme.surface,
      elevation: 8,
      icon: Icon(
        MdiIcons.chevronDown,
        color: Colors.white.withValues(alpha: 0.8), // Made dropdown arrow semi-transparent white
        size: 20,
      ),
      // Made selected text color white
      selectedItemBuilder: (BuildContext context) {
        return [null, ...DocumentType.values].map<Widget>((value) {
          return Container(
            alignment: Alignment.centerLeft,
            child: Text(
              value == null ? 'All Types' : _getDocumentTypeDisplayName(value),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          );
        }).toList();
      },
    ),
  );}

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
      final animationDelay = index * 0.1;
      final slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(
          animationDelay.clamp(0.0, 1.0),
          (animationDelay + 0.3).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ));
      final fadeAnimation = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _staggerController,
        curve: Interval(
          animationDelay.clamp(0.0, 1.0),
          (animationDelay + 0.3).clamp(0.0, 1.0),
          curve: Curves.easeOut,
        ),
      ));
      return SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: _buildDocumentCard(document, index),
        ),
      );
    },
  );
}

Widget _buildDocumentCard(MedicalDocument document, [int? index]) {
  final isHovered = index != null && _hoveredDocumentIndex == index;
  return MouseRegion(
    onEnter: index != null ? (_) => setState(() => _hoveredDocumentIndex = index) : null,
    onExit: index != null ? (_) => setState(() => _hoveredDocumentIndex = null) : null,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150), // Reduced from 200ms for faster response
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // Completely transparent background, no grey
        color: isHovered 
          ? Colors.white.withValues(alpha: 0.08) 
          : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHovered 
            ? Colors.white.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: isHovered ? [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ] : [],
      ),
      child: Material(
        color: Colors.transparent, // Ensure no grey background
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _viewDocument(document),
          hoverColor: Colors.transparent, // Remove default hover grey
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.transparent, // Remove default highlight grey
          child: Container( // Removed AnimatedContainer to reduce delay
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Enhanced document type icon with hover animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 100), // Faster animation
                  tween: Tween(begin: 1.0, end: isHovered ? 1.05 : 1.0), // Reduced scale for subtlety
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getDocumentTypeColor(document.type).withValues(alpha: isHovered ? 0.2 : 0.15),
                              _getDocumentTypeColor(document.type).withValues(alpha: isHovered ? 0.12 : 0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isHovered ? [
                            BoxShadow(
                              color: _getDocumentTypeColor(document.type).withValues(alpha: 0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ] : [
                            BoxShadow(
                              color: _getDocumentTypeColor(document.type).withValues(alpha: 0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getDocumentTypeIcon(document.type),
                          color: _getDocumentTypeColor(document.type),
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 20),
                // Enhanced document information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Document name with better typography
                      Text(
                        document.name,
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // File details with improved layout
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _getFileExtension(document.fileName),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            MdiIcons.circle,
                            size: 4,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatFileSize(document.fileSizeBytes),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Upload date with icon
                      Row(
                        children: [
                          Icon(
                            MdiIcons.clockOutline,
                            size: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(document.uploadDate),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Enhanced status and action area
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Enhanced status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getStatusColor(document.processingStatus).withValues(alpha: 0.15),
                            _getStatusColor(document.processingStatus).withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(document.processingStatus).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getStatusColor(document.processingStatus),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _getStatusText(document.processingStatus),
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(document.processingStatus),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // View button with improved hover animation
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 100), // Faster response
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isHovered 
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isHovered 
                            ? Colors.white.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        MdiIcons.arrowRight,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}

  String _getDocumentTypeDisplayName(DocumentType type) {
    switch (type) {
      case DocumentType.labReport:
        return 'Lab Reports';
      case DocumentType.prescription:
        return 'Prescriptions';
      case DocumentType.discharge:
        return 'Discharge Papers';
      case DocumentType.xray:
        return 'X-Ray & Imaging';
      case DocumentType.consultation:
        return 'Consultation Notes';
      case DocumentType.insurance:
        return 'Insurance Forms';
      case DocumentType.general:
        return 'General Documents';
    }
  }

  String _getFileExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toUpperCase() : 'FILE';
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



