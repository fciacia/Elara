// ...imports remain unchanged...
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import '../providers/auth_provider.dart' as auth;
import '../providers/chat_provider.dart';
import '../utils/app_colors.dart';

class CleanChatInterface extends StatefulWidget {
  const CleanChatInterface({super.key});

  @override
  State<CleanChatInterface> createState() => _CleanChatInterfaceState();
}



class _CleanChatInterfaceState extends State<CleanChatInterface> with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _selectedPatientId = 'P12345'; // Emily Chen
  
  // File upload state
  bool _isDragOver = false;
  List<PlatformFile> _uploadedFiles = [];
  bool _isProcessing = false;
  String _processingStatus = '';
  
  // Patient context panel state
  bool _showPatientContext = true;
  late AnimationController _panelAnimationController;
  late Animation<double> _panelAnimation;
  late TabController _patientTabController;

  // Patient selection state
  String? selectedPatient;
  final List<Map<String, String>> patients = [
    {'name': 'Emily Chen', 'id': 'P12345'},
    {'name': 'John Doe', 'id': 'P67890'},
    {'name': 'Alice Smith', 'id': 'P54321'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeOutCubic));

    // Initialize panel animation controller
    _panelAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _panelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _panelAnimationController,
      curve: Curves.easeInOut,
    ));
    
    if (_showPatientContext) {
      _panelAnimationController.forward();
    }
    
    // Initialize patient tab controller
    _patientTabController = TabController(length: 4, vsync: this);
    
    _animationController!.forward();
  }

  // Helper method for better border colors in light/dark mode
  Color _getBorderColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Theme.of(context).colorScheme.outline.withValues(alpha: 0.2);
    } else {
      return AppColors.borderLight.withValues(alpha: 0.8); // Better visibility in light mode
    }
  }

  // Helper method for secondary text colors in light/dark mode
  Color _getSecondaryTextColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6);
    } else {
      return AppColors.textMedium; // Better contrast for light mode
    }
  }

  // Helper method for muted/placeholder colors in light/dark mode
  Color _getMutedColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3);
    } else {
      return AppColors.textLight; // Better visibility than alpha 0.3 in light mode
    }
  }

  // Helper method for input field fill color
  Color _getInputFillColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3);
    } else {
      return AppColors.surfaceVariantLight; // Solid color for better visibility in light mode
    }
  }

  // Helper method for shadows - light mode should have minimal shadows
  List<BoxShadow> _getBoxShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08), // Much lighter shadow for light mode
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    _panelAnimationController.dispose();
    _patientTabController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final authProvider = context.read<auth.AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    
    chatProvider.sendMessage(
      _messageController.text.trim(), 
      authProvider.currentUser?.role ?? auth.UserRole.nurse
    );
    
    _messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _togglePatientContext() {
    setState(() {
      _showPatientContext = !_showPatientContext;
    });
    
    if (_showPatientContext) {
      _panelAnimationController.forward();
    } else {
      _panelAnimationController.reverse();
    }
  }

  // File handling methods
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _uploadedFiles.addAll(result.files);
        });
        _processFiles(result.files);
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking files: $e')),
        );
      }
    }
  }

  Future<void> _processFiles(List<PlatformFile> files) async {
    setState(() {
      _isProcessing = true;
      _processingStatus = 'Initializing...';
    });

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      
      // Simulate processing steps
      await _simulateProcessing(file.name);
      
      // Add processed file to chat
      if (mounted) {
        final authProvider = context.read<auth.AuthProvider>();
        final chatProvider = context.read<ChatProvider>();
        
        chatProvider.sendMessage(
          '📎 Uploaded and analyzed: ${file.name}\n\n🔍 Document processed successfully! Ask me anything about this file.',
          authProvider.currentUser?.role ?? auth.UserRole.nurse,
        );
      }
    }

    setState(() {
      _isProcessing = false;
      _processingStatus = '';
    });
  }

  Future<void> _simulateProcessing(String fileName) async {
    final steps = [
      '🔍 Scanning document structure...',
      '✍️ Detecting handwritten content...',
      '📊 Extracting tables and charts...',
      '🖼️ Analyzing medical images...',
      '🛡️ Applying privacy protection...',
      '✅ Analysis complete!'
    ];

    for (final step in steps) {
      setState(() {
        _processingStatus = step;
      });
      await Future.delayed(const Duration(milliseconds: 800));
    }
  }

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final isTablet = screenWidth < 1024;
    
    return FadeTransition(
      opacity: _fadeAnimation ?? const AlwaysStoppedAnimation(1.0),
      child: SlideTransition(
        position: _slideAnimation ?? const AlwaysStoppedAnimation(Offset.zero),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Theme.of(context).colorScheme.background,
              child: Row(
                children: [
                  // Left Sidebar - responsive width
                  if (!isMobile)
                    Container(
                      width: isTablet ? 200 : 240,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          right: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), width: 1),
                        ),
                      ),
                      child: _buildLeftSidebar(),
                    ),
                  // Main Chat Area
                  Expanded(
                    flex: 2,
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            _buildChatHeader(),
                            Expanded(child: _buildMessageListWithDragDrop()),
                            _buildUploadedFilesPreview(),
                            _buildMessageInput(),
                          ],
                        ),
                        if (_isProcessing) _buildProcessingOverlay(),
                      ],
                    ),
                  ),
                  // Right Panel - Animated Patient Context
                  AnimatedBuilder(
                    animation: _panelAnimation,
                    builder: (context, child) {
                      if (!_showPatientContext || isMobile) return Container();
                      
                      // Responsive panel width - made narrower
                      final double panelWidth = isTablet ? 280 : 320;
                      
                      return Transform.translate(
                        offset: Offset(
                          (1 - _panelAnimation.value) * panelWidth,
                          0,
                        ),
                        child: Container(
                          width: panelWidth,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(-2, 0),
                              ),
                            ],
                          ),
                          child: _buildPatientContextPanel(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLeftSidebar() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Medical AI Copilot',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButton<Locale>(
                value: Get.locale,
                icon: const Icon(Icons.language, color: Colors.blueAccent),
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text("EN")),
                  DropdownMenuItem(value: Locale('ms'), child: Text("MS")),
                  DropdownMenuItem(value: Locale('zh'), child: Text("中文")),
                ],
                onChanged: (locale) {
                  if (locale != null) {
                    Get.updateLocale(locale);
                  }
                },
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Assistant Active',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final authProvider = context.read<auth.AuthProvider>();
                    final chatProvider = context.read<ChatProvider>();
                    chatProvider.startNewSession(
                      authProvider.currentUser?.role ?? auth.UserRole.nurse,
                      _selectedPatientId,
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: Text(
                    'Start New Session',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Chat Sessions
        Expanded(
          child: Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildSectionHeader('Chat Sessions', Icons.chat_bubble_outline),
                    const SizedBox(height: 8),
                ...chatProvider.chatSessions.take(3).map((session) => 
                      _buildChatSessionItem(session)
                ),                    const SizedBox(height: 24),
                    
                    _buildSectionHeader('Recent Patients', Icons.people_outline),
                    const SizedBox(height: 8),
                    _buildPatientItem('Ahmad Ibrahim', 'IC: 123456-78-9012', true),
                    _buildPatientItem('Sarah Lee', 'IC: 234567-89-0123', false),
                    _buildPatientItem('Dr. Rahman', 'IC: 345678-90-1234', false),
                    
                    const SizedBox(height: 24),
                    
                    _buildSectionHeader('Recent Queries', Icons.history),
                    const SizedBox(height: 8),
                    _buildQueryItem('Patient care guidelines', '2 hours ago'),
                    _buildQueryItem('Diabetes management protocols', '1 day ago'),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildChatSessionItem(ChatSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Blood Test Results Discussion', // Mock title
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          Text(
            '${session.messages.length} messages',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientItem(String name, String ic, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue[50] : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: Colors.blue.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: isSelected ? Colors.blue[600] : Colors.grey[600],
            child: Text(
              name.substring(0, 1),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  ic,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQueryItem(String query, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            query,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Colors.grey[800],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            time,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              MdiIcons.robotOutline,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medical AI Assistant',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  'Ready to help with Emily Chen',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          // Patient context toggle - only show on tablet/desktop
          if (!isMobile)
            IconButton(
              onPressed: _togglePatientContext,
              icon: Icon(
                _showPatientContext ? MdiIcons.accountOff : MdiIcons.account,
                color: _showPatientContext 
                  ? AppColors.primary 
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              tooltip: _showPatientContext ? 'Hide Patient Context' : 'Show Patient Context',
            ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        if (chatProvider.currentSession == null) {
          return _buildWelcomeState();
        }

        final messages = chatProvider.currentSession!.messages;
        
        return Container(
          color: Colors.grey[50],
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return _buildMessageBubble(message);
            },
          ),
        );
      },
    );
  }

  Widget _buildWelcomeState() {
    return Container(
      color: Colors.grey[50],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                MdiIcons.robotOutline,
                size: 48,
                color: Colors.blue[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start a conversation',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything about your medical documents',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSuggestionChip('Explain my blood test results'),
                _buildSuggestionChip('What are my medication side effects?'),
                _buildSuggestionChip('Summarize my medical history'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: Colors.blue[600],
        ),
      ),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
      backgroundColor: Colors.blue[50],
      side: BorderSide(color: Colors.blue.withValues(alpha: 0.3)),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.type == MessageType.user;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                MdiIcons.robotOutline,
                color: Colors.blue[600],
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? Colors.blue[600] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: !isUser ? Border.all(color: Colors.grey.withValues(alpha: 0.2)) : null,
              ),
              child: Text(
                message.content,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isUser ? Colors.white : Colors.grey[800],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue[600],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // File upload button
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: _pickFiles,
                icon: Icon(Icons.attach_file, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20),
                tooltip: 'Upload medical documents',
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 120, // Prevent the input from growing too tall
                ),
                child: TextField(
                  controller: _messageController,
                  maxLines: null, // Allow multiline
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: _uploadedFiles.isNotEmpty 
                        ? 'Ask about your uploaded documents...'
                        : 'Ask me anything about medical care...',
                    hintStyle: GoogleFonts.inter(
                      color: _getSecondaryTextColor(context),
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: _getBorderColor(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: _getBorderColor(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: _getInputFillColor(context),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _sendMessage(),
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
                onPressed: _sendMessage,
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Drag and Drop UI Methods
  Widget _buildMessageListWithDragDrop() {
    return DragTarget<List<String>>(
      builder: (context, candidateData, rejectedData) {
        return Stack(
          children: [
            _buildMessageList(),
            if (_isDragOver)
              Container(
                color: Colors.blue.withValues(alpha: 0.1),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.blue,
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 48,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Drop medical documents here',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Supports: PDF, Images, Word Documents',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      onWillAcceptWithDetails: (details) {
        setState(() {
          _isDragOver = true;
        });
        return true;
      },
      onLeave: (data) {
        setState(() {
          _isDragOver = false;
        });
      },
      onAcceptWithDetails: (details) {
        setState(() {
          _isDragOver = false;
        });
        // Handle dropped files
        _pickFiles();
      },
    );
  }

  Widget _buildUploadedFilesPreview() {
    if (_uploadedFiles.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Uploaded Files',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _uploadedFiles.asMap().entries.map((entry) {
              final index = entry.key;
              final file = entry.value;
              return _buildFileChip(file, index);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFileChip(PlatformFile file, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(file.extension ?? ''),
            size: 16,
            color: Colors.blue[600],
          ),
          const SizedBox(width: 6),
          Text(
            file.name,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _removeFile(index),
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), // Better overlay contrast
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, // Use theme surface color
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 16),
              Text(
                'Processing Document',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _processingStatus,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientContextPanel() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), 
            width: 1
          ),
        ),
      ),
      child: Column(
        children: [
          _buildPatientHeader(),
          _buildPatientInfo(),
          _buildPatientTabBar(),
          Expanded(
            child: TabBarView(
              controller: _patientTabController,
              children: [
                _buildOverviewTab(),
                _buildVitalsTab(),
                _buildMedicationsTab(),
                _buildNotesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), 
            width: 1
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            MdiIcons.account,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Patient Context',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              MdiIcons.refresh,
              size: 20,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            onPressed: () {
              // Refresh patient data
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary, 
                  AppColors.primary.withValues(alpha: 0.8)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'EC',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emily Chen',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'ID: P12345 • Age: 34',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Stable',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), 
            width: 1
          ),
        ),
      ),
      child: TabBar(
        controller: _patientTabController,
        isScrollable: false,
        labelColor: AppColors.primary,
        unselectedLabelColor: _getSecondaryTextColor(context),
        indicatorColor: AppColors.primary,
        labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600
        ),
        unselectedLabelStyle: Theme.of(context).textTheme.labelMedium,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Vitals'),
          Tab(text: 'Meds'),
          Tab(text: 'Notes'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientSectionHeader('Personal Information'),
          const SizedBox(height: 12),
          _buildInfoRow('Gender', 'Female'),
          _buildInfoRow('Date of Birth', 'March 15, 1990'),
          _buildInfoRow('Blood Type', 'A+'),
          _buildInfoRow('Phone', '+60 12-345 6789'),
          _buildInfoRow('Emergency Contact', 'John Chen (Husband)'),
          const SizedBox(height: 20),
          _buildPatientSectionHeader('Medical History'),
          const SizedBox(height: 12),
          _buildInfoRow('Allergies', 'Penicillin, Shellfish'),
          _buildInfoRow('Chronic Conditions', 'Hypertension'),
          _buildInfoRow('Previous Surgeries', 'Appendectomy (2018)'),
          _buildInfoRow('Family History', 'Diabetes, Heart Disease'),
          const SizedBox(height: 20),
          _buildPatientSectionHeader('Insurance & Coverage'),
          const SizedBox(height: 12),
          _buildInfoRow('Insurance Provider', 'Great Eastern'),
          _buildInfoRow('Policy Number', 'GE123456789'),
          _buildInfoRow('Coverage Type', 'Premium Family'),
          _buildInfoRow('Validity', 'Valid until Dec 2024'),
        ],
      ),
    );
  }

  Widget _buildVitalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vital Signs Grid
          Row(
            children: [
              Expanded(
                child: _buildVitalSignCard(
                  '72',
                  'bpm',
                  'Heart Rate',
                  Colors.green,
                  MdiIcons.heart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalSignCard(
                  '36.5',
                  '°C',
                  'Temperature',
                  Colors.blue,
                  MdiIcons.thermometer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildVitalSignCard(
                  '98',
                  '%',
                  'Oxygen',
                  Colors.green,
                  MdiIcons.lungs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalSignCard(
                  '16',
                  '/min',
                  'Resp. Rate',
                  Colors.blue,
                  MdiIcons.chartLine,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Vital Trends Section
          _buildPatientSectionHeader('Vital Trends (7 days)'),
          const SizedBox(height: 16),
          _buildVitalTrendsChart(),
          const SizedBox(height: 24),
          
          // Recent Readings Section
          _buildPatientSectionHeader('Recent Readings'),
          const SizedBox(height: 16),
          _buildRecentReading('Blood Pressure', '120/80 mmHg', '2 hours ago'),
          const SizedBox(height: 12),
          _buildRecentReading('Weight', '65.2 kg', '1 day ago'),
          const SizedBox(height: 12),
          _buildRecentReading('Height', '165 cm', '1 week ago'),
        ],
      ),
    );
  }

  Widget _buildMedicationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientSectionHeader('Current Medications'),
          const SizedBox(height: 12),
          _buildCurrentMedicationCard('Lisinopril', '10mg • Once daily', 'Hypertension', Colors.red),
          const SizedBox(height: 12),
          _buildCurrentMedicationCard('Metformin', '500mg • Twice daily', 'Diabetes prevention', Colors.orange),
          const SizedBox(height: 12),
          _buildCurrentMedicationCard('Vitamin D3', '1000 IU • Once daily', 'Vitamin deficiency', Colors.green),
          const SizedBox(height: 24),
          _buildPatientSectionHeader('Recent Prescriptions'),
          const SizedBox(height: 12),
          _buildRecentPrescriptionCard('Amoxicillin 500mg', 'Dr. Johnson', '5 days ago'),
          const SizedBox(height: 8),
          _buildRecentPrescriptionCard('Ibuprofen 400mg', 'Dr. Johnson', '1 week ago'),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPatientSectionHeader('Clinical Notes'),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Note'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildClinicalNoteCard(
            'Routine Checkup',
            'Patient reports feeling well overall. Blood pressure controlled with current medication...',
            'Dr. Sarah Johnson',
            'Today, 2:30 PM',
          ),
          const SizedBox(height: 12),
          _buildClinicalNoteCard(
            'Follow-up Visit',
            'Blood work results reviewed. All values within normal range. Continue current treatment...',
            'Dr. Michael Wong',
            'Yesterday, 10:15 AM',
          ),
          const SizedBox(height: 12),
          _buildClinicalNoteCard(
            'Initial Consultation',
            'New patient presenting with mild hypertension. Family history of cardiovascular disease...',
            'Dr. Sarah Johnson',
            '3 days ago, 4:45 PM',
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentMedicationCard(String name, String dosage, String condition, Color indicatorColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: indicatorColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dosage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  condition,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPrescriptionCard(String medication, String doctor, String timeAgo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBorderColor(context)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.medication_outlined,
            size: 20,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$doctor • $timeAgo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalNoteCard(String title, String content, String author, String timestamp) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  timestamp,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        author,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'View Full Note',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVitalSignCard(String value, String unit, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: color,
                ),
              ),
              const Spacer(),
              Icon(
                MdiIcons.trendingUp,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                  fontSize: 32,
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalTrendsChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(context),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.chartLine,
            size: 48,
            color: _getMutedColor(context),
          ),
          const SizedBox(height: 12),
          Text(
            'Vital Trends Chart',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: _getSecondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReading(String label, String value, String time) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            time,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ],
    );
  }
}