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
    Key? key,
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
          color: Colors.black.withOpacity(0.25),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Color(0xFF8B5CF6), // Purple border
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withOpacity(0.18),
                      blurRadius: 32,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header with close button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, color: const Color(0xFF3B82F6), size: 28),
                          const SizedBox(width: 12),
                          Text('Elara AI Chat', style: GoogleFonts.orbitron(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF3B82F6))),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey, size: 28),
                            onPressed: onClose,
                            tooltip: 'Close chat',
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, thickness: 1),
                    // Chat messages area
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return buildChatBubble(msg.text, msg.isUser);
                        },
                      ),
                    ),
                    // Input area
                    Container(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              style: GoogleFonts.inter(fontSize: 16, color: const Color(0xFF181F36)),
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                hintStyle: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF6366F1)),
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
                                filled: true,
                                fillColor: Colors.white,
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
    );
  }
}
