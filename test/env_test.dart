import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:leffet_psy/app/config/gemini_config.dart';
import 'package:leffet_psy/app/config/api_config.dart';

void main() {
  test('dotenv loads and GeminiConfig/ApiConfig read keys', () async {
    dotenv.loadFromString(
      envString: 'GEMINI_API_KEY=test_gemini_key_12345\nAPI_URL=https://custom-api.test.com',
    );

    expect(GeminiConfig.apiKey, equals('test_gemini_key_12345'));
    expect(GeminiConfig.isConfigured, isTrue);
    expect(ApiConfig.baseUrl, equals('https://custom-api.test.com'));
  });
}
