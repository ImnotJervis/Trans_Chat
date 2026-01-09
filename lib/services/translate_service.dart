import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslateService {
  final String? _apiKey = dotenv.env['AIzaSyA5BNy-kZwwpQoVze4jJ0mm-InsmDVknaM'];

  Future<String> translate({
    required String text,
    required String targetLang,
  }) async {
    // API 키 없으면 그냥 원문 반환 (전시나 오프라인 대비)
    if (_apiKey == null || _apiKey!.isEmpty) {
      return text;
    }

    try {
      final uri = Uri.parse(
        'https://translation.googleapis.com/language/translate/v2',
      );
      final res = await http.post(uri, body: {
        'q': text,
        'target': targetLang,
        'format': 'text',
        'key': _apiKey!,
      });

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final translated =
        data['data']['translations'][0]['translatedText'] as String;
        return translated;
      } else {
        return text; // 실패 시에도 원문 반환
      }
    } catch (_) {
      return text;
    }
  }
}
