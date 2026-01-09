import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String messageId;
  final String chatId;
  final String senderUid;
  final String receiverUid;
  final String originalText;
  final String? translatedText;
  final DateTime createdAt;

  MessageModel({
    required this.messageId,
    required this.chatId,
    required this.senderUid,
    required this.receiverUid,
    required this.originalText,
    this.translatedText,
    required this.createdAt,
  });

  factory MessageModel.fromMap(Map<String, dynamic> data, String id) {
    return MessageModel(
      messageId: id,
      chatId: data['chatId'] ?? '',
      senderUid: data['senderUid'] ?? '',
      receiverUid: data['receiverUid'] ?? '',
      originalText: data['originalText'] ?? data['content'] ?? '',
      translatedText: data['translatedText'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          (data['timestamp'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'originalText': originalText,
      'translatedText': translatedText,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // 🔧 과거 코드 호환용
  String get content => originalText;
  DateTime get timestamp => createdAt;
}
