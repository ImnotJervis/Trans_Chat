import 'package:flutter/material.dart';
import 'mock_chat_list_screen.dart';
import 'mock_chat_screen.dart';

class MockFriendListScreen extends StatelessWidget {
  const MockFriendListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13B9FD);

    final mockFriends = [
      {
        'name': '데모 친구 1',
        'status': '영어 공부중입니다.',
      },
      {
        'name': '데모 친구 2',
        'status': '오늘 번역 과제 끝!',
      },
      {
        'name': '데모 친구 3',
        'status': '상태 메시지를 입력해보세요.',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 내 프로필
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFFE4F6FF),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              title: Text(
                'izayoi.saigo@gmail.com',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                '상태 메시지를 설정해보세요.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // 친구 섹션 타이틀
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '친구 ${mockFriends.length}',
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 친구 리스트
          Expanded(
            child: Container(
              color: const Color(0xFFF4F5F7),
              child: ListView.separated(
                itemCount: mockFriends.length,
                separatorBuilder: (_, __) => const Divider(
                  height: 1,
                  indent: 72,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  final f = mockFriends[index];
                  final name = f['name'] as String;
                  final status = f['status'] as String;

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
                      status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    onTap: () {
                      // ✅ 친구를 누르면 해당 친구와의 채팅 목업 화면으로
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
          if (index == 1) {
            // ✅ 채팅 탭으로 이동
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const MockChatListScreen(),
              ),
            );
          }
          // index == 0 이면 현재 화면이므로 아무것도 안 함
        },
      ),
    );
  }
}
