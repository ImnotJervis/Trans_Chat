import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String text;
  final String? translatedText;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.text,
    this.translatedText,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isMe ? const Color(0xFF13B9FD).withOpacity(0.8) : const Color(0xFFCCCCCC).withOpacity(0.8);
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: align,
              children: [
                Text(
                  text,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
                if (translatedText != null && translatedText != text) ...[
                  const SizedBox(height: 4),
                  Text(
                    translatedText!,
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
