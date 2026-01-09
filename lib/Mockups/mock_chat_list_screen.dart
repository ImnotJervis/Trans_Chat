import 'package:flutter/material.dart';
import '../Mockups/mock_friend_list_screen.dart';
import 'mock_chat_screen.dart';

class MockChatListScreen extends StatelessWidget {
  const MockChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13B9FD);

    final chats = [
      {
        'name': '데모 친구 1',
        'last': '번역 테스트 해보자!',
        'time': '오전 11:32',
        'unread': 2,
      },
      {
        'name': '데모 친구 2',
        'last': '오늘 저녁에 볼래?',
        'time': '어제',
        'unread': 0,
      },
      {
        'name': '데모 오픈채팅',
        'last': 'Welcome to TrChat demo room.',
        'time': '월',
        'unread': 5,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'TrChat',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 4),
            child: Icon(Icons.person_add_outlined),
          ),
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: chats.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: 72,
        ),
        itemBuilder: (context, index) {
          final c = chats[index];
          final name = c['name'] as String;
          final last = c['last'] as String;
          final time = c['time'] as String;
          final unread = c['unread'] as int;

          return ListTile(
            leading: const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFE4F6FF),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              last,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                if (unread > 0)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unread.toString(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            onTap: () {
              // ✅ 채팅 리스트에서도 채팅 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MockChatScreen(
                    friendName: name,
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: primary,
        unselectedItemColor: Colors.grey[500],
        backgroundColor: Colors.white,
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
        onTap: (index) {
          if (index == 0) {
            // ✅ 친구 탭으로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const MockFriendListScreen(),
              ),
            );
          }
          // index == 1 은 현재 화면
        },
      ),
    );
  }
}
