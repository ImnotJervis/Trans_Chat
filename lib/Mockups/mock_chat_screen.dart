import 'package:flutter/material.dart';

class MockChatScreen extends StatelessWidget {
  final String friendName;

  const MockChatScreen({
    super.key,
    this.friendName = '데모 친구 1',
  });

  @override
  Widget build(BuildContext context) {
    const myColor = Color(0xFF13B9FD);
    const otherColor = Color(0xFFE5E5E5);

    // 목업용 메시지들
    final messages = <_MockMessage>[
      _MockMessage(
        fromMe: true,
        original: '오늘 테스트 해볼까?',
        translated: null, // 내 메시지는 번역 X
        time: '오전 11:35',
      ),
      _MockMessage(
        fromMe: false,
        original: "Sure, let's try real-time translation.",
        translated: '좋아요, 실시간 번역을 해보죠.',
        time: '오전 11:36',
      ),
      _MockMessage(
        fromMe: false,
        original: '안녕하세요!',
        translated: null, // 동일 언어 → 한 줄
        time: '오전 11:37',
      ),
      _MockMessage(
        fromMe: true,
        original: '영어로 아무 말이나 해줘.',
        translated: null,
        time: '오전 11:38',
      ),
      _MockMessage(
        fromMe: false,
        original: 'This sentence will be translated into Korean.',
        translated: '이 문장은 한국어로 번역됩니다.',
        time: '오전 11:39',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE4F6FF),
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    friendName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '영어 → 한국어 자동 번역',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              reverse: true, // 최근 메시지가 아래
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                final isMe = msg.fromMe;

                final bubbleColor = isMe ? myColor : otherColor;
                final align =
                isMe ? Alignment.centerRight : Alignment.centerLeft;
                final radius = BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                  isMe ? const Radius.circular(16) : const Radius.circular(4),
                  bottomRight:
                  isMe ? const Radius.circular(4) : const Radius.circular(16),
                );

                return Align(
                  alignment: align,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          constraints: BoxConstraints(
                            maxWidth:
                            MediaQuery.of(context).size.width * 0.7,
                          ),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: radius,
                          ),
                          child: _MessageText(msg: msg, isMe: isMe),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          msg.time,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // 하단 입력창 (동작 X – UI용)
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: '메시지 입력',
                          border: InputBorder.none,
                        ),
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: myColor),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockMessage {
  final bool fromMe;
  final String original;
  final String? translated;
  final String time;

  const _MockMessage({
    required this.fromMe,
    required this.original,
    this.translated,
    required this.time,
  });
}

class _MessageText extends StatelessWidget {
  final _MockMessage msg;
  final bool isMe;

  const _MessageText({required this.msg, required this.isMe});

  @override
  Widget build(BuildContext context) {
    // 상대 메시지 + 번역이 있을 때만 2층 구조
    if (!isMe && msg.translated != null && msg.translated!.isNotEmpty) {
      return Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            msg.original,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            msg.translated!,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    // 그 외에는 한 줄
    return Text(
      msg.original,
      style: const TextStyle(
        fontSize: 13,
        color: Colors.black87,
      ),
    );
  }
}
