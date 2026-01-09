import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  FirestoreService({this.demoMode = false});

  final bool demoMode;
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser?.uid ?? '';

  // ---------------------------------------------------------------------------
  // 🧩 사용자 관리
  // ---------------------------------------------------------------------------

  /// ✅ 최초 로그인 시 Firestore에 사용자 문서를 생성
  ///  - Auth에 새 계정이 생기면 이 메서드를 한 번만 호출해주면 됨
  ///  - 컬렉션: users_data / 문서 ID: uid
  Future<void> createUserIfNotExists(User user) async {
    if (demoMode) return; // 데모 모드에서는 Firestore 접근 X

    final docRef = _db.collection('users_data').doc(user.uid);
    final snap = await docRef.get();

    // 이미 문서 있으면 아무 것도 안 함
    if (snap.exists) return;

    // 최초 로그인 사용자 → 새 문서 생성
    await docRef.set({
      'uid': user.uid,
      'name': user.displayName ?? '',
      'email': user.email ?? '',
      'profileUrl': user.photoURL ?? '',
      'statusMessage': '안녕하세요!',
      'targetLang': 'ko',          // 기본 도착 언어
      'friends': <String>[],       // 초기 친구 목록
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 현재 로그인한 사용자 프로필 조회
  Future<UserModel?> getCurrentUserProfile() async {
    if (demoMode) {
      if (currentUid.isEmpty) return null;
      return UserModel(
        uid: currentUid,
        name: '전시용 사용자',
        email: 'demo@example.com',
        statusMessage: '전시 모드입니다.',
        profileUrl: null,
        targetLang: 'ko',
      );
    }

    if (currentUid.isEmpty) return null;
    final snap = await _db.collection('users_data').doc(currentUid).get();
    if (!snap.exists) return null;
    return UserModel.fromMap(snap.data()!);
  }

  /// UID로 유저 찾기
  Future<UserModel?> getUserByUid(String uid) async {
    if (demoMode) return null;
    final snap = await _db.collection('users_data').doc(uid).get();
    if (!snap.exists) return null;
    return UserModel.fromMap(snap.data()!);
  }

  /// 내 프로필 수정
  Future<void> updateUserProfile({
    String? name,
    String? status,
    String? photoUrl,
  }) async {
    if (demoMode) return;
    if (currentUid.isEmpty) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (status != null) updates['statusMessage'] = status;
    if (photoUrl != null) updates['profileUrl'] = photoUrl;

    await _db.collection('users_data').doc(currentUid).update(updates);
  }

  /// 도착 언어 변경
  Future<void> updateTargetLanguage(String targetLang) async {
    if (demoMode) return;
    if (currentUid.isEmpty) return;

    await _db
        .collection('users_data')
        .doc(currentUid)
        .update({'targetLang': targetLang});
  }

  /// 나 자신을 제외한 모든 사용자 가져오기
  Future<List<UserModel>> getAllUsersExceptCurrent() async {
    if (demoMode) {
      // 데모용 더미 목록
      return [
        UserModel(
          uid: 'demo_friend_1',
          name: '데모 친구 1',
          email: 'friend1@example.com',
          statusMessage: '테스트 중입니다.',
        ),
        UserModel(
          uid: 'demo_friend_2',
          name: '데모 친구 2',
          email: 'friend2@example.com',
          statusMessage: 'TrChat 데모!',
        ),
      ];
    }

    final qs = await _db.collection('users_data').get();
    return qs.docs
        .where((d) => d.id != currentUid)
        .map((d) => UserModel.fromMap(d.data()))
        .toList();
  }

  /// 이메일로 사용자 정확히 검색 (==)
  Future<List<UserModel>> searchUsersByEmail(String email) async {
    if (demoMode) {
      // 단순 데모용
      return [
        UserModel(
          uid: 'demo_search',
          name: '검색 데모 친구',
          email: email,
          statusMessage: '검색 결과 예시입니다.',
        ),
      ];
    }

    final qs = await _db
        .collection('users_data')
        .where('email', isEqualTo: email)
        .get();

    return qs.docs.map((d) => UserModel.fromMap(d.data())).toList();
  }

  /// 친구 추가 (양방향)
  Future<void> addFriend(String friendUid) async {
    if (demoMode) return;
    if (currentUid.isEmpty || friendUid.isEmpty) return;

    final myRef = _db.collection('users_data').doc(currentUid);
    final friendRef = _db.collection('users_data').doc(friendUid);

    await _db.runTransaction((tx) async {
      final mySnap = await tx.get(myRef);
      final friendSnap = await tx.get(friendRef);
      if (!mySnap.exists || !friendSnap.exists) return;

      final myFriends = List<String>.from(mySnap.data()?['friends'] ?? []);
      final friendFriends =
      List<String>.from(friendSnap.data()?['friends'] ?? []);

      if (!myFriends.contains(friendUid)) myFriends.add(friendUid);
      if (!friendFriends.contains(currentUid)) friendFriends.add(currentUid);

      tx.update(myRef, {'friends': myFriends});
      tx.update(friendRef, {'friends': friendFriends});
    });
  }

  // ---------------------------------------------------------------------------
  // 💬 메시지 관리 (1:1 채팅)
  // ---------------------------------------------------------------------------

  String getChatId(String uid1, String uid2) {
    final list = [uid1, uid2]..sort();
    return '${list.first}_${list.last}';
  }

  Future<void> _ensureChatMeta({
    required String chatId,
    required List<String> participants,
    required String recentMessage,
    required DateTime recentAt,
  }) async {
    if (demoMode) return;

    final chatRef = _db.collection('chats').doc(chatId);
    final sorted = [...participants]..sort();

    await chatRef.set(
      {
        'participants': sorted,
        'recentMessage': recentMessage,
        'recentAt': Timestamp.fromDate(recentAt),
      },
      SetOptions(merge: true),
    );
  }

  /// ✅ 하위 호환 포함 메시지 전송
  Future<void> sendMessage({
    required String chatId,
    required String receiverUid,
    // 새 표준
    String? originalText,
    String? translatedText,
    DateTime? createdAt,
    // 구 표준(호환)
    String? message,
    String? content,
    DateTime? timestamp,
  }) async {
    if (demoMode) return;

    final String finalText =
        originalText ?? message ?? content ?? '';
    final DateTime finalCreatedAt =
        createdAt ?? timestamp ?? DateTime.now();

    if (finalText.isEmpty) {
      throw ArgumentError('sendMessage: 메시지 내용이 비어 있습니다.');
    }

    final msgRef =
    _db.collection('chats').doc(chatId).collection('messages').doc();

    final model = MessageModel(
      messageId: msgRef.id,
      chatId: chatId,
      senderUid: currentUid,
      receiverUid: receiverUid,
      originalText: finalText,
      translatedText: translatedText,
      createdAt: finalCreatedAt,
    );

    await msgRef.set(model.toMap());
    await _ensureChatMeta(
      chatId: chatId,
      participants: [currentUid, receiverUid],
      recentMessage:
      (translatedText?.isNotEmpty ?? false) ? translatedText! : finalText,
      recentAt: finalCreatedAt,
    );
  }

  /// 채팅 메시지 스트림
  Stream<List<MessageModel>> getMessagesStream(
      String chatId, {
        int limit = 200,
      }) {
    if (demoMode) {
      final now = DateTime.now();
      final dummy = [
        MessageModel(
          messageId: '1',
          chatId: chatId,
          senderUid: currentUid,
          receiverUid: 'demo_friend',
          originalText: '안녕! 전시용 메시지야.',
          translatedText: 'Hello! This is a demo message.',
          createdAt: now.subtract(const Duration(minutes: 1)),
        ),
        MessageModel(
          messageId: '2',
          chatId: chatId,
          senderUid: 'demo_friend',
          receiverUid: currentUid,
          originalText: '반가워!',
          translatedText: 'Nice to meet you!',
          createdAt: now,
        ),
      ];
      return Stream.value(dummy);
    }

    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (qs) => qs.docs
          .map((d) => MessageModel.fromMap(d.data(), d.id))
          .toList(),
    );
  }

  /// 내 채팅방 메타 정보 목록
  Future<List<Map<String, dynamic>>> getMyChatsMeta() async {
    if (demoMode) {
      return [
        {
          'chatId': 'demo_chat_1',
          'recentMessage': '데모 채팅입니다.',
          'recentAt': Timestamp.fromDate(DateTime.now()),
          'participants': [currentUid, 'demo_friend_1'],
        },
      ];
    }

    if (currentUid.isEmpty) return [];

    final qs = await _db
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .orderBy('recentAt', descending: true)
        .get();

    return qs.docs.map((d) {
      final data = d.data();
      data['chatId'] = d.id;
      return data;
    }).toList();
  }
}
