import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ElaraChatMessage {
  final String text;
  final bool isUser;
  ElaraChatMessage(this.text, this.isUser);
}

Widget buildChatBubble(String text, bool isUser, [bool isDarkMode = false]) {
  return Align(
    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isUser ? const Color(0xFF3B82F6) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUser ? null : Border.all(color: const Color(0xFF6366F1).withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withValues(alpha: 0.04) : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 15,
          color: isUser ? Colors.white : const Color(0xFF181F36),
        ),
      ),
    ),
  );
}
