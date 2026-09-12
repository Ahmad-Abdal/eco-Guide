import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get mapTilerApiKey => dotenv.env['MAPTILER_API_KEY'] ?? '';
}