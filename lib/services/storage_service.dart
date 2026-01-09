import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 이미지 선택 후 Firebase Storage 업로드
  Future<String?> uploadProfileImage(String uid) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return null;

      final file = File(picked.path);
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');

      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();

      return url;
    } catch (e) {
      print('❌ 프로필 업로드 오류: $e');
      return null;
    }
  }


}
