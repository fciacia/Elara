// ...imports remain unchanged...
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/auth_provider.dart' as auth;
import '../providers/chat_provider_aws.dart';
import '../utils/app_colors.dart';

class CleanChatInterface extends StatefulWidget {
  const CleanChatInterface({super.key});

  @override
  State<CleanChatInterface> createState() => _CleanChatInterfaceState();
}

class _HoverableItem extends StatefulWidget {
  final Widget Function(bool isHovered) child;
  final VoidCallback? onTap;

  const _HoverableItem({
    required this.child,
    this.onTap,
  });

  @override
  State<_HoverableItem> createState() => _HoverableItemState();
}

class _HoverableItemState extends State<_HoverableItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: widget.child(_isHovered),
      ),
    );
  }
}

class _CleanChatInterfaceState extends State<CleanChatInterface> with TickerProviderStateMixin {
  // Animation controllers
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  late AnimationController _logoAnimationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<Offset> _logoSlideAnimation;
  
  // Controllers
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Selection state variables
  String? selectedPatient;
  String? selectedChatSession;
  String _rightPanelContent = 'patient'; // 'patient' or 'chat'
  
  // File upload state
  bool _isDragOver = false;
  final List<PlatformFile> _uploadedFiles = [];
  bool _isProcessing = false;
  String _processingStatus = '';
  
  // Patient context panel state
  bool _showPatientContext = true;
  late AnimationController _panelAnimationController;
  late Animation<double> _panelAnimation;
  late TabController _patientTabController;

  // Hardcoded patient data
  final Map<String, Map<String, dynamic>> _patientProfiles = {
    'Emily Chen': {
      'id': 'P001',
      'ic': '123456-78-9012',
      'age': 45,
      'gender': 'Female',
      'bloodType': 'O+',
      'phone': '+60 12-345 6789',
      'emergencyContact': 'Michael Chen (Husband)',
      'allergies': 'None',
      'conditions': 'Diabetes Type 2',
      'surgeries': 'None',
      'familyHistory': 'Hypertension, Diabetes',
      'insurance': 'Great Eastern',
      'policyNumber': 'GE987654321',
      'vitals': {
        'heartRate': '78',
        'temperature': '36.8',
        'oxygen': '97',
        'respRate': '18',
        'bloodPressure': '135/85 mmHg',
        'weight': '75.2 kg',
        'height': '172 cm',
      },
      'medications': [
        {'name': 'Metformin', 'dosage': '850mg • Twice daily', 'condition': 'Diabetes Type 2'},
        {'name': 'Lisinopril', 'dosage': '5mg • Once daily', 'condition': 'Blood pressure'},
      ],
      'notes': [
        {
          'title': 'Diabetes Follow-up',
          'content': 'Blood sugar levels well controlled. Continue current medication regimen...',
          'author': 'Dr. Lim Wei Ming',
          'timestamp': '2 hours ago',
        },
        {
          'title': 'Routine Check-up',
          'content': 'Patient reports good adherence to medication. No side effects noted...',
          'author': 'Nurse Sarah',
          'timestamp': '1 week ago',
        },
      ],
    },
    'Michael Tan': {
      'id': 'P002',
      'ic': '234567-89-0123',
      'age': 29,
      'gender': 'Male',
      'bloodType': 'A+',
      'phone': '+60 12-987 6543',
      'emergencyContact': 'Emily Tan (Wife)',
      'allergies': 'Penicillin',
      'conditions': 'Migraine',
      'surgeries': 'None',
      'familyHistory': 'Migraine, Anxiety',
      'insurance': 'Prudential',
      'policyNumber': 'PR123456789',
      'vitals': {
        'heartRate': '68',
        'temperature': '36.4',
        'oxygen': '99',
        'respRate': '16',
        'bloodPressure': '110/70 mmHg',
        'weight': '58.5 kg',
        'height': '160 cm',
      },
      'medications': [
        {'name': 'Sumatriptan', 'dosage': '50mg • As needed', 'condition': 'Migraine'},
        {'name': 'Propranolol', 'dosage': '40mg • Once daily', 'condition': 'Migraine prevention'},
      ],
      'notes': [
        {
          'title': 'Migraine Consultation',
          'content': 'Patient reports reduced frequency of migraines with current medication...',
          'author': 'Dr. Jennifer Wong',
          'timestamp': '3 days ago',
        },
      ],
    },
    'Aisha Abdullah': {
      'id': 'P003',
      'ic': '345678-90-1234',
      'age': 52,
      'gender': 'Male',
      'bloodType': 'B+',
      'phone': '+60 12-555 7777',
      'emergencyContact': 'Aminah Rahman (Wife)',
      'allergies': 'Shellfish',
      'conditions': 'Hypertension, High Cholesterol',
      'surgeries': 'Gallbladder removal (2019)',
      'familyHistory': 'Cardiac disease, Stroke',
      'insurance': 'AIA',
      'policyNumber': 'AIA555777999',
      'vitals': {
        'heartRate': '75',
        'temperature': '36.6',
        'oxygen': '98',
        'respRate': '17',
        'bloodPressure': '140/90 mmHg',
        'weight': '82.1 kg',
        'height': '175 cm',
      },
      'medications': [
        {'name': 'Amlodipine', 'dosage': '10mg • Once daily', 'condition': 'Hypertension'},
        {'name': 'Atorvastatin', 'dosage': '20mg • Once daily', 'condition': 'High cholesterol'},
        {'name': 'Aspirin', 'dosage': '75mg • Once daily', 'condition': 'Cardiovascular protection'},
      ],
      'notes': [
        {
          'title': 'Cardiovascular Review',
          'content': 'Blood pressure still elevated despite medication. Consider dosage adjustment...',
          'author': 'Dr. Khalid Hassan',
          'timestamp': '1 day ago',
        },
        {
          'title': 'Cholesterol Follow-up',
          'content': 'Cholesterol levels improved significantly. Continue current statin therapy...',
          'author': 'Dr. Khalid Hassan',
          'timestamp': '2 weeks ago',
        },
      ],
    },
  };

