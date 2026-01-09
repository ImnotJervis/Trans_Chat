import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../palette.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'chat_list_screen.dart';
import 'friend_search_screen.dart';
import 'setting_screen.dart';
import 'friend_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool demoMode;
  const HomeScreen({super.key, required this.demoMode});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  late final FirestoreService _firestore;
  int _selectedIndex = 0;
  Future<UserModel?>? _meFuture;

  @override
  void initState() {
    super.initState();
    _firestore = FirestoreService(demoMode: widget.demoMode);
    _meFuture = _firestore.getCurrentUserProfile();
  }

  void _openSearchFriend() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FriendSearchScreen(
          demoMode: widget.demoMode,
          firestore: _firestore,
        ),
      ),
    );
  }

  void _openSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SettingScreen(
        demoMode: widget.demoMode,
        firestore: _firestore,
      ),
    );
  }

  void _openFriendProfile(UserModel friend) {
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
        firestore: _firestore,
        friend: friend,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'TrChat',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined),
            onPressed: _openSearchFriend,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: Column(
        children: [
          // 내 프로필 영역
          FutureBuilder<UserModel?>(
            future: _meFuture,
            builder: (context, snapshot) {
              final me = snapshot.data;
              return Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: Colors.white,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: (me?.profileUrl?.isNotEmpty ?? false)
                          ? NetworkImage(me!.profileUrl!)
                          : null,
                      child: (me?.profileUrl?.isEmpty ?? true)
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            me?.name?.isNotEmpty == true
                                ? me!.name!
                                : (user?.email ?? '나'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            me?.statusMessage ?? '상태 메시지를 설정해보세요.',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: _selectedIndex == 0
                ? _buildFriendsTab()
                : ChatListScreen(
              demoMode: widget.demoMode,
              firestore: _firestore,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '친구',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: '채팅',
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsTab() {
    return FutureBuilder<List<UserModel>>(
      future: _firestore.getAllUsersExceptCurrent(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data!;
        if (users.isEmpty) {
          return const Center(child: Text('추가된 친구가 없습니다.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: users.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final u = users[index];
            return ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                radius: 22,
                backgroundImage: (u.profileUrl?.isNotEmpty ?? false)
                    ? NetworkImage(u.profileUrl!)
                    : null,
                child: (u.profileUrl?.isEmpty ?? true)
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(
                u.name ?? u.email ?? '알 수 없음',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: (u.statusMessage?.isNotEmpty ?? false)
                  ? Text(
                u.statusMessage!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
                  : null,
              onTap: () => _openFriendProfile(u),
            );
          },
        );
      },
    );
  }
}
