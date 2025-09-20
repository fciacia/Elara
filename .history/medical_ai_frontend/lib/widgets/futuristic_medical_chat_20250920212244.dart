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
  final String _selectedPatientId = 'P001'; // Default patient
  
  // File upload state
  bool _isDragOver = false;
  List<PlatformFile> _uploadedFiles = [];
  bool _isProcessing = false;
  String _processingStatus = '';

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
    _animationController!.forward();
  }

  @override
  void dispose() {
  _animationController?.dispose();
    _messageController.dispose();
    _scrollController.dispose();
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
                      width: isTablet ? 240 : 280,
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
                  // Right Panel - responsive width
                  if (!isMobile && !isTablet)
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          left: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), width: 1),
                        ),
                      ),
                      child: _buildPatientContext(),
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
                  'Ready to help with your medical documents',
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
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
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

  Widget _buildPatientContext() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                MdiIcons.account,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Patient Context',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Patient Info Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withValues(alpha: 0.1),
                  Colors.blue.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'A',
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
                        'Ahmad Ibrahim',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Age 45 • IC: 123456-78-9012',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Critical Info Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withValues(alpha: 0.1),
                  Colors.orange.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CRITICAL INFO',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.orange[700],
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildCriticalInfoItem('Allergies', 'Penicillin, Aspirin'),
                const SizedBox(height: 8),
                _buildCriticalInfoItem('Comorbidities', 'Type 2 Diabetes, Hypertension'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Recent Vitals Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Vitals',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              _buildVitalRow('Blood Pressure', '140/90 mmHg', Colors.orange),
              const SizedBox(height: 8),
              _buildVitalRow('Heart Rate', '72 bpm', Colors.green),
              const SizedBox(height: 8),
              _buildVitalRow('Temperature', '37.2°C', Colors.blue),
              const SizedBox(height: 8),
              _buildVitalRow('Blood Sugar', '8.5 mmol/L', Colors.orange),
            ],
          ),
        ],
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
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.white,
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
}