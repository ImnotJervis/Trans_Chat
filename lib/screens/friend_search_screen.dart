import 'package:flutter/material.dart';
import '../palette.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'friend_profile_screen.dart';

class FriendSearchScreen extends StatefulWidget {
  final bool demoMode;
  final FirestoreService firestore;

  const FriendSearchScreen({
    super.key,
    required this.demoMode,
    required this.firestore,
  });

  @override
  State<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends State<FriendSearchScreen> {
  final _emailCtrl = TextEditingController();
  Future<List<UserModel>>? _searchFuture;

  void _search() {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    setState(() {
      _searchFuture = widget.firestore.searchUsersByEmail(email);
    });
  }

  void _openProfile(UserModel friend) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => FriendProfileScreen(
        demoMode: widget.demoMode,
        firestore: widget.firestore,
        friend: friend,
      ),
    );
  }

  Future<void> _addFriend(UserModel friend) async {
    await widget.firestore.addFriend(friend.uid);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${friend.name ?? friend.email} 님을 친구로 추가했습니다')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 바
            Row(
              children: [
                const Text(
                  '친구 추가',
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
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: '이메일로 친구 검색',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _search,
                child: const Text('검색'),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _searchFuture == null
                  ? const Center(child: Text('이메일을 입력해 검색해보세요.'))
                  : FutureBuilder<List<UserModel>>(
                future: _searchFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  final users = snapshot.data!;
                  if (users.isEmpty) {
                    return const Center(child: Text('검색 결과가 없습니다.'));
                  }
                  return ListView.separated(
                    itemCount: users.length,
                    separatorBuilder: (_, __) =>
                    const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final u = users[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                          (u.profileUrl?.isNotEmpty ?? false)
                              ? NetworkImage(u.profileUrl!)
                              : null,
                          child: (u.profileUrl?.isEmpty ?? true)
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(u.name ?? u.email ?? '알 수 없음'),
                        subtitle: Text(u.email ?? ''),
                        onTap: () => _openProfile(u),
                        trailing: IconButton(
                          icon: const Icon(Icons.person_add_alt_1),
                          onPressed: () => _addFriend(u),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
