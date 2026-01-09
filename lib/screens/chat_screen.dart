import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/translate_service.dart';
import '../models/message_model.dart';
import '../palette.dart';

class ChatScreen extends StatefulWidget {
  final bool demoMode;
  final FirestoreService firestore;
  final TranslateService translateService;

  final String chatId;
  final String receiverUid;
  final String receiverName;
  final String targetLang;

  const ChatScreen({
    super.key,
    required this.demoMode,
    required this.firestore,
    required this.translateService,
    required this.chatId,
    required this.receiverUid,
    required this.receiverName,
    required this.targetLang,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    try {
      String translated = text;
      if (!widget.demoMode) {
        translated = await widget.translateService
            .translate(text: text, targetLang: widget.targetLang);
      }

      await widget.firestore.sendMessage(
        chatId: widget.chatId,
        receiverUid: widget.receiverUid,
        originalText: text,
        translatedText: translated,
      );
      _controller.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('메시지 전송 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = widget.firestore.currentUid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: widget.firestore.getMessagesStream(widget.chatId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return const Center(child: Text('첫 메시지를 보내보세요.'));
                }
                return ListView.builder(
                  reverse: true,
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final m = messages[index];
                    final isMe = m.senderUid == currentUid;
                    return _buildBubble(m, isMe);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '메시지 입력',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: _sending
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.send),
                    color: AppColors.primary,
                    onPressed: _sending ? null : _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(MessageModel m, bool isMe) {
    final bg = isMe ? AppColors.myBubble : AppColors.friendBubble;
    final align =
    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: isMe
          ? const Radius.circular(16)
          : const Radius.circular(4),
      bottomRight: isMe
          ? const Radius.circular(4)
          : const Radius.circular(16),
    );

    final showTwoLines =
        !isMe && (m.translatedText?.isNotEmpty ?? false) && m.translatedText != m.originalText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: radius,
              ),
              child: Column(
                crossAxisAlignment: align,
                children: [
                  if (showTwoLines) ...[
                    Text(
                      m.originalText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.translatedText ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
                    Text(
                      m.originalText,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