  // Hardcoded chat session data
  final Map<String, Map<String, dynamic>> _chatSessions = {
    'session_001': {
      'id': 'session_001',
      'title': 'Blood Test Results Discussion',
      'patientId': 'P001',
      'patientName': 'Emily Chen',
      'createdAt': DateTime.now().subtract(Duration(hours: 2)),
      'messages': [
        {
          'type': 'ai',
          'content': "Hello! I've reviewed Emily Chen's recent blood test results. Her HbA1c is 7.2%, which shows good diabetes control.",
          'timestamp': DateTime.now().subtract(Duration(hours: 2)),
        },
        {
          'type': 'user',
          'content': 'What about her cholesterol levels?',
          'timestamp': DateTime.now().subtract(Duration(hours: 2, minutes: 5)),
        },
        {
          'type': 'ai',
          'content': 'Her total cholesterol is 195 mg/dL, LDL is 125 mg/dL, and HDL is 45 mg/dL. The LDL is slightly elevated and could benefit from dietary modifications.',
          'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 58)),
        },
        {
          'type': 'user',
          'content': 'Should we adjust her medication?',
          'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 55)),
        },
        {
          'type': 'ai',
          'content': "Given her current diabetes control, I'd recommend maintaining her Metformin dosage. For cholesterol, consider adding a low-dose statin if dietary changes don't improve LDL in 3 months.",
          'timestamp': DateTime.now().subtract(Duration(hours: 1, minutes: 50)),
        },
      ],
    },
    'session_002': {
      'id': 'session_002',
      'title': 'Migraine Treatment Plan',
      'patientId': 'P002',
      'patientName': 'Michael Tan',
      'createdAt': DateTime.now().subtract(Duration(days: 1)),
      'messages': [
        {
          'type': 'ai',
          'content': "I've analyzed Michael Tan's migraine pattern. He's been having 2-3 episodes per month, which is a significant improvement from before.",
          'timestamp': DateTime.now().subtract(Duration(days: 1)),
        },
        {
          'type': 'user',
          'content': 'What triggers should we focus on?',
          'timestamp': DateTime.now().subtract(Duration(days: 1, hours: 1)),
        },
        {
          'type': 'ai',
          'content': 'Based on his migraine diary, stress and irregular sleep patterns are the main triggers. His current Propranolol prevention is working well.',
          'timestamp': DateTime.now().subtract(Duration(days: 1, hours: 2)),
        },
        {
          'type': 'user',
          'content': 'Any lifestyle recommendations?',
          'timestamp': DateTime.now().subtract(Duration(days: 1, hours: 3)),
        },
        {
          'type': 'ai',
          'content': 'I recommend maintaining regular sleep schedule (7-8 hours), stress management techniques, and avoiding known dietary triggers like aged cheese and wine.',
          'timestamp': DateTime.now().subtract(Duration(days: 1, hours: 4)),
        },
      ],
    },
  };

