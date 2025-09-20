import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'elara_chat_message.dart';
import 'dart:ui';

class ElaraChatOverlay extends StatelessWidget {
  final List<ElaraChatMessage> messages;
  final String input;
  final ValueChanged<String> onInputChanged;
  final VoidCallback onSend;
  final VoidCallback onClose;

  const ElaraChatOverlay({
    super.key,
    required this.messages,
    required this.input,
    required this.onInputChanged,
    required this.onSend,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedOpacity(
        opacity: 1.0,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        child: Container(
          color: Colors.transparent, // Fully transparent overlay
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                width: 280,
                height: 420,
                decoration: BoxDecoration(
                  color: Colors.transparent, // Fully transparent box
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6),
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withValues(alpha: 0.18),
                      blurRadius: 32,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: Column(
                      children: [
                        // Header with close button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          child: // Fixed header Row in your elara_chat_overlay.dart
                          Row(
                            children: [
                              // Icon
                              Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              // Use Expanded to prevent overflow
                              Expanded(
                              child: Text(
                              'Elara AI Chat',
                              style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis, // Handle text overflow
                            maxLines: 1,
                            ),
                                ),
                   // Close button
    IconButton(
      onPressed: onClose,
      icon: const Icon(Icons.close, color: Colors.white, size: 18),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 30,
        minHeight: 30,
      ),
    ),
  ],
)
                        ),
                        const Divider(height: 1, thickness: 1, color: Colors.white24),
                        // Chat messages area
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg = messages[index];
                              return Align(
                                alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: msg.isUser ? const Color(0xFF3B82F6) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    border: msg.isUser ? null : Border.all(color: const Color(0xFF6366F1).withValues(alpha: 0.3)),
                                  ),
                                  child: Text(
                                    msg.text,
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Input area
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Ask a medical question...',
                                    hintStyle: GoogleFonts.inter(
                                      fontSize: 15,
                                      color: Colors.white.withValues(alpha: 0.6),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2.5),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    filled: false,
                                  ),
                                  onChanged: onInputChanged,
                                  onSubmitted: (value) {
                                    if (value.trim().isNotEmpty) {
                                      onSend();
                                    }
                                  },
                                  controller: TextEditingController(text: input),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.send, color: Colors.white),
                                  onPressed: () {
                                    if (input.trim().isNotEmpty) {
                                      onSend();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

