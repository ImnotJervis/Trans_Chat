class UserModel {
  final String uid;
  final String? name;
  final String? email;
  final String? statusMessage;
  final String? profileUrl;
  final String? targetLang;
  final List<String> friends;

  UserModel({
    required this.uid,
    this.name,
    this.email,
    this.statusMessage,
    this.profileUrl,
    this.targetLang,
    this.friends = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> data, {String? documentId}) {
    return UserModel(
      uid: data['uid'] ?? documentId ?? '',
      name: data['name'],
      email: data['email'],
      statusMessage: data['statusMessage'],
      profileUrl: data['profileUrl'],
      targetLang: data['targetLang'],
      friends: List<String>.from(data['friends'] ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'statusMessage': statusMessage,
      'profileUrl': profileUrl,
      'targetLang': targetLang,
      'friends': friends,
    };
  }

  // 🔧 과거 코드 호환용 getter
  String? get status => statusMessage;
  String? get photoUrl => profileUrl;
}