  // Method to handle patient selection
  void _selectPatient(String patientName) {
    setState(() {
      selectedPatient = patientName;
      _rightPanelContent = 'patient';
      _showPatientContext = true;
    });
    _panelAnimationController.forward();
    print('Selected patient: $patientName');
  }

  // Method to handle chat session selection
  void _selectChatSession(String sessionId) {
    setState(() {
      selectedChatSession = sessionId;
      _rightPanelContent = 'chat';
      _showPatientContext = true;
    });
    _panelAnimationController.forward();
    print('Selected chat session: $sessionId');
  }

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
      duration: const Duration(milliseconds: 900), // ultra-smooth, longer
      vsync: this,
    );
    _panelAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _panelAnimationController,
      curve: Curves.fastOutSlowIn, // fluid, natural
    ));
    
    if (_showPatientContext) {
      _panelAnimationController.forward();
    }
    
    // Initialize patient tab controller
    _patientTabController = TabController(length: 4, vsync: this);
    
    // Animation logic from user snippet
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeInOut),
    );
    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _logoAnimationController, curve: Curves.easeOutCubic));
    _logoAnimationController.forward();
    _animationController!.forward();
  }

   // Method to select a chat session
  void selectChatSession(String sessionId) {
    try {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.switchToSession(sessionId);
      
      print('Selected chat session: $sessionId');
    } catch (e) {
      print('Session not found: $sessionId');
    }
  }
  
  // Method to check if a session is selected
  bool isSessionSelected(String sessionId) {
    return selectedChatSession == sessionId;
  }

  // Method to clear session selection
  void clearSessionSelection() {
    setState(() {
      selectedChatSession = null;
      _rightPanelContent = 'patient';
    });
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
      return Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
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
  _logoAnimationController.dispose();
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
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'lib/assets/background.png',
            fit: BoxFit.cover,
          ),
        ),
        Builder(
          builder: (context) {
            final screenWidth = MediaQuery.of(context).size.width;
            final isMobile = screenWidth < 768;
            final isTablet = screenWidth < 1024;
            return Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                children: [
                  // Left Sidebar - responsive width
                  if (!isMobile)
                    Container(
                      width: isTablet ? 200 : 240,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                          right: BorderSide(color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), width: 1),
                        ),
                      ),
                      child: _buildLeftSidebar(),
                    ),
                  // Main Chat Area with fade+slide transition
                  Expanded(
                    flex: 2,
                    child: FadeTransition(
                      opacity: _fadeAnimation!,
                      child: SlideTransition(
                        position: _slideAnimation!,
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
                    ),
                  ),
                  // Right Panel - Animated Patient Context
                  AnimatedBuilder(
                    animation: _panelAnimation,
                    builder: (context, child) {
                      if ((!_showPatientContext || isMobile) || (selectedPatient == null && selectedChatSession == null)) {
                        return Container();
                      }
                      final double panelWidth = isTablet ? 280 : 320;
                      return AnimatedSlide(
                        offset: Offset(1 - _panelAnimation.value, 0),
                        duration: _panelAnimationController.duration ?? const Duration(milliseconds: 900),
                        curve: Curves.fastOutSlowIn,
                        child: Container(
                          width: panelWidth,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            boxShadow: _getBoxShadow(context),
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
      ],
    );
  }
  Widget _buildLeftSidebar() {
  // Debug prints to verify initialization
  print('_chatSessions: ${_chatSessions}');
  print('_patientProfiles: ${_patientProfiles}');
  final chatSessionKeys = (_chatSessions != null && _chatSessions is Map<String, dynamic>) ? _chatSessions.keys : <String>[];
  final patientProfileKeys = (_patientProfiles != null && _patientProfiles is Map<String, dynamic>) ? _patientProfiles.keys : <String>[];
    return Column(
      children: [
        // Header (same as before)
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
              // ... rest of header content
            ],
          ),
        ),
        // Chat Sessions and Patients
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildSectionHeader('Chat Sessions', Icons.chat_bubble_outline),
                const SizedBox(height: 8),
                // Hardcoded chat sessions
                ...chatSessionKeys.map((sessionId) => 
                  _buildEnhancedChatSessionItem(sessionId, selectedChatSession == sessionId)
                ),
                const SizedBox(height: 24),
                _buildSectionHeader('Recent Patients', Icons.people_outline),
                const SizedBox(height: 8),
                // Patient list
                ...patientProfileKeys.map((patientName) {
                  final patient = _patientProfiles[patientName]!;
                  return _buildPatientItem(
                    patientName, 
                    patient['ic'], 
                    selectedPatient == patientName
                  );
                }),
                const SizedBox(height: 24),
                _buildSectionHeader('Recent Queries', Icons.history),
                const SizedBox(height: 8),
                _buildQueryItem('Patient care guidelines', '2 hours ago'),
                _buildQueryItem('Diabetes management protocols', '1 day ago'),
                _buildQueryItem('Blood pressure monitoring', '2 days ago'),
                _buildQueryItem('Medication interactions', '3 days ago'),
                _buildQueryItem('Cardiac assessment tools', '1 week ago'),
              ],
            ),
          ),
        ),
      ],
    );
  }


