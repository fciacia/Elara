import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'auth_provider.dart';

enum MessageType { user, assistant, system }
enum MessageStatus { sending, sent, delivered, error }

class ChatMessage {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final MessageStatus status;
  final String? originalLanguage;
  final String? translatedContent;
  final List<String>? documentReferences;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.status = MessageStatus.sent,
    this.originalLanguage,
    this.translatedContent,
    this.documentReferences,
    this.metadata,
  });

  ChatMessage copyWith({
    String? content,
    MessageStatus? status,
    String? translatedContent,
    List<String>? documentReferences,
    Map<String, dynamic>? metadata,
  }) {
    return ChatMessage(
      id: id,
      content: content ?? this.content,
      type: type,
      timestamp: timestamp,
      status: status ?? this.status,
      originalLanguage: originalLanguage,
      translatedContent: translatedContent ?? this.translatedContent,
      documentReferences: documentReferences ?? this.documentReferences,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<ChatMessage> messages;
  final UserRole userRole;
  final String? patientId;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
    this.messages = const [],
    required this.userRole,
    this.patientId,
  });
}

class ChatProvider extends ChangeNotifier {
  final Uuid _uuid = const Uuid();
  
  List<ChatSession> _chatSessions = [];
  ChatSession? _currentSession;
  bool _isLoading = false;
  bool _isTyping = false;
  String? _errorMessage;
  String _currentLanguage = 'en';
  
  // Getters
  List<ChatSession> get chatSessions => _chatSessions;
  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get currentMessages => _currentSession?.messages ?? [];
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String? get errorMessage => _errorMessage;
  String get currentLanguage => _currentLanguage;

  // Demo responses for different roles
  final Map<UserRole, List<String>> _demoResponses = {
    UserRole.nurse: [
      "Patient vitals are stable. Temperature: 98.6°F. Continue monitoring every 4 hours.",
      "Medication administration completed. Next dose scheduled for 14:00. Patient tolerated medication well.",
      "Patient shows signs of improvement. Pain level decreased from 7/10 to 4/10. Continue current pain management.",
      "IV line is patent and functioning well. Fluids running at prescribed rate. Monitor for signs of infiltration.",
      "Patient education completed regarding post-discharge care. Family understands wound care instructions.",
    ],
    UserRole.doctor: [
      "Patient's cardiac enzymes are within normal limits. Troponin levels: 0.02 ng/mL (normal <0.04). EKG shows normal sinus rhythm.",
      "Drug interaction analysis complete: No significant interactions detected between current medications. Monitor liver function.",
      "Patient history shows recurrent UTIs. Consider prophylactic antibiotics. Culture sensitivity suggests ciprofloxacin resistance.",
      "Imaging results: Minor osteoarthritis in knee joint. Recommend physical therapy and NSAIDs for symptom management.",
      "Lab trend analysis: HbA1c improved from 8.2% to 6.8% over 3 months. Current diabetes management is effective.",
    ],
    UserRole.admin: [
      "ICD-10 coding verification: Primary diagnosis Z00.00 (routine health examination) is correctly documented.",
      "Insurance claim analysis: All required signatures and documentation present. Claim meets approval criteria.",
      "Document compliance check: Missing physician signature on discharge summary dated March 15th.",
      "Billing code validation: CPT code 99213 appropriate for level of service provided during consultation.",
      "Quality metrics: Patient satisfaction scores show 95% approval rating for this department this quarter.",
    ],
  };

  // Initialize chat provider
  void initialize() {
    _createDemoSessions();
  }

