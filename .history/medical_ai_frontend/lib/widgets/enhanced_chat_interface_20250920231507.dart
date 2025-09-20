import 'package:flutter/material.dart';import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:provider/provider.dart';import 'package:provider/provider.dart';

import '../utils/app_theme.dart';import '../utils/app_theme.dart';

import '../providers/chat_provider.dart';import '../providers/chat_provider.dart';

import '../providers/auth_provider.dart' as auth;import '../providers/auth_provider.dart' as auth;

import 'common/app_components.dart';import 'common/app_components.dart';

import 'common/patient_context_panel.dart';import 'common/patient_context_panel.dart';



class EnhancedChatInterface extends StatefulWidget {class EnhancedChatInterface extends StatefulWidget {

  const EnhancedChatInterface({Key? key}) : super(key: key);  const EnhancedChatInterface({Key? key}) : super(key: key);



  @override  @override

  State<EnhancedChatInterface> createState() => _EnhancedChatInterfaceState();  State<EnhancedChatInterface> createState() => _EnhancedChatInterfaceState();

}}



class _EnhancedChatInterfaceState extends State<EnhancedChatInterface>class _EnhancedChatInterfaceState extends State<EnhancedChatInterface> {

    with TickerProviderStateMixin {  final TextEditingController _messageController = TextEditingController();

  final TextEditingController _messageController = TextEditingController();  final ScrollController _scrollController = ScrollController();

  final ScrollController _scrollController = ScrollController();  final FocusNode _messageFocusNode = FocusNode();

  final FocusNode _messageFocusNode = FocusNode();  bool _isTyping = false;

  bool _isTyping = false;  String _selectedPatientId = 'P12345';

  bool _showPatientContext = true; // Toggle state for patient panel

  String _selectedPatientId = 'P12345';  @override

  late AnimationController _panelAnimationController;  void dispose() {

  late Animation<double> _panelAnimation;    _messageController.dispose();

    _scrollController.dispose();

  @override    _messageFocusNode.dispose();

  void initState() {    super.dispose();

    super.initState();  }

    _panelAnimationController = AnimationController(

      duration: const Duration(milliseconds: 300),  void _sendMessage() {

      vsync: this,    if (_messageController.text.trim().isEmpty) return;

    );

    _panelAnimation = Tween<double>(    final authProvider = context.read<auth.AuthProvider>();

      begin: 0.0,    final chatProvider = context.read<ChatProvider>();

      end: 1.0,

    ).animate(CurvedAnimation(    chatProvider.sendMessage(

      parent: _panelAnimationController,      _messageController.text.trim(),

      curve: Curves.easeInOut,      authProvider.currentUser?.role ?? auth.UserRole.nurse,

    ));    );

    

    if (_showPatientContext) {    _messageController.clear();

      _panelAnimationController.forward();    setState(() => _isTyping = false);

    }

  }    // Scroll to bottom

    WidgetsBinding.instance.addPostFrameCallback((_) {

  @override      if (_scrollController.hasClients) {

  void dispose() {        _scrollController.animateTo(

    _messageController.dispose();          _scrollController.position.maxScrollExtent,

    _scrollController.dispose();          duration: const Duration(milliseconds: 300),

    _messageFocusNode.dispose();          curve: Curves.easeOut,

    _panelAnimationController.dispose();        );

    super.dispose();      }

  }    });

  }

  void _togglePatientContext() {

    setState(() {  @override

      _showPatientContext = !_showPatientContext;  Widget build(BuildContext context) {

    });    return Scaffold(

          backgroundColor: AppTheme.backgroundColor,

    if (_showPatientContext) {      body: Row(

      _panelAnimationController.forward();        children: [

    } else {          // Main chat area

      _panelAnimationController.reverse();          Expanded(

    }            child: Column(

  }              children: [

                _buildChatHeader(),

  void _sendMessage() {                Expanded(

    if (_messageController.text.trim().isEmpty) return;                  child: _buildMessageArea(),

                ),

    final authProvider = context.read<auth.AuthProvider>();                _buildInputArea(),

    final chatProvider = context.read<ChatProvider>();              ],

            ),

    chatProvider.sendMessage(          ),

      _messageController.text.trim(),          // Patient context panel

      authProvider.currentUser?.role ?? auth.UserRole.nurse,          PatientContextPanel(patientId: _selectedPatientId),

    );        ],

      ),

    _messageController.clear();    );

    setState(() => _isTyping = false);  }



    // Scroll to bottom  Widget _buildChatHeader() {

    WidgetsBinding.instance.addPostFrameCallback((_) {    return Container(

      if (_scrollController.hasClients) {      padding: const EdgeInsets.all(20),

        _scrollController.animateTo(      decoration: BoxDecoration(

          _scrollController.position.maxScrollExtent,        color: AppTheme.surfaceColor,

          duration: const Duration(milliseconds: 300),        border: Border(

          curve: Curves.easeOut,          bottom: BorderSide(color: AppTheme.dividerColor),

        );        ),

      }      ),

    });      child: Row(

  }        children: [

          Container(

  @override            padding: const EdgeInsets.all(12),

  Widget build(BuildContext context) {            decoration: AppTheme.primaryGradientDecoration,

    return Scaffold(            child: Icon(

      backgroundColor: AppTheme.backgroundColor,              MdiIcons.robot,

      body: Row(              color: Colors.white,

        children: [              size: 24,

          // Main chat area            ),

          Expanded(          ),

            child: Column(          const SizedBox(width: 16),

              children: [          Expanded(

                _buildChatHeader(),            child: Column(

                Expanded(              crossAxisAlignment: CrossAxisAlignment.start,

                  child: _buildMessageArea(),              children: [

                ),                Text(

                _buildInputArea(),                  'Medical AI Assistant',

              ],                  style: AppTheme.titleLarge.copyWith(

            ),                    fontWeight: FontWeight.w600,

          ),                  ),

          // Animated patient context panel                ),

          AnimatedBuilder(                Row(

            animation: _panelAnimation,                  children: [

            builder: (context, child) {                    Container(

              return Transform.translate(                      width: 8,

                offset: Offset(                      height: 8,

                  (1 - _panelAnimation.value) * 380, // Panel width                      decoration: BoxDecoration(

                  0,                        color: AppTheme.successColor,

                ),                        shape: BoxShape.circle,

                child: Container(                      ),

                  width: 380,                    ),

                  height: double.infinity,                    const SizedBox(width: 6),

                  child: _showPatientContext                    Text(

                      ? PatientContextPanel(patientId: _selectedPatientId)                      'Online • Ready to help',

                      : Container(),                      style: AppTheme.bodySmall.copyWith(

                ),                        color: AppTheme.textSecondary,

              );                      ),

            },                    ),

          ),                  ],

        ],                ),

      ),              ],

    );            ),

  }          ),

          _buildHeaderActions(),

  Widget _buildChatHeader() {        ],

    return Container(      ),

      padding: const EdgeInsets.all(20),    );

      decoration: BoxDecoration(  }

        color: AppTheme.surfaceColor,

        border: Border(  Widget _buildHeaderActions() {

          bottom: BorderSide(color: AppTheme.dividerColor),    return Row(

        ),      children: [

      ),        IconButton(

      child: Row(          onPressed: () {},

        children: [          icon: Icon(MdiIcons.history, color: AppTheme.textSecondary),

          Container(          tooltip: 'Chat History',

            padding: const EdgeInsets.all(12),        ),

            decoration: BoxDecoration(        IconButton(

              gradient: LinearGradient(          onPressed: () {},

                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],          icon: Icon(MdiIcons.bookmark, color: AppTheme.textSecondary),

                begin: Alignment.topLeft,          tooltip: 'Saved Conversations',

                end: Alignment.bottomRight,        ),

              ),        IconButton(

              borderRadius: BorderRadius.circular(12),          onPressed: () {},

            ),          icon: Icon(MdiIcons.contentSave, color: AppTheme.textSecondary),

            child: Icon(          tooltip: 'Export Chat',

              MdiIcons.robot,        ),

              color: Colors.white,        const SizedBox(width: 8),

              size: 24,        AppButton(

            ),          text: 'Clear Chat',

          ),          type: ButtonType.secondary,

          const SizedBox(width: 16),          size: ButtonSize.small,

          Expanded(          icon: MdiIcons.deleteEmpty,

            child: Column(          onPressed: () {

              crossAxisAlignment: CrossAxisAlignment.start,            final authProvider = context.read<auth.AuthProvider>();

              children: [            context.read<ChatProvider>().startNewSession(

                Text(              authProvider.currentUser?.role ?? auth.UserRole.nurse,

                  'Medical AI Assistant',              null,

                  style: AppTheme.titleLarge.copyWith(            );

                    fontWeight: FontWeight.w600,          },

                  ),        ),

                ),      ],

                Row(    );

                  children: [  }

                    Container(

                      width: 8,  Widget _buildMessageArea() {

                      height: 8,    return Container(

                      decoration: BoxDecoration(      color: AppTheme.backgroundColor,

                        color: AppTheme.successColor,      child: Consumer<ChatProvider>(

                        shape: BoxShape.circle,        builder: (context, chatProvider, child) {

                      ),          if (chatProvider.currentMessages.isEmpty) {

                    ),            return _buildWelcomeState();

                    const SizedBox(width: 6),          }

                    Text(

                      'Online • Ready to help with Emily Chen',          return ListView.builder(

                      style: AppTheme.bodySmall.copyWith(            controller: _scrollController,

                        color: AppTheme.textSecondary,            padding: const EdgeInsets.all(20),

                      ),            itemCount: chatProvider.currentMessages.length + (_isTyping ? 1 : 0),

                    ),            itemBuilder: (context, index) {

                  ],              if (index == chatProvider.currentMessages.length && _isTyping) {

                ),                return _buildTypingIndicator();

              ],              }

            ),

          ),              final message = chatProvider.currentMessages[index];

          _buildHeaderActions(),              final isUser = message.type == MessageType.user;

        ],              final isFirst = index == 0 ||

      ),                  chatProvider.currentMessages[index - 1].type != message.type;

    );              final isLast = index == chatProvider.currentMessages.length - 1 ||

  }                  (index < chatProvider.currentMessages.length - 1 &&

                      chatProvider.currentMessages[index + 1].type != message.type);

  Widget _buildHeaderActions() {

    return Row(              return _buildMessageBubble(message, isUser, isFirst, isLast);

      children: [            },

        IconButton(          );

          onPressed: () {},        },

          icon: Icon(MdiIcons.history, color: AppTheme.textSecondary),      ),

          tooltip: 'Chat History',    );

        ),  }

        IconButton(

          onPressed: () {},  Widget _buildWelcomeState() {

          icon: Icon(MdiIcons.bookmark, color: AppTheme.textSecondary),    return Center(

          tooltip: 'Saved Conversations',      child: Column(

        ),        mainAxisAlignment: MainAxisAlignment.center,

        IconButton(        children: [

          onPressed: _togglePatientContext,          Container(

          icon: Icon(            width: 120,

            _showPatientContext ? MdiIcons.accountOff : MdiIcons.account,            height: 120,

            color: _showPatientContext ? AppTheme.primaryColor : AppTheme.textSecondary,            decoration: AppTheme.primaryGradientDecoration,

          ),            child: Icon(

          tooltip: _showPatientContext ? 'Hide Patient Context' : 'Show Patient Context',              MdiIcons.stethoscope,

        ),              color: Colors.white,

        const SizedBox(width: 8),              size: 48,

        AppButton(            ),

          text: 'Clear Chat',          ),

          type: ButtonType.secondary,          const SizedBox(height: 24),

          size: ButtonSize.small,          Text(

          icon: MdiIcons.deleteEmpty,            'Welcome to Medical AI Assistant',

          onPressed: () {            style: AppTheme.headingLarge.copyWith(

            final authProvider = context.read<auth.AuthProvider>();              color: AppTheme.textPrimary,

            context.read<ChatProvider>().startNewSession(            ),

              authProvider.currentUser?.role ?? auth.UserRole.nurse,          ),

              null,          const SizedBox(height: 12),

            );          Text(

          },            'I can help you with patient information, medical queries,\nand document analysis. How can I assist you today?',

        ),            style: AppTheme.bodyMedium.copyWith(

      ],              color: AppTheme.textSecondary,

    );            ),

  }            textAlign: TextAlign.center,

          ),

  Widget _buildMessageArea() {          const SizedBox(height: 32),

    return Container(          Wrap(

      color: AppTheme.backgroundColor,            spacing: 12,

      child: Consumer<ChatProvider>(            runSpacing: 12,

        builder: (context, chatProvider, child) {            children: [

          if (chatProvider.currentMessages.isEmpty) {              _buildSuggestionChip('Analyze patient symptoms'),

            return _buildWelcomeState();              _buildSuggestionChip('Review lab results'),

          }              _buildSuggestionChip('Check medication interactions'),

              _buildSuggestionChip('Patient care recommendations'),

          return ListView.builder(            ],

            controller: _scrollController,          ),

            padding: const EdgeInsets.all(20),        ],

            itemCount: chatProvider.currentMessages.length + (_isTyping ? 1 : 0),      ),

            itemBuilder: (context, index) {    );

              if (index == chatProvider.currentMessages.length && _isTyping) {  }

                return _buildTypingIndicator();

              }  Widget _buildSuggestionChip(String text) {

    return GestureDetector(

              final message = chatProvider.currentMessages[index];      onTap: () {

              final isUser = message.type == MessageType.user;        _messageController.text = text;

              final isFirst = index == 0 ||        _sendMessage();

                  chatProvider.currentMessages[index - 1].type != message.type;      },

              final isLast = index == chatProvider.currentMessages.length - 1 ||      child: Container(

                  chatProvider.currentMessages[index + 1].type != message.type;        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

        decoration: BoxDecoration(

              return _buildMessageBubble(message, isUser, isFirst, isLast);          color: AppTheme.surfaceColor,

            },          borderRadius: BorderRadius.circular(20),

          );          border: Border.all(color: AppTheme.dividerColor),

        },        ),

      ),        child: Row(

    );          mainAxisSize: MainAxisSize.min,

  }          children: [

            Icon(

  Widget _buildWelcomeState() {              MdiIcons.lightbulbOutline,

    return Center(              size: 16,

      child: Container(              color: AppTheme.primaryColor,

        constraints: const BoxConstraints(maxWidth: 600),            ),

        padding: const EdgeInsets.all(32),            const SizedBox(width: 6),

        child: Column(            Text(

          mainAxisAlignment: MainAxisAlignment.center,              text,

          children: [              style: AppTheme.bodySmall.copyWith(

            Container(                color: AppTheme.textPrimary,

              padding: const EdgeInsets.all(24),              ),

              decoration: BoxDecoration(            ),

                gradient: LinearGradient(          ],

                  colors: [        ),

                    AppTheme.primaryColor.withOpacity(0.1),      ),

                    AppTheme.secondaryColor.withOpacity(0.1),    );

                  ],  }

                ),

                shape: BoxShape.circle,  Widget _buildMessageBubble(ChatMessage message, bool isUser, bool isFirst, bool isLast) {

              ),    return Container(

              child: Icon(      margin: EdgeInsets.only(

                MdiIcons.robot,        bottom: isLast ? 16 : 4,

                size: 64,        top: isFirst ? 8 : 0,

                color: AppTheme.primaryColor,      ),

              ),      child: Row(

            ),        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,

            const SizedBox(height: 24),        crossAxisAlignment: CrossAxisAlignment.end,

            Text(        children: [

              'Welcome to Medical AI Assistant',          if (!isUser && isLast) _buildAvatar(false),

              style: AppTheme.headingMedium.copyWith(          if (!isUser && !isLast) const SizedBox(width: 40),

                fontWeight: FontWeight.w700,          const SizedBox(width: 8),

              ),          Flexible(

              textAlign: TextAlign.center,            child: Container(

            ),              constraints: BoxConstraints(

            const SizedBox(height: 12),                maxWidth: MediaQuery.of(context).size.width * 0.7,

            Text(              ),

              'I\'m here to help you with patient Emily Chen. Ask me anything about her medical history, current condition, or treatment recommendations.',              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

              style: AppTheme.bodyLarge.copyWith(              decoration: BoxDecoration(

                color: AppTheme.textSecondary,                color: isUser ? AppTheme.primaryColor : AppTheme.surfaceColor,

              ),                borderRadius: BorderRadius.only(

              textAlign: TextAlign.center,                  topLeft: const Radius.circular(16),

            ),                  topRight: const Radius.circular(16),

            const SizedBox(height: 32),                  bottomLeft: Radius.circular(isUser ? 16 : (isLast ? 4 : 16)),

            _buildSuggestionChips(),                  bottomRight: Radius.circular(isUser ? (isLast ? 4 : 16) : 16),

          ],                ),

        ),                boxShadow: AppTheme.cardShadow,

      ),              ),

    );              child: Column(

  }                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

  Widget _buildSuggestionChips() {                  if (!isUser && isFirst)

    final suggestions = [                    Padding(

      'Review Emily\'s vital signs',                      padding: const EdgeInsets.only(bottom: 4),

      'Check medication interactions',                      child: Text(

      'Analyze recent lab results',                        'Medical AI',

      'Suggest treatment plan',                        style: AppTheme.labelSmall.copyWith(

    ];                          color: AppTheme.primaryColor,

                          fontWeight: FontWeight.w600,

    return Wrap(                        ),

      spacing: 12,                      ),

      runSpacing: 12,                    ),

      alignment: WrapAlignment.center,                  Text(

      children: suggestions.map((suggestion) {                    message.content,

        return ActionChip(                    style: AppTheme.bodyMedium.copyWith(

          label: Text(suggestion),                      color: isUser ? Colors.white : AppTheme.textPrimary,

          onPressed: () {                    ),

            _messageController.text = suggestion;                  ),

            _sendMessage();                  const SizedBox(height: 4),

          },                  Row(

          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),                    mainAxisSize: MainAxisSize.min,

          labelStyle: AppTheme.bodySmall.copyWith(                    children: [

            color: AppTheme.primaryColor,                      Text(

            fontWeight: FontWeight.w500,                        _formatTime(message.timestamp),

          ),                        style: AppTheme.labelSmall.copyWith(

          side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),                          color: isUser

        );                              ? Colors.white.withOpacity(0.7)

      }).toList(),                              : AppTheme.textTertiary,

    );                        ),

  }                      ),

                      if (isUser) ...[

  Widget _buildMessageBubble(ChatMessage message, bool isUser, bool isFirst, bool isLast) {                        const SizedBox(width: 4),

    return Container(                        Icon(

      margin: EdgeInsets.only(                          MdiIcons.check,

        bottom: isLast ? 16 : 4,                          size: 12,

        top: isFirst ? 16 : 0,                          color: Colors.white.withOpacity(0.7),

      ),                        ),

      child: Row(                      ],

        crossAxisAlignment: CrossAxisAlignment.start,                    ],

        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,                  ),

        children: [                ],

          if (!isUser && isFirst) _buildAvatar(isUser),              ),

          if (!isUser && !isFirst) const SizedBox(width: 40),            ),

          if (!isUser) const SizedBox(width: 8),          ),

          Flexible(          const SizedBox(width: 8),

            child: Container(          if (isUser && isLast) _buildAvatar(true),

              constraints: BoxConstraints(          if (isUser && !isLast) const SizedBox(width: 40),

                maxWidth: MediaQuery.of(context).size.width * 0.7,        ],

              ),      ),

              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),    );

              decoration: BoxDecoration(  }

                color: isUser ? AppTheme.primaryColor : AppTheme.surfaceColor,

                borderRadius: BorderRadius.only(  Widget _buildAvatar(bool isUser) {

                  topLeft: Radius.circular(isUser || !isFirst ? 16 : 4),    return Container(

                  topRight: Radius.circular(!isUser || !isFirst ? 16 : 4),      width: 32,

                  bottomLeft: Radius.circular(isUser || !isLast ? 16 : 4),      height: 32,

                  bottomRight: Radius.circular(!isUser || !isLast ? 16 : 4),      decoration: BoxDecoration(

                ),        color: isUser ? AppTheme.primaryColor : AppTheme.infoColor,

                boxShadow: [        shape: BoxShape.circle,

                  BoxShadow(      ),

                    color: Colors.black.withOpacity(0.1),      child: Icon(

                    blurRadius: 4,        isUser ? MdiIcons.account : MdiIcons.robot,

                    offset: const Offset(0, 2),        color: Colors.white,

                  ),        size: 18,

                ],      ),

              ),    );

              child: Column(  }

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [  Widget _buildTypingIndicator() {

                  Text(    return Container(

                    message.content,      margin: const EdgeInsets.only(bottom: 16),

                    style: AppTheme.bodyMedium.copyWith(      child: Row(

                      color: isUser ? Colors.white : AppTheme.textPrimary,        children: [

                    ),          _buildAvatar(false),

                  ),          const SizedBox(width: 8),

                  if (isLast) ...[          Container(

                    const SizedBox(height: 4),            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

                    Text(            decoration: BoxDecoration(

                      _formatTime(message.timestamp),              color: AppTheme.surfaceColor,

                      style: AppTheme.labelSmall.copyWith(              borderRadius: BorderRadius.circular(16),

                        color: isUser              boxShadow: AppTheme.cardShadow,

                            ? Colors.white.withOpacity(0.7)            ),

                            : AppTheme.textTertiary,            child: Row(

                      ),              mainAxisSize: MainAxisSize.min,

                    ),              children: [

                  ],                Text(

                ],                  'AI is typing',

              ),                  style: AppTheme.bodySmall.copyWith(

            ),                    color: AppTheme.textSecondary,

          ),                    fontStyle: FontStyle.italic,

          if (isUser) const SizedBox(width: 8),                  ),

          if (isUser && isFirst) _buildAvatar(isUser),                ),

          if (isUser && !isFirst) const SizedBox(width: 40),                const SizedBox(width: 8),

        ],                SizedBox(

      ),                  width: 20,

    );                  height: 20,

  }                  child: CircularProgressIndicator(

                    strokeWidth: 2,

  Widget _buildAvatar(bool isUser) {                    valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),

    return Container(                  ),

      width: 32,                ),

      height: 32,              ],

      decoration: BoxDecoration(            ),

        color: isUser ? AppTheme.primaryColor : AppTheme.secondaryColor,          ),

        shape: BoxShape.circle,        ],

      ),      ),

      child: Icon(    );

        isUser ? MdiIcons.account : MdiIcons.robot,  }

        color: Colors.white,

        size: 18,  Widget _buildInputArea() {

      ),    return Container(

    );      padding: const EdgeInsets.all(20),

  }      decoration: BoxDecoration(

        color: AppTheme.surfaceColor,

  Widget _buildTypingIndicator() {        border: Border(

    return Container(          top: BorderSide(color: AppTheme.dividerColor),

      margin: const EdgeInsets.symmetric(vertical: 8),        ),

      child: Row(        boxShadow: [

        children: [          BoxShadow(

          _buildAvatar(false),            color: Colors.black.withOpacity(0.05),

          const SizedBox(width: 8),            blurRadius: 10,

          Container(            offset: const Offset(0, -2),

            padding: const EdgeInsets.all(16),          ),

            decoration: BoxDecoration(        ],

              color: AppTheme.surfaceColor,      ),

              borderRadius: BorderRadius.circular(16),      child: Column(

            ),        children: [

            child: Row(          Row(

              mainAxisSize: MainAxisSize.min,            children: [

              children: [              Expanded(

                _buildTypingDot(0),                child: Container(

                const SizedBox(width: 4),                  decoration: BoxDecoration(

                _buildTypingDot(1),                    color: AppTheme.backgroundColor,

                const SizedBox(width: 4),                    borderRadius: BorderRadius.circular(24),

                _buildTypingDot(2),                    border: Border.all(color: AppTheme.dividerColor),

              ],                  ),

            ),                  child: Row(

          ),                    children: [

        ],                      IconButton(

      ),                        onPressed: () {},

    );                        icon: Icon(MdiIcons.attachment, color: AppTheme.textTertiary),

  }                        tooltip: 'Attach file',

                      ),

  Widget _buildTypingDot(int index) {                      Expanded(

    return AnimatedContainer(                        child: TextField(

      duration: Duration(milliseconds: 600 + (index * 200)),                          controller: _messageController,

      width: 8,                          focusNode: _messageFocusNode,

      height: 8,                          onChanged: (text) {

      decoration: BoxDecoration(                            setState(() {

        color: AppTheme.textTertiary,                              _isTyping = text.isNotEmpty;

        shape: BoxShape.circle,                            });

      ),                          },

    );                          onSubmitted: (_) => _sendMessage(),

  }                          maxLines: null,

                          decoration: InputDecoration(

  Widget _buildInputArea() {                            hintText: 'Ask about patient care, symptoms, or medical queries...',

    return Container(                            hintStyle: AppTheme.bodyMedium.copyWith(

      padding: const EdgeInsets.all(20),                              color: AppTheme.textTertiary,

      decoration: BoxDecoration(                            ),

        color: AppTheme.surfaceColor,                            border: InputBorder.none,

        border: Border(                            contentPadding: const EdgeInsets.symmetric(

          top: BorderSide(color: AppTheme.dividerColor),                              horizontal: 16,

        ),                              vertical: 12,

      ),                            ),

      child: Row(                          ),

        children: [                          style: AppTheme.bodyMedium,

          IconButton(                        ),

            onPressed: () {},                      ),

            icon: Icon(MdiIcons.attachment, color: AppTheme.textSecondary),                      IconButton(

            tooltip: 'Attach file',                        onPressed: () {},

          ),                        icon: Icon(MdiIcons.microphone, color: AppTheme.textTertiary),

          const SizedBox(width: 8),                        tooltip: 'Voice input',

          Expanded(                      ),

            child: TextField(                    ],

              controller: _messageController,                  ),

              focusNode: _messageFocusNode,                ),

              decoration: InputDecoration(              ),

                hintText: 'Ask about Emily Chen\'s condition...',              const SizedBox(width: 12),

                hintStyle: AppTheme.bodyMedium.copyWith(              Container(

                  color: AppTheme.textTertiary,                decoration: BoxDecoration(

                ),                  color: _messageController.text.trim().isNotEmpty

                filled: true,                      ? AppTheme.primaryColor

                fillColor: AppTheme.backgroundColor,                      : AppTheme.textTertiary,

                border: OutlineInputBorder(                  shape: BoxShape.circle,

                  borderRadius: BorderRadius.circular(24),                ),

                  borderSide: BorderSide.none,                child: IconButton(

                ),                  onPressed: _messageController.text.trim().isNotEmpty

                contentPadding: const EdgeInsets.symmetric(                      ? _sendMessage

                  horizontal: 20,                      : null,

                  vertical: 12,                  icon: Icon(

                ),                    MdiIcons.send,

              ),                    color: Colors.white,

              maxLines: null,                    size: 20,

              textInputAction: TextInputAction.send,                  ),

              onSubmitted: (_) => _sendMessage(),                  tooltip: 'Send message',

              onChanged: (text) {                ),

                setState(() {              ),

                  _isTyping = text.isNotEmpty;            ],

                });          ),

              },          const SizedBox(height: 8),

            ),          Row(

          ),            children: [

          const SizedBox(width: 8),              Icon(MdiIcons.information, size: 12, color: AppTheme.textTertiary),

          IconButton(              const SizedBox(width: 4),

            onPressed: () {},              Text(

            icon: Icon(MdiIcons.microphone, color: AppTheme.textSecondary),                'AI responses are for informational purposes only. Always consult medical professionals.',

            tooltip: 'Voice input',                style: AppTheme.labelSmall.copyWith(

          ),                  color: AppTheme.textTertiary,

          const SizedBox(width: 8),                ),

          Container(              ),

            decoration: BoxDecoration(            ],

              gradient: LinearGradient(          ),

                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],        ],

              ),      ),

              borderRadius: BorderRadius.circular(24),    );

            ),  }

            child: IconButton(

              onPressed: _sendMessage,  String _formatTime(DateTime timestamp) {

              icon: Icon(MdiIcons.send, color: Colors.white),    final now = DateTime.now();

              tooltip: 'Send message',    final diff = now.difference(timestamp);

            ),

          ),    if (diff.inMinutes < 1) {

        ],      return 'Just now';

      ),    } else if (diff.inHours < 1) {

    );      return '${diff.inMinutes}m ago';

  }    } else if (diff.inDays < 1) {

      return '${diff.inHours}h ago';

  String _formatTime(DateTime dateTime) {    } else {

    final now = DateTime.now();      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

    final difference = now.difference(dateTime);    }

  }

    if (difference.inDays > 0) {}
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}