Widget _buildSectionHeader(String title, IconData icon) {
  return Row(
    children: [
      Icon(icon, size: 16, color: const Color.fromARGB(255, 255, 255, 255)),
      const SizedBox(width: 8),
      Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
      ),
    ],
  );
}

// Enhanced chat session with proper hover effect
Widget _buildEnhancedChatSessionItem(String sessionId, bool isSelected) {
  final session = _chatSessions[sessionId];
  if (session == null) return Container();

  return _HoverableItem(
    onTap: () {
      if (selectedChatSession == sessionId) {
        setState(() {
          selectedChatSession = null;
          _rightPanelContent = 'patient';
        });
      } else {
        _selectChatSession(sessionId);
      }
    },
    child: (isHovered) => Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: isSelected 
            ? Colors.grey[400]!
            : (isHovered ? Colors.grey.withValues(alpha: 0.3) : Colors.transparent),
          width: isSelected ? 1 : (isHovered ? 1.5 : 1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue[600]?.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 14,
              color: Colors.blue[400],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session['title'],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isHovered ? Colors.purple[200] : Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Patient: ${session['patientName']}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _formatSessionTime(session['createdAt']),
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            size: 16,
            color: isHovered 
              ? Colors.white.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.5),
          ),
        ],
      ),
    ),
  );
}

// Helper method to format session time (you can customize this)
String _formatSessionTime(DateTime? createdAt) {
  if (createdAt == null) return 'Recently';
  
  final now = DateTime.now();
  final difference = now.difference(createdAt);
  
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else {
    return '${(difference.inDays / 7).floor()}w ago';
  }
}

Widget _buildPatientItem(String name, String ic, bool isSelected) {
  return _HoverableItem(
    onTap: () {
      if (selectedPatient == name) {
        setState(() {
          selectedPatient = null;
          _rightPanelContent = 'chat';
        });
      } else {
        _selectPatient(name);
      }
    },
    child: (isHovered) => Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHovered ? const Color.fromARGB(255, 255, 255, 255).withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected 
            ? Colors.grey[400]!
            : (isHovered ? Colors.grey.withValues(alpha: 0.3) : Colors.transparent),
          width: isSelected ? 1 : (isHovered ? 1.5 : 1),
        ),
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
                    color: isHovered ? Colors.purple[200] : Colors.white,
                  ),
                ),
                Text(
                  ic,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.7),
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
    ),
  );
}