  void _createDemoSessions() {
    _chatSessions = [
      ChatSession(
        id: _uuid.v4(),
        title: 'Blood Test Results Discussion',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        lastMessageAt: DateTime.now().subtract(const Duration(hours: 1)),
        userRole: UserRole.nurse,
        messages: [
          ChatMessage(
            id: '1-1',
            content: 'Can you explain my latest blood test results?',
            type: MessageType.user,
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ChatMessage(
            id: '1-2',
            content: 'Based on your blood test results from March 2024, your white blood cell count is normal at 7,200/μL, indicating no signs of infection or immune system issues. Your other lab values are also within normal ranges.',
            type: MessageType.assistant,
            timestamp: DateTime.now().subtract(const Duration(days: 2, minutes: 1)),
            documentReferences: ['blood_test_march_2024.pdf'],
          ),
        ],
      ),
      ChatSession(
        id: _uuid.v4(),
        title: 'Heart Medication Questions',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        lastMessageAt: DateTime.now().subtract(const Duration(minutes: 30)),
        userRole: UserRole.nurse,
        messages: [
          ChatMessage(
            id: '2-1',
            content: 'What are the side effects of my heart medication?',
            type: MessageType.user,
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ChatMessage(
            id: '2-2',
            content: 'Your prescribed Metformin 500mg may cause mild side effects such as nausea, upset stomach, or diarrhea, especially when first starting. These usually improve over time. Take with food to minimize stomach irritation.',
            type: MessageType.assistant,
            timestamp: DateTime.now().subtract(const Duration(days: 1, minutes: 1)),
            documentReferences: ['heart_medication_rx.pdf'],
          ),
        ],
      ),
    ];
    notifyListeners();
  }

  // Start new chat session
  Future<void> startNewSession(UserRole userRole, String? patientId) async {
    final sessionId = _uuid.v4();
    final newSession = ChatSession(
      id: sessionId,
      title: 'New Conversation',
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
      userRole: userRole,
      patientId: patientId,
    );

    _chatSessions.insert(0, newSession);
    _currentSession = newSession;
    notifyListeners();
  }

  // Switch to existing session
  void switchToSession(String sessionId) {
    _currentSession = _chatSessions.firstWhere(
      (session) => session.id == sessionId,
      orElse: () => _chatSessions.first,
    );
    notifyListeners();
  }

  // Send message
  Future<void> sendMessage(String content, UserRole userRole) async {
    if (_currentSession == null) {
      await startNewSession(userRole, null);
    }

    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    _addMessageToCurrentSession(userMessage);

    // Update session title if it's the first message
    if (_currentSession!.messages.length == 1) {
      _updateSessionTitle(content);
    }

    // Simulate AI typing
    _setTyping(true);
    await Future.delayed(const Duration(seconds: 2));

    // Generate AI response
    final aiResponse = _generateAIResponse(content, userRole);
    final aiMessage = ChatMessage(
      id: _uuid.v4(),
      content: aiResponse,
      type: MessageType.assistant,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
      documentReferences: _getRelevantDocuments(content),
    );

    _addMessageToCurrentSession(aiMessage);
    _setTyping(false);
  }

  // Add message to current session
  void _addMessageToCurrentSession(ChatMessage message) {
    if (_currentSession == null) return;

    final updatedMessages = List<ChatMessage>.from(_currentSession!.messages)
      ..add(message);

    final updatedSession = ChatSession(
      id: _currentSession!.id,
      title: _currentSession!.title,
      createdAt: _currentSession!.createdAt,
      lastMessageAt: DateTime.now(),
      messages: updatedMessages,
      userRole: _currentSession!.userRole,
      patientId: _currentSession!.patientId,
    );

    // Update in sessions list
    final sessionIndex = _chatSessions.indexWhere(
      (session) => session.id == _currentSession!.id,
    );
    if (sessionIndex != -1) {
      _chatSessions[sessionIndex] = updatedSession;
    }

    _currentSession = updatedSession;
    notifyListeners();
  }

  // Generate AI response based on user role and query
  String _generateAIResponse(String query, UserRole userRole) {
    final responses = _demoResponses[userRole] ?? _demoResponses[UserRole.nurse]!;
    
    // Simple keyword-based response selection
    if (query.toLowerCase().contains('blood') || query.toLowerCase().contains('test')) {
      return responses[0];
    } else if (query.toLowerCase().contains('medication') || query.toLowerCase().contains('drug')) {
      return responses[1];
    } else if (query.toLowerCase().contains('x-ray') || query.toLowerCase().contains('chest')) {
      return responses[2];
    } else if (query.toLowerCase().contains('insurance') || query.toLowerCase().contains('claim')) {
      return responses[3];
    } else {
      return responses[4];
    }
  }

  // Get relevant documents for query
  List<String> _getRelevantDocuments(String query) {
    final List<String> relevantDocs = [];
    
    if (query.toLowerCase().contains('blood') || query.toLowerCase().contains('test')) {
      relevantDocs.add('blood_test_march_2024.pdf');
    }
    if (query.toLowerCase().contains('medication') || query.toLowerCase().contains('prescription')) {
      relevantDocs.add('heart_medication_rx.pdf');
    }
    if (query.toLowerCase().contains('x-ray') || query.toLowerCase().contains('chest')) {
      relevantDocs.add('chest_xray_report.pdf');
    }
    if (query.toLowerCase().contains('discharge') || query.toLowerCase().contains('hospital')) {
      relevantDocs.add('discharge_summary_feb2024.pdf');
    }

    return relevantDocs;
  }

  // Update session title
  void _updateSessionTitle(String firstMessage) {
    if (_currentSession == null) return;

    String title = firstMessage.length > 30 
        ? '${firstMessage.substring(0, 30)}...' 
        : firstMessage;

    final updatedSession = ChatSession(
      id: _currentSession!.id,
      title: title,
      createdAt: _currentSession!.createdAt,
      lastMessageAt: _currentSession!.lastMessageAt,
      messages: _currentSession!.messages,
      userRole: _currentSession!.userRole,
      patientId: _currentSession!.patientId,
    );

    final sessionIndex = _chatSessions.indexWhere(
      (session) => session.id == _currentSession!.id,
    );
    if (sessionIndex != -1) {
      _chatSessions[sessionIndex] = updatedSession;
    }

    _currentSession = updatedSession;
    notifyListeners();
  }

  // Delete session
  Future<void> deleteSession(String sessionId) async {
    _chatSessions.removeWhere((session) => session.id == sessionId);
    
    if (_currentSession?.id == sessionId) {
      _currentSession = _chatSessions.isNotEmpty ? _chatSessions.first : null;
    }
    
    notifyListeners();
  }

  // Clear all sessions
  Future<void> clearAllSessions() async {
    _chatSessions.clear();
    _currentSession = null;
    notifyListeners();
  }

  // Translate message
  Future<void> translateMessage(String messageId, String targetLanguage) async {
    if (_currentSession == null) return;

    final messageIndex = _currentSession!.messages.indexWhere(
      (message) => message.id == messageId,
    );
    
    if (messageIndex == -1) return;

    _setLoading(true);

    try {
      // Simulate translation API call
      await Future.delayed(const Duration(seconds: 1));
      
      final originalMessage = _currentSession!.messages[messageIndex];
      final translatedMessage = originalMessage.copyWith(
        translatedContent: _simulateTranslation(originalMessage.content, targetLanguage),
      );

      final updatedMessages = List<ChatMessage>.from(_currentSession!.messages);
      updatedMessages[messageIndex] = translatedMessage;

      final updatedSession = ChatSession(
        id: _currentSession!.id,
        title: _currentSession!.title,
        createdAt: _currentSession!.createdAt,
        lastMessageAt: _currentSession!.lastMessageAt,
        messages: updatedMessages,
        userRole: _currentSession!.userRole,
        patientId: _currentSession!.patientId,
      );

      _currentSession = updatedSession;
      
      final sessionIndex = _chatSessions.indexWhere(
        (session) => session.id == _currentSession!.id,
      );
      if (sessionIndex != -1) {
        _chatSessions[sessionIndex] = updatedSession;
      }

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Simulate translation (in real app, this would call a translation API)
  String _simulateTranslation(String text, String targetLanguage) {
    switch (targetLanguage) {
      case 'ms':
        return '[Bahasa Melayu] $text';
      case 'zh':
        return '[中文] $text';
      case 'ta':
        return '[தமிழ்] $text';
      default:
        return text;
    }
  }

  // Set language preference
  void setLanguage(String languageCode) {
    _currentLanguage = languageCode;
    notifyListeners();
  }

  // Get session statistics
  Map<String, int> getSessionStats() {
    return {
      'totalSessions': _chatSessions.length,
      'totalMessages': _chatSessions.fold<int>(
        0, (sum, session) => sum + session.messages.length,
      ),
      'todaySessions': _chatSessions.where(
        (session) => session.createdAt.isAfter(
          DateTime.now().subtract(const Duration(days: 1)),
        ),
      ).length,
    };
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }
}
