import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'palette.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'Mockups/mock_friend_list_screen.dart';
import 'Mockups/mock_chat_list_screen.dart';

/// 전시용 기본값: Firebase 없이 더미로 돌리고 싶으면 true
const bool kDemoMode = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 로드 (없어도 에러 없이 통과)
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    debugPrint("⚠️ .env 파일을 찾을 수 없습니다. 기본값으로 실행합니다.");
  }

  if (!kDemoMode) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("✅ Firebase 초기화 완료");
    } catch (e) {
      debugPrint("❌ Firebase 초기화 실패: $e");
    }
  } else {
    debugPrint("🚀 Demo Mode로 실행 중 (Firebase 비활성화)");
  }

  runApp(const TrChatApp());
}

class TrChatApp extends StatelessWidget {
  const TrChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
      ),
      //home: SplashScreen(demoMode: kDemoMode),
        home: const MockFriendListScreen()
    );
  }
}