Widget _buildQueryItem(String query, String time) {
  return _HoverableItem(
    child: (isHovered) => Container(
      width: double.infinity, // Ensure full width alignment
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), // Better padding
      decoration: BoxDecoration(
        color: isHovered ? Colors.grey.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isHovered 
            ? Colors.grey.withValues(alpha: 0.3)
            : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Query text with proper alignment
          Container(
            width: double.infinity,
            child: Text(
              query,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: isHovered ? Colors.purple[200] : Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 4),
          // Time with proper alignment
          Container(
            width: double.infinity,
            child: Text(
              time,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
      ),
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
        color: Colors.transparent,
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
              color: Colors.transparent,
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
                  'Ready to assist you with patient care',
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
          color: Colors.transparent,
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
      color: Colors.transparent,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                MdiIcons.robotOutline,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start a conversation',
              style: GoogleFonts.inter(
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me anything about your medical documents',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: const Color.fromARGB(255, 179, 145, 237).withOpacity(0.7),
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
          fontSize: 13,
          color: const Color.fromARGB(255, 192, 176, 219),
        ),
      ),
      onPressed: () {
        _messageController.text = text;
        _sendMessage();
      },
      backgroundColor: Colors.transparent,
      side: BorderSide(color: const Color.fromARGB(255, 206, 201, 213).withValues(alpha: 0.3)),
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
        color: Colors.transparent,
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
                color: Colors.purple[700]?.withValues(alpha: 0.1),
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
                    fillColor: Colors.transparent,
                    isDense: true,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
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
                      boxShadow: _getBoxShadow(context),
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
            boxShadow: _getBoxShadow(context),
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
        color: Colors.transparent,
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2), 
            width: 1
          ),
        ),
      ),
      child: _rightPanelContent == 'patient' 
        ? _buildPatientProfileView()
        : _buildChatHistoryView(),
    );
  }

  // Patient profile view
  Widget _buildPatientProfileView() {
    if (selectedPatient == null) {
      return _buildDefaultPatientView();
    }

    final patient = _patientProfiles[selectedPatient!]!;
    
    return Column(
      children: [
        _buildPatientHeader(),
        _buildDynamicPatientInfo(patient),
        _buildPatientTabBar(),
        Expanded(
          child: TabBarView(
            controller: _patientTabController,
            children: [
              _buildDynamicOverviewTab(patient),
              _buildDynamicVitalsTab(patient),
              _buildDynamicMedicationsTab(patient),
              _buildDynamicNotesTab(patient),
            ],
          ),
        ),
      ],
    );
  }

  // Chat history view
  Widget _buildChatHistoryView() {
    if (selectedChatSession == null) {
      return _buildDefaultChatView();
    }

    final session = _chatSessions[selectedChatSession!]!;
    
    return Column(
      children: [
        _buildChatHistoryHeader(session),
        Expanded(
          child: _buildChatMessages(session),
        ),
      ],
    );
  }

  // Default views when nothing is selected
  Widget _buildDefaultPatientView() {
    return Column(
      children: [
        _buildPatientHeader(),
        _buildPatientInfo(), // Your existing Emily Chen info
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
    );
  }

  Widget _buildDefaultChatView() {
    return Container(
      color: Colors.transparent,
      child: Center(
        child: Text(
          'No chat session selected',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  // Dynamic patient info builder
  Widget _buildDynamicPatientInfo(Map<String, dynamic> patient) {
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
            child: Center(
              child: Text(
                selectedPatient?.substring(0, 2).toUpperCase() ?? 'EC',
                style: const TextStyle(
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
                  selectedPatient ?? 'Emily Chen',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'ID: ${patient['id']} • Age: ${patient['age']}',
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
              'Active',
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

  // Chat history header
  Widget _buildChatHistoryHeader(Map<String, dynamic> session) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Chat History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            session['title'],
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            'Patient: ${session['patientName']}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // Chat messages view
  Widget _buildChatMessages(Map<String, dynamic> session) {
    final messages = session['messages'] as List<Map<String, dynamic>>;
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isAI = message['type'] == 'ai';
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: [
              if (isAI) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    MdiIcons.robotOutline,
                    color: Colors.purple[600],
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isAI ? Colors.grey[50] : Colors.blue[600],
                    borderRadius: BorderRadius.circular(12),
                    border: isAI ? Border.all(color: Colors.grey.withValues(alpha: 0.2)) : null,
                  ),
                  child: Text(
                    message['content'],
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isAI ? Colors.grey[800] : Colors.white,
                    ),
                  ),
                ),
              ),
              if (!isAI) ...[
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
      },
    );
  }

  // Dynamic overview tab
  Widget _buildDynamicOverviewTab(Map<String, dynamic> patient) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientSectionHeader('Personal Information'),
          const SizedBox(height: 12),
          _buildInfoRow('Gender', patient['gender']),
          _buildInfoRow('Age', '${patient['age']} years'),
          _buildInfoRow('Blood Type', patient['bloodType']),
          _buildInfoRow('Phone', patient['phone']),
          _buildInfoRow('Emergency Contact', patient['emergencyContact']),
          const SizedBox(height: 20),
          _buildPatientSectionHeader('Medical History'),
          const SizedBox(height: 12),
          _buildInfoRow('Allergies', patient['allergies']),
          _buildInfoRow('Chronic Conditions', patient['conditions']),
          _buildInfoRow('Previous Surgeries', patient['surgeries']),
          _buildInfoRow('Family History', patient['familyHistory']),
          const SizedBox(height: 20),
          _buildPatientSectionHeader('Insurance & Coverage'),
          const SizedBox(height: 12),
          _buildInfoRow('Insurance Provider', patient['insurance']),
          _buildInfoRow('Policy Number', patient['policyNumber']),
        ],
      ),
    );
  }

  // Dynamic vitals tab
  Widget _buildDynamicVitalsTab(Map<String, dynamic> patient) {
    final vitals = patient['vitals'] as Map<String, dynamic>;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildVitalSignCard(
                  vitals['heartRate'],
                  'bpm',
                  'Heart Rate',
                  Colors.green,
                  MdiIcons.heart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalSignCard(
                  vitals['temperature'],
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
                  vitals['oxygen'],
                  '%',
                  'Oxygen',
                  Colors.green,
                  MdiIcons.lungs,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildVitalSignCard(
                  vitals['respRate'],
                  '/min',
                  'Resp. Rate',
                  Colors.blue,
                  MdiIcons.chartLine,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPatientSectionHeader('Recent Readings'),
          const SizedBox(height: 16),
          _buildRecentReading('Blood Pressure', vitals['bloodPressure'], '2 hours ago'),
          const SizedBox(height: 12),
          _buildRecentReading('Weight', vitals['weight'], '1 day ago'),
          const SizedBox(height: 12),
          _buildRecentReading('Height', vitals['height'], '1 week ago'),
        ],
      ),
    );
  }

  // Dynamic medications tab
  Widget _buildDynamicMedicationsTab(Map<String, dynamic> patient) {
    final meds = patient['medications'] as List<dynamic>;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientSectionHeader('Current Medications'),
          const SizedBox(height: 12),
          ...meds.map((med) => _buildCurrentMedicationCard(med['name'], med['dosage'], med['condition'], Colors.green)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Dynamic notes tab
  Widget _buildDynamicNotesTab(Map<String, dynamic> patient) {
    final notes = patient['notes'] as List<dynamic>;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientSectionHeader('Clinical Notes'),
          const SizedBox(height: 16),
          ...notes.map((note) => _buildClinicalNoteCard(note['title'], note['content'], note['author'], note['timestamp'])),
        ],
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
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