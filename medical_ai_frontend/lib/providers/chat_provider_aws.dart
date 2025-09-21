import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../services/aws_api_service.dart';
import 'auth_provider.dart'; // Import for UserRole enum

// Import models and enums from existing chat provider
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
  final String? confidence;
  final List<DocumentSource>? sources;

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
    this.confidence,
    this.sources,
  });

  ChatMessage copyWith({
    String? content,
    MessageStatus? status,
    String? translatedContent,
    List<String>? documentReferences,
    Map<String, dynamic>? metadata,
    String? confidence,
    List<DocumentSource>? sources,
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
      confidence: confidence ?? this.confidence,
      sources: sources ?? this.sources,
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
  final String? sessionId;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
    this.messages = const [],
    required this.userRole,
    this.patientId,
    this.sessionId,
  });
}

class ChatProvider with ChangeNotifier {
  final AWSApiService _apiService = AWSApiService();
  final Uuid _uuid = const Uuid();

  // State variables
  List<ChatSession> _chatSessions = [];
  ChatSession? _currentSession;
  bool _isTyping = false;
  String? _error;
  String _currentLanguage = 'en';

  // Getters
  List<ChatSession> get chatSessions => _chatSessions;
  ChatSession? get currentSession => _currentSession;
  bool get isTyping => _isTyping;
  String? get error => _error;
  String get currentLanguage => _currentLanguage;

  // Clear error
  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // Set error
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Set typing state
  void _setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  // Start new chat session
  Future<void> startNewSession(UserRole userRole, String? patientId) async {
    final newSession = ChatSession(
      id: _uuid.v4(),
      title: 'New Consultation',
      createdAt: DateTime.now(),
      lastMessageAt: DateTime.now(),
      messages: [],
      userRole: userRole,
      patientId: patientId,
    );

    _chatSessions.insert(0, newSession);
    _currentSession = newSession;
    _clearError();
    notifyListeners();
  }

