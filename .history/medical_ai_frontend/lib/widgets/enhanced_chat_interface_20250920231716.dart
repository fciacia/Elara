import 'package:flutter/material.dart';import 'package:flutter/material.dart';import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:provider/provider.dart';import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../utils/app_theme.dart';

import '../providers/chat_provider.dart';import 'package:provider/provider.dart';import 'package:provider/provider.dart';

import '../providers/auth_provider.dart' as auth;

import 'common/app_components.dart';import '../utils/app_theme.dart';import '../utils/app_theme.dart';

import 'common/patient_context_panel.dart';

import '../providers/chat_provider.dart';import '../providers/chat_provider.dart';

class EnhancedChatInterface extends StatefulWidget {

  const EnhancedChatInterface({Key? key}) : super(key: key);import '../providers/auth_provider.dart' as auth;import '../providers/auth_provider.dart' as auth;



  @overrideimport 'common/app_components.dart';import 'common/app_components.dart';

  State<EnhancedChatInterface> createState() => _EnhancedChatInterfaceState();

}import 'common/patient_context_panel.dart';import 'common/patient_context_panel.dart';



class _EnhancedChatInterfaceState extends State<EnhancedChatInterface>

    with TickerProviderStateMixin {

  final TextEditingController _messageController = TextEditingController();class EnhancedChatInterface extends StatefulWidget {class EnhancedChatInterface extends StatefulWidget {

  final ScrollController _scrollController = ScrollController();

  final FocusNode _messageFocusNode = FocusNode();  const EnhancedChatInterface({Key? key}) : super(key: key);  const EnhancedChatInterface({Key? key}) : super(key: key);

  bool _isTyping = false;

  bool _showPatientContext = true; // Toggle state for patient panel

  String _selectedPatientId = 'P12345';

  late AnimationController _panelAnimationController;  @override  @override

  late Animation<double> _panelAnimation;

  State<EnhancedChatInterface> createState() => _EnhancedChatInterfaceState();  State<EnhancedChatInterface> createState() => _EnhancedChatInterfaceState();

  @override

  void initState() {}}

    super.initState();

    _panelAnimationController = AnimationController(

      duration: const Duration(milliseconds: 300),

      vsync: this,class _EnhancedChatInterfaceState extends State<EnhancedChatInterface>class _EnhancedChatInterfaceState extends State<EnhancedChatInterface> {

    );

    _panelAnimation = Tween<double>(    with TickerProviderStateMixin {  final TextEditingController _messageController = TextEditingController();

      begin: 0.0,

      end: 1.0,  final TextEditingController _messageController = TextEditingController();  final ScrollController _scrollController = ScrollController();

    ).animate(CurvedAnimation(

      parent: _panelAnimationController,  final ScrollController _scrollController = ScrollController();  final FocusNode _messageFocusNode = FocusNode();

      curve: Curves.easeInOut,

    ));  final FocusNode _messageFocusNode = FocusNode();  bool _isTyping = false;

    

    if (_showPatientContext) {  bool _isTyping = false;  String _selectedPatientId = 'P12345';

      _panelAnimationController.forward();

    }  bool _showPatientContext = true; // Toggle state for patient panel

  }

  String _selectedPatientId = 'P12345';  @override

  @override

  void dispose() {  late AnimationController _panelAnimationController;  void dispose() {

    _messageController.dispose();

    _scrollController.dispose();  late Animation<double> _panelAnimation;    _messageController.dispose();

    _messageFocusNode.dispose();

    _panelAnimationController.dispose();    _scrollController.dispose();

    super.dispose();

  }  @override    _messageFocusNode.dispose();



  void _togglePatientContext() {  void initState() {    super.dispose();

    setState(() {

      _showPatientContext = !_showPatientContext;    super.initState();  }

    });

        _panelAnimationController = AnimationController(

    if (_showPatientContext) {

      _panelAnimationController.forward();      duration: const Duration(milliseconds: 300),  void _sendMessage() {

    } else {

      _panelAnimationController.reverse();      vsync: this,    if (_messageController.text.trim().isEmpty) return;

    }

  }    );



  void _sendMessage() {    _panelAnimation = Tween<double>(    final authProvider = context.read<auth.AuthProvider>();

    if (_messageController.text.trim().isEmpty) return;

      begin: 0.0,    final chatProvider = context.read<ChatProvider>();

    final authProvider = context.read<auth.AuthProvider>();

    final chatProvider = context.read<ChatProvider>();      end: 1.0,



    chatProvider.sendMessage(    ).animate(CurvedAnimation(    chatProvider.sendMessage(

      _messageController.text.trim(),

      authProvider.currentUser?.role ?? auth.UserRole.nurse,      parent: _panelAnimationController,      _messageController.text.trim(),

    );

      curve: Curves.easeInOut,      authProvider.currentUser?.role ?? auth.UserRole.nurse,

    _messageController.clear();

    setState(() => _isTyping = false);    ));    );



    // Scroll to bottom    

    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (_scrollController.hasClients) {    if (_showPatientContext) {    _messageController.clear();

        _scrollController.animateTo(

          _scrollController.position.maxScrollExtent,      _panelAnimationController.forward();    setState(() => _isTyping = false);

          duration: const Duration(milliseconds: 300),

          curve: Curves.easeOut,    }

        );

      }  }    // Scroll to bottom

    });

  }    WidgetsBinding.instance.addPostFrameCallback((_) {



  @override  @override      if (_scrollController.hasClients) {

  Widget build(BuildContext context) {

    return Scaffold(  void dispose() {        _scrollController.animateTo(

      backgroundColor: AppTheme.backgroundColor,

      body: Row(    _messageController.dispose();          _scrollController.position.maxScrollExtent,

        children: [

          // Main chat area    _scrollController.dispose();          duration: const Duration(milliseconds: 300),

          Expanded(

            child: Column(    _messageFocusNode.dispose();          curve: Curves.easeOut,

              children: [

                _buildChatHeader(),    _panelAnimationController.dispose();        );

                Expanded(

                  child: _buildMessageArea(),    super.dispose();      }

                ),

                _buildInputArea(),  }    });

              ],

            ),  }

          ),

          // Animated patient context panel  void _togglePatientContext() {

          AnimatedBuilder(

            animation: _panelAnimation,    setState(() {  @override

            builder: (context, child) {

              return Transform.translate(      _showPatientContext = !_showPatientContext;  Widget build(BuildContext context) {

                offset: Offset(

                  (1 - _panelAnimation.value) * 380, // Panel width    });    return Scaffold(

                  0,

                ),          backgroundColor: AppTheme.backgroundColor,

                child: Container(

                  width: 380,    if (_showPatientContext) {      body: Row(

                  height: double.infinity,

                  child: _showPatientContext      _panelAnimationController.forward();        children: [

                      ? PatientContextPanel(patientId: _selectedPatientId)

                      : Container(),    } else {          // Main chat area

                ),

              );      _panelAnimationController.reverse();          Expanded(

            },

          ),    }            child: Column(

        ],

      ),  }              children: [

    );

  }                _buildChatHeader(),



  Widget _buildChatHeader() {  void _sendMessage() {                Expanded(

    return Container(

      padding: const EdgeInsets.all(20),    if (_messageController.text.trim().isEmpty) return;                  child: _buildMessageArea(),

      decoration: BoxDecoration(

        color: AppTheme.surfaceColor,                ),

        border: Border(

          bottom: BorderSide(color: AppTheme.dividerColor),    final authProvider = context.read<auth.AuthProvider>();                _buildInputArea(),

        ),

      ),    final chatProvider = context.read<ChatProvider>();              ],

      child: Row(

        children: [            ),

          Container(

            padding: const EdgeInsets.all(12),    chatProvider.sendMessage(          ),

            decoration: BoxDecoration(

              gradient: LinearGradient(      _messageController.text.trim(),          // Patient context panel

                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],

                begin: Alignment.topLeft,      authProvider.currentUser?.role ?? auth.UserRole.nurse,          PatientContextPanel(patientId: _selectedPatientId),

                end: Alignment.bottomRight,

              ),    );        ],

              borderRadius: BorderRadius.circular(12),

            ),      ),

            child: Icon(

              MdiIcons.robot,    _messageController.clear();    );

              color: Colors.white,

              size: 24,    setState(() => _isTyping = false);  }

            ),

          ),

          const SizedBox(width: 16),

          Expanded(    // Scroll to bottom  Widget _buildChatHeader() {

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,    WidgetsBinding.instance.addPostFrameCallback((_) {    return Container(

              children: [

                Text(      if (_scrollController.hasClients) {      padding: const EdgeInsets.all(20),

                  'Medical AI Assistant',

                  style: AppTheme.titleLarge.copyWith(        _scrollController.animateTo(      decoration: BoxDecoration(

                    fontWeight: FontWeight.w600,

                  ),          _scrollController.position.maxScrollExtent,        color: AppTheme.surfaceColor,

                ),

                Row(          duration: const Duration(milliseconds: 300),        border: Border(

                  children: [

                    Container(          curve: Curves.easeOut,          bottom: BorderSide(color: AppTheme.dividerColor),

                      width: 8,

                      height: 8,        );        ),

                      decoration: BoxDecoration(

                        color: AppTheme.successColor,      }      ),

                        shape: BoxShape.circle,

                      ),    });      child: Row(

                    ),

                    const SizedBox(width: 6),  }        children: [

                    Text(

                      'Online • Ready to help with Emily Chen',          Container(

                      style: AppTheme.bodySmall.copyWith(

                        color: AppTheme.textSecondary,  @override            padding: const EdgeInsets.all(12),

                      ),

                    ),  Widget build(BuildContext context) {            decoration: AppTheme.primaryGradientDecoration,

                  ],

                ),    return Scaffold(            child: Icon(

              ],

            ),      backgroundColor: AppTheme.backgroundColor,              MdiIcons.robot,

          ),

          _buildHeaderActions(),      body: Row(              color: Colors.white,

        ],

      ),        children: [              size: 24,

    );

  }          // Main chat area            ),



  Widget _buildHeaderActions() {          Expanded(          ),

    return Row(

      children: [            child: Column(          const SizedBox(width: 16),

        IconButton(

          onPressed: () {},              children: [          Expanded(

          icon: Icon(MdiIcons.history, color: AppTheme.textSecondary),

          tooltip: 'Chat History',                _buildChatHeader(),            child: Column(

        ),

        IconButton(                Expanded(              crossAxisAlignment: CrossAxisAlignment.start,

          onPressed: () {},

          icon: Icon(MdiIcons.bookmark, color: AppTheme.textSecondary),                  child: _buildMessageArea(),              children: [

          tooltip: 'Saved Conversations',

        ),                ),                Text(

        IconButton(

          onPressed: _togglePatientContext,                _buildInputArea(),                  'Medical AI Assistant',

          icon: Icon(

            _showPatientContext ? MdiIcons.accountOff : MdiIcons.account,              ],                  style: AppTheme.titleLarge.copyWith(

            color: _showPatientContext ? AppTheme.primaryColor : AppTheme.textSecondary,

          ),            ),                    fontWeight: FontWeight.w600,

          tooltip: _showPatientContext ? 'Hide Patient Context' : 'Show Patient Context',

        ),          ),                  ),

        const SizedBox(width: 8),

        AppButton(          // Animated patient context panel                ),

          text: 'Clear Chat',

          type: ButtonType.secondary,          AnimatedBuilder(                Row(

          size: ButtonSize.small,

          icon: MdiIcons.deleteEmpty,            animation: _panelAnimation,                  children: [

          onPressed: () {

            final authProvider = context.read<auth.AuthProvider>();            builder: (context, child) {                    Container(

            context.read<ChatProvider>().startNewSession(

              authProvider.currentUser?.role ?? auth.UserRole.nurse,              return Transform.translate(                      width: 8,

              null,

            );                offset: Offset(                      height: 8,

          },

        ),                  (1 - _panelAnimation.value) * 380, // Panel width                      decoration: BoxDecoration(

      ],

    );                  0,                        color: AppTheme.successColor,

  }

                ),                        shape: BoxShape.circle,

  Widget _buildMessageArea() {

    return Container(                child: Container(                      ),

      color: AppTheme.backgroundColor,

      child: Consumer<ChatProvider>(                  width: 380,                    ),

        builder: (context, chatProvider, child) {

          if (chatProvider.currentMessages.isEmpty) {                  height: double.infinity,                    const SizedBox(width: 6),

            return _buildWelcomeState();

          }                  child: _showPatientContext                    Text(



          return ListView.builder(                      ? PatientContextPanel(patientId: _selectedPatientId)                      'Online • Ready to help',

            controller: _scrollController,

            padding: const EdgeInsets.all(20),                      : Container(),                      style: AppTheme.bodySmall.copyWith(

            itemCount: chatProvider.currentMessages.length + (_isTyping ? 1 : 0),

            itemBuilder: (context, index) {                ),                        color: AppTheme.textSecondary,

              if (index == chatProvider.currentMessages.length && _isTyping) {

                return _buildTypingIndicator();              );                      ),

              }

            },                    ),

              final message = chatProvider.currentMessages[index];

              final isUser = message.type == MessageType.user;          ),                  ],

              final isFirst = index == 0 ||

                  chatProvider.currentMessages[index - 1].type != message.type;        ],                ),

              final isLast = index == chatProvider.currentMessages.length - 1 ||

                  chatProvider.currentMessages[index + 1].type != message.type;      ),              ],



              return _buildMessageBubble(message, isUser, isFirst, isLast);    );            ),

            },

          );  }          ),

        },

      ),          _buildHeaderActions(),

    );

  }  Widget _buildChatHeader() {        ],



  Widget _buildWelcomeState() {    return Container(      ),

    return Center(

      child: Container(      padding: const EdgeInsets.all(20),    );

        constraints: const BoxConstraints(maxWidth: 600),

        padding: const EdgeInsets.all(32),      decoration: BoxDecoration(  }

        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,        color: AppTheme.surfaceColor,

          children: [

            Container(        border: Border(  Widget _buildHeaderActions() {

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(          bottom: BorderSide(color: AppTheme.dividerColor),    return Row(

                gradient: LinearGradient(

                  colors: [        ),      children: [

                    AppTheme.primaryColor.withOpacity(0.1),

                    AppTheme.secondaryColor.withOpacity(0.1),      ),        IconButton(

                  ],

                ),      child: Row(          onPressed: () {},

                shape: BoxShape.circle,

              ),        children: [          icon: Icon(MdiIcons.history, color: AppTheme.textSecondary),

              child: Icon(

                MdiIcons.robot,          Container(          tooltip: 'Chat History',

                size: 64,

                color: AppTheme.primaryColor,            padding: const EdgeInsets.all(12),        ),

              ),

            ),            decoration: BoxDecoration(        IconButton(

            const SizedBox(height: 24),

            Text(              gradient: LinearGradient(          onPressed: () {},

              'Welcome to Medical AI Assistant',

              style: AppTheme.headingMedium.copyWith(                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],          icon: Icon(MdiIcons.bookmark, color: AppTheme.textSecondary),

                fontWeight: FontWeight.w700,

              ),                begin: Alignment.topLeft,          tooltip: 'Saved Conversations',

              textAlign: TextAlign.center,

            ),                end: Alignment.bottomRight,        ),

            const SizedBox(height: 12),

            Text(              ),        IconButton(

              'I\'m here to help you with patient Emily Chen. Ask me anything about her medical history, current condition, or treatment recommendations.',

              style: AppTheme.bodyLarge.copyWith(              borderRadius: BorderRadius.circular(12),          onPressed: () {},

                color: AppTheme.textSecondary,

              ),            ),          icon: Icon(MdiIcons.contentSave, color: AppTheme.textSecondary),

              textAlign: TextAlign.center,

            ),            child: Icon(          tooltip: 'Export Chat',

            const SizedBox(height: 32),

            _buildSuggestionChips(),              MdiIcons.robot,        ),

          ],

        ),              color: Colors.white,        const SizedBox(width: 8),

      ),

    );              size: 24,        AppButton(

  }

            ),          text: 'Clear Chat',

  Widget _buildSuggestionChips() {

    final suggestions = [          ),          type: ButtonType.secondary,

      'Review Emily\'s vital signs',

      'Check medication interactions',          const SizedBox(width: 16),          size: ButtonSize.small,

      'Analyze recent lab results',

      'Suggest treatment plan',          Expanded(          icon: MdiIcons.deleteEmpty,

    ];

            child: Column(          onPressed: () {

    return Wrap(

      spacing: 12,              crossAxisAlignment: CrossAxisAlignment.start,            final authProvider = context.read<auth.AuthProvider>();

      runSpacing: 12,

      alignment: WrapAlignment.center,              children: [            context.read<ChatProvider>().startNewSession(

      children: suggestions.map((suggestion) {

        return ActionChip(                Text(              authProvider.currentUser?.role ?? auth.UserRole.nurse,

          label: Text(suggestion),

          onPressed: () {                  'Medical AI Assistant',              null,

            _messageController.text = suggestion;

            _sendMessage();                  style: AppTheme.titleLarge.copyWith(            );

          },

          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),                    fontWeight: FontWeight.w600,          },

          labelStyle: AppTheme.bodySmall.copyWith(

            color: AppTheme.primaryColor,                  ),        ),

            fontWeight: FontWeight.w500,

          ),                ),      ],

          side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.3)),

        );                Row(    );

      }).toList(),

    );                  children: [  }

  }

                    Container(

  Widget _buildMessageBubble(ChatMessage message, bool isUser, bool isFirst, bool isLast) {

    return Container(                      width: 8,  Widget _buildMessageArea() {

      margin: EdgeInsets.only(

        bottom: isLast ? 16 : 4,                      height: 8,    return Container(

        top: isFirst ? 16 : 0,

      ),                      decoration: BoxDecoration(      color: AppTheme.backgroundColor,

      child: Row(

        crossAxisAlignment: CrossAxisAlignment.start,                        color: AppTheme.successColor,      child: Consumer<ChatProvider>(

        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,

        children: [                        shape: BoxShape.circle,        builder: (context, chatProvider, child) {

          if (!isUser && isFirst) _buildAvatar(isUser),

          if (!isUser && !isFirst) const SizedBox(width: 40),                      ),          if (chatProvider.currentMessages.isEmpty) {

          if (!isUser) const SizedBox(width: 8),

          Flexible(                    ),            return _buildWelcomeState();

            child: Container(

              constraints: BoxConstraints(                    const SizedBox(width: 6),          }

                maxWidth: MediaQuery.of(context).size.width * 0.7,

              ),                    Text(

              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

              decoration: BoxDecoration(                      'Online • Ready to help with Emily Chen',          return ListView.builder(

                color: isUser ? AppTheme.primaryColor : AppTheme.surfaceColor,

                borderRadius: BorderRadius.only(                      style: AppTheme.bodySmall.copyWith(            controller: _scrollController,

                  topLeft: Radius.circular(isUser || !isFirst ? 16 : 4),

                  topRight: Radius.circular(!isUser || !isFirst ? 16 : 4),                        color: AppTheme.textSecondary,            padding: const EdgeInsets.all(20),

                  bottomLeft: Radius.circular(isUser || !isLast ? 16 : 4),

                  bottomRight: Radius.circular(!isUser || !isLast ? 16 : 4),                      ),            itemCount: chatProvider.currentMessages.length + (_isTyping ? 1 : 0),

                ),

                boxShadow: [                    ),            itemBuilder: (context, index) {

                  BoxShadow(

                    color: Colors.black.withOpacity(0.1),                  ],              if (index == chatProvider.currentMessages.length && _isTyping) {

                    blurRadius: 4,

                    offset: const Offset(0, 2),                ),                return _buildTypingIndicator();

                  ),

                ],              ],              }

              ),

              child: Column(            ),

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [          ),              final message = chatProvider.currentMessages[index];

                  Text(

                    message.content,          _buildHeaderActions(),              final isUser = message.type == MessageType.user;

                    style: AppTheme.bodyMedium.copyWith(

                      color: isUser ? Colors.white : AppTheme.textPrimary,        ],              final isFirst = index == 0 ||

                    ),

                  ),      ),                  chatProvider.currentMessages[index - 1].type != message.type;

                  if (isLast) ...[

                    const SizedBox(height: 4),    );              final isLast = index == chatProvider.currentMessages.length - 1 ||

                    Text(

                      _formatTime(message.timestamp),  }                  (index < chatProvider.currentMessages.length - 1 &&

                      style: AppTheme.labelSmall.copyWith(

                        color: isUser                      chatProvider.currentMessages[index + 1].type != message.type);

                            ? Colors.white.withOpacity(0.7)

                            : AppTheme.textTertiary,  Widget _buildHeaderActions() {

                      ),

                    ),    return Row(              return _buildMessageBubble(message, isUser, isFirst, isLast);

                  ],

                ],      children: [            },

              ),

            ),        IconButton(          );

          ),

          if (isUser) const SizedBox(width: 8),          onPressed: () {},        },

          if (isUser && isFirst) _buildAvatar(isUser),

          if (isUser && !isFirst) const SizedBox(width: 40),          icon: Icon(MdiIcons.history, color: AppTheme.textSecondary),      ),

        ],

      ),          tooltip: 'Chat History',    );

    );

  }        ),  }



  Widget _buildAvatar(bool isUser) {        IconButton(

    return Container(

      width: 32,          onPressed: () {},  Widget _buildWelcomeState() {

      height: 32,

      decoration: BoxDecoration(          icon: Icon(MdiIcons.bookmark, color: AppTheme.textSecondary),    return Center(

        color: isUser ? AppTheme.primaryColor : AppTheme.secondaryColor,

        shape: BoxShape.circle,          tooltip: 'Saved Conversations',      child: Column(

      ),

      child: Icon(        ),        mainAxisAlignment: MainAxisAlignment.center,

        isUser ? MdiIcons.account : MdiIcons.robot,

        color: Colors.white,        IconButton(        children: [

        size: 18,

      ),          onPressed: _togglePatientContext,          Container(

    );

  }          icon: Icon(            width: 120,



  Widget _buildTypingIndicator() {            _showPatientContext ? MdiIcons.accountOff : MdiIcons.account,            height: 120,

    return Container(

      margin: const EdgeInsets.symmetric(vertical: 8),            color: _showPatientContext ? AppTheme.primaryColor : AppTheme.textSecondary,            decoration: AppTheme.primaryGradientDecoration,

      child: Row(

        children: [          ),            child: Icon(

          _buildAvatar(false),

          const SizedBox(width: 8),          tooltip: _showPatientContext ? 'Hide Patient Context' : 'Show Patient Context',              MdiIcons.stethoscope,

          Container(

            padding: const EdgeInsets.all(16),        ),              color: Colors.white,

            decoration: BoxDecoration(

              color: AppTheme.surfaceColor,        const SizedBox(width: 8),              size: 48,

              borderRadius: BorderRadius.circular(16),

            ),        AppButton(            ),

            child: Row(

              mainAxisSize: MainAxisSize.min,          text: 'Clear Chat',          ),

              children: [

                _buildTypingDot(0),          type: ButtonType.secondary,          const SizedBox(height: 24),

                const SizedBox(width: 4),

                _buildTypingDot(1),          size: ButtonSize.small,          Text(

                const SizedBox(width: 4),

                _buildTypingDot(2),          icon: MdiIcons.deleteEmpty,            'Welcome to Medical AI Assistant',

              ],

            ),          onPressed: () {            style: AppTheme.headingLarge.copyWith(

          ),

        ],            final authProvider = context.read<auth.AuthProvider>();              color: AppTheme.textPrimary,

      ),

    );            context.read<ChatProvider>().startNewSession(            ),

  }

              authProvider.currentUser?.role ?? auth.UserRole.nurse,          ),

  Widget _buildTypingDot(int index) {

    return AnimatedContainer(              null,          const SizedBox(height: 12),

      duration: Duration(milliseconds: 600 + (index * 200)),

      width: 8,            );          Text(

      height: 8,

      decoration: BoxDecoration(          },            'I can help you with patient information, medical queries,\nand document analysis. How can I assist you today?',

        color: AppTheme.textTertiary,

        shape: BoxShape.circle,        ),            style: AppTheme.bodyMedium.copyWith(

      ),

    );      ],              color: AppTheme.textSecondary,

  }

    );            ),

  Widget _buildInputArea() {

    return Container(  }            textAlign: TextAlign.center,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(          ),

        color: AppTheme.surfaceColor,

        border: Border(  Widget _buildMessageArea() {          const SizedBox(height: 32),

          top: BorderSide(color: AppTheme.dividerColor),

        ),    return Container(          Wrap(

      ),

      child: Row(      color: AppTheme.backgroundColor,            spacing: 12,

        children: [

          IconButton(      child: Consumer<ChatProvider>(            runSpacing: 12,

            onPressed: () {},

            icon: Icon(MdiIcons.attachment, color: AppTheme.textSecondary),        builder: (context, chatProvider, child) {            children: [

            tooltip: 'Attach file',

          ),          if (chatProvider.currentMessages.isEmpty) {              _buildSuggestionChip('Analyze patient symptoms'),

          const SizedBox(width: 8),

          Expanded(            return _buildWelcomeState();              _buildSuggestionChip('Review lab results'),

            child: TextField(

              controller: _messageController,          }              _buildSuggestionChip('Check medication interactions'),

              focusNode: _messageFocusNode,

              decoration: InputDecoration(              _buildSuggestionChip('Patient care recommendations'),

                hintText: 'Ask about Emily Chen\'s condition...',

                hintStyle: AppTheme.bodyMedium.copyWith(          return ListView.builder(            ],

                  color: AppTheme.textTertiary,

                ),            controller: _scrollController,          ),

                filled: true,

                fillColor: AppTheme.backgroundColor,            padding: const EdgeInsets.all(20),        ],

                border: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(24),            itemCount: chatProvider.currentMessages.length + (_isTyping ? 1 : 0),      ),

                  borderSide: BorderSide.none,

                ),            itemBuilder: (context, index) {    );

                contentPadding: const EdgeInsets.symmetric(

                  horizontal: 20,              if (index == chatProvider.currentMessages.length && _isTyping) {  }

                  vertical: 12,

                ),                return _buildTypingIndicator();

              ),

              maxLines: null,              }  Widget _buildSuggestionChip(String text) {

              textInputAction: TextInputAction.send,

              onSubmitted: (_) => _sendMessage(),    return GestureDetector(

              onChanged: (text) {

                setState(() {              final message = chatProvider.currentMessages[index];      onTap: () {

                  _isTyping = text.isNotEmpty;

                });              final isUser = message.type == MessageType.user;        _messageController.text = text;

              },

            ),              final isFirst = index == 0 ||        _sendMessage();

          ),

          const SizedBox(width: 8),                  chatProvider.currentMessages[index - 1].type != message.type;      },

          IconButton(

            onPressed: () {},              final isLast = index == chatProvider.currentMessages.length - 1 ||      child: Container(

            icon: Icon(MdiIcons.microphone, color: AppTheme.textSecondary),

            tooltip: 'Voice input',                  chatProvider.currentMessages[index + 1].type != message.type;        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

          ),

          const SizedBox(width: 8),        decoration: BoxDecoration(

          Container(

            decoration: BoxDecoration(              return _buildMessageBubble(message, isUser, isFirst, isLast);          color: AppTheme.surfaceColor,

              gradient: LinearGradient(

                colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],            },          borderRadius: BorderRadius.circular(20),

              ),

              borderRadius: BorderRadius.circular(24),          );          border: Border.all(color: AppTheme.dividerColor),

            ),

            child: IconButton(        },        ),

              onPressed: _sendMessage,

              icon: Icon(MdiIcons.send, color: Colors.white),      ),        child: Row(

              tooltip: 'Send message',

            ),    );          mainAxisSize: MainAxisSize.min,

          ),

        ],  }          children: [

      ),

    );            Icon(

  }

  Widget _buildWelcomeState() {              MdiIcons.lightbulbOutline,

  String _formatTime(DateTime dateTime) {

    final now = DateTime.now();    return Center(              size: 16,

    final difference = now.difference(dateTime);

      child: Container(              color: AppTheme.primaryColor,

    if (difference.inDays > 0) {

      return '${difference.inDays}d ago';        constraints: const BoxConstraints(maxWidth: 600),            ),

    } else if (difference.inHours > 0) {

      return '${difference.inHours}h ago';        padding: const EdgeInsets.all(32),            const SizedBox(width: 6),

    } else if (difference.inMinutes > 0) {

      return '${difference.inMinutes}m ago';        child: Column(            Text(

    } else {

      return 'Just now';          mainAxisAlignment: MainAxisAlignment.center,              text,

    }

  }          children: [              style: AppTheme.bodySmall.copyWith(

}
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