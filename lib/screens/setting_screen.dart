import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../palette.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';
import 'splash_screen.dart';

class SettingScreen extends StatefulWidget {
  final bool demoMode;
  final FirestoreService firestore;

  const SettingScreen({
    super.key,
    required this.demoMode,
    required this.firestore,
  });

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final _nameCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();
  String? _targetLang;

  Future<UserModel?>? _meFuture;

  @override
  void initState() {
    super.initState();
    _meFuture = widget.firestore.getCurrentUserProfile();
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    final me = await widget.firestore.getCurrentUserProfile();
    if (!mounted || me == null) return;
    setState(() {
      _nameCtrl.text = me.name ?? '';
      _statusCtrl.text = me.statusMessage ?? '';
      _targetLang = me.targetLang ?? 'ko';
    });
  }

  Future<void> _saveProfile() async {
    await widget.firestore.updateUserProfile(
      name: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      status:
      _statusCtrl.text.trim().isEmpty ? null : _statusCtrl.text.trim(),
    );
    if (_targetLang != null) {
      await widget.firestore.updateTargetLanguage(_targetLang!);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('저장되었습니다.')),
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    if (!mounted) return;
    Navigator.of(context).pop(); // bottom sheet 닫기
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const SplashScreen(demoMode: false),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _meFuture,
      builder: (context, snapshot) {
        final me = snapshot.data;
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  '설정',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // 프로필 영역
                Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundImage: (me?.profileUrl?.isNotEmpty ?? false)
                          ? NetworkImage(me!.profileUrl!)
                          : null,
                      child: (me?.profileUrl?.isEmpty ?? true)
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: '닉네임',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _statusCtrl,
                  decoration: const InputDecoration(
                    labelText: '상태 메시지',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  '도착 언어 설정',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _langChip('ko', '한국어'),
                    _langChip('en', '영어'),
                    _langChip('ja', '일본어'),
                    _langChip('zh-CN', '중국어'),
                  ],
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _saveProfile,
                    child: const Text('저장'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _logout,
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _langChip(String code, String label) {
    final selected = _targetLang == code;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _targetLang = code);
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
    );
  }
}