  // Switch to existing session
  void switchToSession(String sessionId) {
    final session = _chatSessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => _chatSessions.first,
    );
    _currentSession = session;
    _clearError();
    notifyListeners();
  }

  // Update session title
  void _updateSessionTitle(String content) {
    if (_currentSession == null) return;

    final title = content.length > 30 
        ? '${content.substring(0, 30)}...' 
        : content;

    final updatedSession = ChatSession(
      id: _currentSession!.id,
      title: title,
      createdAt: _currentSession!.createdAt,
      lastMessageAt: _currentSession!.lastMessageAt,
      messages: _currentSession!.messages,
      userRole: _currentSession!.userRole,
      patientId: _currentSession!.patientId,
      sessionId: _currentSession!.sessionId,
    );

    final sessionIndex = _chatSessions.indexWhere(
      (session) => session.id == _currentSession!.id,
    );
    
    if (sessionIndex != -1) {
      _chatSessions[sessionIndex] = updatedSession;
      _currentSession = updatedSession;
      notifyListeners();
    }
  }

  // Update session ID from AWS response
  void _updateSessionId(String sessionId) {
    if (_currentSession == null) return;

    final updatedSession = ChatSession(
      id: _currentSession!.id,
      title: _currentSession!.title,
      createdAt: _currentSession!.createdAt,
      lastMessageAt: _currentSession!.lastMessageAt,
      messages: _currentSession!.messages,
      userRole: _currentSession!.userRole,
      patientId: _currentSession!.patientId,
      sessionId: sessionId,
    );

    final sessionIndex = _chatSessions.indexWhere(
      (session) => session.id == _currentSession!.id,
    );
    
    if (sessionIndex != -1) {
      _chatSessions[sessionIndex] = updatedSession;
      _currentSession = updatedSession;
      notifyListeners();
    }
  }

  // Update message status
  void _updateMessageStatus(String messageId, MessageStatus status) {
    if (_currentSession == null) return;

    final updatedMessages = _currentSession!.messages.map((msg) {
      if (msg.id == messageId) {
        return msg.copyWith(status: status);
      }
      return msg;
    }).toList();

    final updatedSession = ChatSession(
      id: _currentSession!.id,
      title: _currentSession!.title,
      createdAt: _currentSession!.createdAt,
      lastMessageAt: DateTime.now(),
      messages: updatedMessages,
      userRole: _currentSession!.userRole,
      patientId: _currentSession!.patientId,
      sessionId: _currentSession!.sessionId,
    );

    final sessionIndex = _chatSessions.indexWhere(
      (session) => session.id == _currentSession!.id,
    );
    
    if (sessionIndex != -1) {
      _chatSessions[sessionIndex] = updatedSession;
      _currentSession = updatedSession;
      notifyListeners();
    }
  }

  // Send message to AWS API
  Future<void> sendMessage(String content, UserRole userRole) async {
    print('\n🔵 [CHAT] Starting sendMessage...');
    print('📝 [CHAT] User message: "${content.length > 100 ? content.substring(0, 100) + "..." : content}"');
    print('👤 [CHAT] User role: ${userRole.toString().split('.').last}');
    
    if (_currentSession == null) {
      print('🆕 [CHAT] No active session, creating new one...');
      await startNewSession(userRole, null);
      print('✅ [CHAT] New session created: ${_currentSession?.id}');
    }

    if (content.trim().isEmpty) {
      print('⚠️ [CHAT] Empty message content, aborting');
      return;
    }

    _clearError();

    // Add user message immediately
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: content,
      type: MessageType.user,
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );

    print('💬 [CHAT] Adding user message to session...');
    _addMessageToCurrentSession(userMessage);

    // Update session title if it's the first message
    if (_currentSession!.messages.length == 1) {
      print('📑 [CHAT] First message, updating session title...');
      _updateSessionTitle(content);
    }

    // Set loading state
    print('⏳ [CHAT] Setting loading state...');
    _setTyping(true);

    try {
      // Convert UserRole to string for API
      final userTypeString = _userRoleToString(userRole);
      
      print('\n🚀 [API] Preparing AWS Lambda request...');
      print('🎯 [API] Endpoint: query medical documents');
      print('📊 [API] Parameters:');
      print('   - Question: "${content.length > 50 ? content.substring(0, 50) + "..." : content}"');
      print('   - User Type: $userTypeString');
      print('   - Language: $_currentLanguage');
      print('   - Patient ID: ${_currentSession!.patientId ?? "null"}');
      print('   - Session ID: ${_currentSession!.sessionId ?? "new"}');
      
      // Call AWS API
      print('📡 [API] Sending request to Lambda...');
      final stopwatch = Stopwatch()..start();
      
      final response = await _apiService.queryMedicalDocuments(
        question: content,
        userType: userTypeString,
        language: _currentLanguage,
        patientId: _currentSession!.patientId,
      );
      
      stopwatch.stop();
      print('✅ [API] Lambda response received in ${stopwatch.elapsedMilliseconds}ms');
      
      // Log response details
      print('\n📥 [RESPONSE] Lambda response details:');
      print('   - Answer length: ${response.answer.length} characters');
      print('   - Confidence: ${response.confidence}');
      print('   - Sources count: ${response.sources?.length ?? 0}');
      print('   - Session ID: ${response.sessionId ?? "not provided"}');
      print('   - Total docs found: ${response.totalDocumentsFound}');
      
      if (response.sources != null && response.sources!.isNotEmpty) {
        print('📚 [SOURCES] Document sources:');
        for (int i = 0; i < response.sources!.length; i++) {
          final source = response.sources![i];
          print('   ${i + 1}. ${source.title ?? source.id} (Confidence: ${source.confidence}, Relevance: ${source.relevanceScore ?? "N/A"})');
        }
      }

      // Update user message status to sent
      print('📤 [CHAT] Updating user message status to sent...');
      _updateMessageStatus(userMessage.id, MessageStatus.sent);

      // Create AI response message
      print('🤖 [CHAT] Creating AI response message...');
      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: response.answer,
        type: MessageType.assistant,
        timestamp: response.timestamp,
        status: MessageStatus.sent,
        confidence: response.confidence,
        sources: response.sources,
        documentReferences: response.sources?.map((s) => s.title ?? s.id).toList(),
        metadata: {
          'total_documents_found': response.totalDocumentsFound,
          'session_id': response.sessionId,
          'response_time_ms': stopwatch.elapsedMilliseconds,
        },
      );

      _addMessageToCurrentSession(aiMessage);
      print('✅ [CHAT] AI response added to session');

      // Update session with AWS session ID if provided
      if (response.sessionId != null && _currentSession!.sessionId != response.sessionId) {
        print('🔄 [SESSION] Updating session ID: ${_currentSession!.sessionId} → ${response.sessionId}');
        _updateSessionId(response.sessionId!);
      }

      print('🎉 [CHAT] Message processing completed successfully!\n');

    } catch (e, stackTrace) {
      print('\n❌ [ERROR] Lambda request failed!');
      print('🚨 [ERROR] Error type: ${e.runtimeType}');
      print('📝 [ERROR] Error message: ${e.toString()}');
      print('🔍 [ERROR] Stack trace: ${stackTrace.toString().split('\n').take(5).join('\n')}');
      
      // Update user message status to error
      print('🔄 [CHAT] Updating user message status to error...');
      _updateMessageStatus(userMessage.id, MessageStatus.error);
      
      // Add error message
      _setError('Failed to get response: ${e.toString()}');
      
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        content: 'Sorry, I encountered an error while processing your request. Please try again.',
        type: MessageType.assistant,
        timestamp: DateTime.now(),
        status: MessageStatus.error,
        metadata: {
          'error': e.toString(),
          'error_type': e.runtimeType.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      _addMessageToCurrentSession(errorMessage);
      print('🚨 [CHAT] Error message added to session');
      print('💔 [CHAT] Message processing failed!\n');
    } finally {
      _setTyping(false);
      print('🏁 [CHAT] Clearing loading state - sendMessage complete\n');
    }
  }

  // Convert UserRole enum to string for API
  String _userRoleToString(UserRole userRole) {
    switch (userRole) {
      case UserRole.doctor:
        return 'doctor';
      case UserRole.nurse:
        return 'nurse';
      case UserRole.admin:
        return 'admin';
    }
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
      sessionId: _currentSession!.sessionId,
    );

    // Update in sessions list
    final sessionIndex = _chatSessions.indexWhere(
      (session) => session.id == _currentSession!.id,
    );
    
    if (sessionIndex != -1) {
      _chatSessions[sessionIndex] = updatedSession;
      _currentSession = updatedSession;
      notifyListeners();
    }
  }

  // Delete session
  void deleteSession(String sessionId) {
    _chatSessions.removeWhere((session) => session.id == sessionId);
    
    if (_currentSession?.id == sessionId) {
      _currentSession = _chatSessions.isNotEmpty ? _chatSessions.first : null;
    }
    
    notifyListeners();
  }

  // Set language
  void setLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }

  // Clear all sessions
  void clearAllSessions() {
    _chatSessions.clear();
    _currentSession = null;
    _clearError();
    notifyListeners();
  }
}
