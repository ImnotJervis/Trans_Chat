import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/translate_service.dart';
import '../models/user_model.dart';
import '../palette.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  final bool demoMode;
  final FirestoreService firestore;

  const ChatListScreen({
    super.key,
    required this.demoMode,
    required this.firestore,
  });

  @override
  Widget build(BuildContext context) {
    if (demoMode) {
      // 간단한 더미 UI
      return ListView(
        children: const [
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('데모 채팅방'),
            subtitle: Text('데모 메시지입니다.'),
          ),
        ],
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: firestore.getMyChatsMeta(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final chats = snapshot.data!;
        if (chats.isEmpty) {
          return const Center(child: Text('채팅 목록이 없습니다.'));
        }

        return ListView.separated(
          itemCount: chats.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final chat = chats[index];
            final chatId = chat['chatId'] as String;
            final recent = chat['recentMessage'] as String? ?? '';
            final participants =
            List<String>.from(chat['participants'] ?? const []);
            final receiverUid =
            participants.firstWhere((id) => id != firestore.currentUid,
                orElse: () => '');
            return FutureBuilder<UserModel?>(
              future: firestore.getUserByUid(receiverUid),
              builder: (context, snapUser) {
                final friend = snapUser.data;
                final title = friend?.name ?? '채팅방';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: (friend?.profileUrl?.isNotEmpty ?? false)
                        ? NetworkImage(friend!.profileUrl!)
                        : null,
                    child: (friend?.profileUrl?.isEmpty ?? true)
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(title),
                  subtitle: Text(
                    recent,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          demoMode: demoMode,
                          firestore: firestore,
                          translateService: TranslateService(),
                          chatId: chatId,
                          receiverUid: receiverUid,
                          receiverName: friend?.name ?? '친구',
                          targetLang: friend?.targetLang ?? 'ko',
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
