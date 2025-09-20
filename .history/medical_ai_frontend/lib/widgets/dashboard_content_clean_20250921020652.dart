import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart' as auth;
import 'elara_chat_overlay.dart';
import 'elara_chat_message.dart';
import '../providers/document_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/app_provider.dart';
import '../utils/app_colors.dart';
import 'background_layout.dart';
import 'dart:ui';

class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> with TickerProviderStateMixin {
  // Elara AI chat overlay state
  List<ElaraChatMessage> _elaraMessages = [
    ElaraChatMessage('Hello! How can I assist you today?', false),
  ];
  bool _showAIChatOverlay = false;
  String _elaraInput = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isDarkMode = appProvider.isDarkMode;
        
        Widget sidebar = const SizedBox.shrink(); // No sidebar for dashboard
        Widget homeContent = Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Section
                      _buildWelcomeSection(),
                      const SizedBox(height: 24),
                      // Generative AI Widget
                      _buildGenerativeAIWidget(),
                      const SizedBox(height: 16),
                      // Quick Access Features Row
                      _buildQuickAccessRow(),
                      const SizedBox(height: 32),
                      // Main Content Grid
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column - Chat & Queries
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildRecentChatsCard(),
                                const SizedBox(height: 16),
                                _buildRecentQueriesCard(),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Right Column - Patients & Stats
                          Expanded(
                            flex: 2,
                            child: Column(
                              children: [
                                _buildRecentPatientsCard(),
                                const SizedBox(height: 16),
                                _buildStatsCards(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_showAIChatOverlay)
              ElaraChatOverlay(
                messages: _elaraMessages,
                input: _elaraInput,
                onInputChanged: (value) {
                  setState(() {
                    _elaraInput = value;
                  });
                },
                onSend: () {
                  if (_elaraInput.trim().isNotEmpty) {
                    setState(() {
                      _elaraMessages.add(ElaraChatMessage(_elaraInput.trim(), true));
                      _elaraInput = '';
                    });
                  }
                },
                onClose: () {
                  setState(() {
                    _showAIChatOverlay = false;
                    _elaraInput = '';
                    _elaraMessages = [
                      ElaraChatMessage('Hello! How can I assist you today?', false),
                    ];
                  });
                },
              ),
          ],
        );
        
        return BackgroundLayout(
          sidebar: sidebar, 
          homeContent: homeContent,
          isDarkMode: isDarkMode,
        );
      },
    );
  }

  bool _isHoveringAI = false;

  Widget _buildGenerativeAIWidget() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHoveringAI = true),
      onExit: (_) => setState(() => _isHoveringAI = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _getCardBackgroundColor(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: _getBoxShadow(isDarkMode),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Elara logo and title, left aligned
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _isHoveringAI ? const Color(0xFF3B82F6) : const Color(0xFF6366F1),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                            center: Alignment.center,
                            radius: 0.8,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isHoveringAI ? const Color(0xFF3B82F6).withValues(alpha: 0.25) : const Color(0xFF6366F1).withValues(alpha: 0.12),
                              blurRadius: _isHoveringAI ? 18 : 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.auto_awesome, size: 28, color: Colors.white),
                    ],
                  ),
                ),
                Text(
                  'Elara',
                  style: GoogleFonts.orbitron(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.2,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: _isHoveringAI ? const Color(0xFF3B82F6).withValues(alpha: 0.3) : const Color(0xFF6366F1).withValues(alpha: 0.18),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ask medical questions, generate summaries, or request AI-powered insights.',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 18),
            // Futuristic TextField with glowing border
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _isHoveringAI ? const Color(0xFF3B82F6).withValues(alpha: 0.18) : const Color(0xFF6366F1).withValues(alpha: 0.10),
                    blurRadius: _isHoveringAI ? 12 : 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: TextField(
                style: GoogleFonts.inter(fontSize: 16, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type your prompt for Elara...',
                  hintStyle: GoogleFonts.inter(fontSize: 15, color: Colors.white.withValues(alpha: 0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: const Color(0xFF3B82F6), width: 2.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  suffixIcon: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isHoveringAI
                            ? [const Color(0xFF3B82F6), const Color(0xFF6366F1)]
                            : [const Color(0xFF6366F1), Colors.white.withValues(alpha: 0.1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(Icons.send, color: Colors.white),
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.1),
                ),
                onChanged: (value) {
                  setState(() {
                    _elaraInput = value;
                    if (value.isNotEmpty && !_showAIChatOverlay) {
                      _showAIChatOverlay = true;
                    }
                  });
                },
                onSubmitted: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('AI response coming soon...', style: GoogleFonts.inter()),
                      backgroundColor: const Color(0xFF3B82F6),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<auth.AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final hour = DateTime.now().hour;
        String greeting;
        
        if (hour < 12) {
          greeting = 'Good Morning';
        } else if (hour < 17) {
          greeting = 'Good Afternoon';
        } else {
          greeting = 'Good Evening';
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, Colors.transparent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting, ${user?.name ?? 'Doctor'}!',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getRoleDisplayName(user?.role),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ready to assist with patient care and medical consultations',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.medical_services,
                size: 80,
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessRow() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            'New Chat Session',
            'Start AI consultation',
            Icons.chat_bubble_outline,
            AppColors.primary,
            () {
              Navigator.of(context).pushNamed('/chat');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            'Patient Search',
            'Find patient records',
            Icons.search,
            AppColors.doctorRole,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Patient search feature coming soon', style: GoogleFonts.inter()),
                  backgroundColor: AppColors.doctorRole,
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionCard(
            'Emergency Protocol',
            'Quick access to protocols',
            Icons.local_hospital,
            AppColors.accent,
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Emergency protocols accessed', style: GoogleFonts.inter()),
                  backgroundColor: AppColors.accent,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentChatsCard() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final recentSessions = chatProvider.chatSessions.take(5).toList();
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.chat_bubble_outline, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Chat Sessions',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/chat');
                    },
                    child: Text('View All', style: GoogleFonts.inter(color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (recentSessions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white.withValues(alpha: 0.8), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'No chat sessions yet. Start your first consultation!',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...recentSessions.map((session) => _buildChatSessionItem(session)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChatSessionItem(ChatSession session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.chat, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chat Session ${session.id.length > 8 ? session.id.substring(0, 8) : session.id}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${session.messages.length} messages • ${_formatTime(session.createdAt)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.6), size: 16),
        ],
      ),
    );
  }

  Widget _buildRecentQueriesCard() {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final recentQueries = chatProvider.chatSessions
            .expand((session) => session.messages)
            .where((message) => message.type == MessageType.user)
            .take(5)
            .toList();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.history, color: AppColors.doctorRole, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Recent Queries',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (recentQueries.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white.withValues(alpha: 0.8), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'No queries yet. Ask me anything about medical care!',
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...recentQueries.map((query) => _buildQueryItem(query)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQueryItem(ChatMessage query) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.doctorRole.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(Icons.question_answer, color: AppColors.doctorRole, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  query.content.length > 50 
                    ? '${query.content.substring(0, 50)}...'
                    : query.content,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _formatTime(query.timestamp),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPatientsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_outline, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Recent Patients',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Patient directory coming soon', style: GoogleFonts.inter()),
                      backgroundColor: AppColors.secondary,
                    ),
                  );
                },
                child: Text('View All', style: GoogleFonts.inter(color: AppColors.secondary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPatientItem('Ahmad Ibrahim', 'IC: 123456-78-9012', 'Hypertension follow-up', true),
          _buildPatientItem('Sarah Lee', 'IC: 234567-89-0123', 'Diabetes consultation', false),
          _buildPatientItem('Dr. Rahman Ali', 'IC: 345678-90-1234', 'Cardiology referral', false),
          _buildPatientItem('Fatimah Zahra', 'IC: 456789-01-2345', 'Routine checkup', false),
        ],
      ),
    );
  }

  Widget _buildPatientItem(String name, String ic, String condition, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? AppColors.secondary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: isActive ? Border.all(color: AppColors.secondary.withValues(alpha: 0.3)) : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isActive ? AppColors.secondary : Colors.white.withValues(alpha: 0.3),
            child: Text(
              name.substring(0, 1),
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  condition,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Active',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.6), size: 16),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Consumer2<DocumentProvider, ChatProvider>(
      builder: (context, docProvider, chatProvider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Documents',
                '${docProvider.documents.length}',
                Icons.folder_outlined,
                AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'AI Sessions',
                '${chatProvider.chatSessions.length}',
                Icons.chat_outlined,
                AppColors.success,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: AppColors.success, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _getRoleDisplayName(auth.UserRole? role) {
    switch (role) {
      case auth.UserRole.nurse:
        return 'Registered Nurse';
      case auth.UserRole.doctor:
        return 'Medical Doctor';
      case auth.UserRole.admin:
        return 'Administrator';
      default:
        return 'Healthcare Professional';
    }
  }

  // Theme helper methods
  Color _getCardBackgroundColor(bool isDarkMode) {
    return isDarkMode ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.9);
  }

  List<BoxShadow> _getBoxShadow(bool isDarkMode) {
    return [
      BoxShadow(
        color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.15),
        blurRadius: 15,
        offset: const Offset(0, 5),
      ),
    ];
  }
}