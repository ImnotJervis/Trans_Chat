import 'package:flutter/material.dart';
import '../palette.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import '../services/translate_service.dart';
import 'chat_screen.dart';

class FriendProfileScreen extends StatelessWidget {
  final bool demoMode;
  final FirestoreService firestore;
  final UserModel friend;

  const FriendProfileScreen({
    super.key,
    required this.demoMode,
    required this.firestore,
    required this.friend,
  });

  Future<void> _addFriend(BuildContext context) async {
    await firestore.addFriend(friend.uid);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${friend.name ?? '친구'} 님을 추가했습니다.')),
      );
    }
  }

  void _openChat(BuildContext context) {
    final chatId = firestore.getChatId(firestore.currentUid, friend.uid);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          demoMode: demoMode,
          firestore: firestore,
          translateService: TranslateService(),
          chatId: chatId,
          receiverUid: friend.uid,
          receiverName: friend.name ?? '친구',
          targetLang: friend.targetLang ?? 'ko',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 핸들 + 닫기
            Row(
              children: [
                const Text(
                  '프로필',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 40,
              backgroundImage: (friend.profileUrl?.isNotEmpty ?? false)
                  ? NetworkImage(friend.profileUrl!)
                  : null,
              child: (friend.profileUrl?.isEmpty ?? true)
                  ? const Icon(Icons.person, size: 40)
                  : null,
            ),
            const SizedBox(height: 12),
            Text(
              friend.name ?? friend.email ?? '알 수 없음',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            if (friend.statusMessage != null &&
                friend.statusMessage!.isNotEmpty)
              Text(
                friend.statusMessage!,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            const SizedBox(height: 16),
            if (friend.email != null)
              Text(
                friend.email!,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _addFriend(context),
                    child: const Text('친구 추가'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _openChat(context),
                    child: const Text('채팅하기'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
