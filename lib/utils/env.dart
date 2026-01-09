import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String? get googleApiKey => dotenv.maybeGet('GOOGLE_TRANSLATE_API_KEY');
}
