import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leffet_psy/app/config/api_config.dart';

void main() {
  group('ApiConfig Base URL & Media Resolution Tests', () {
    test('ngrokUrl is configured properly', () {
      expect(ApiConfig.ngrokUrl, 'https://leffetpsy.vercel.app');
    });

    test('baseUrl returns a valid URL', () {
      final base = ApiConfig.baseUrl;
      expect(base.startsWith('http://') || base.startsWith('https://'), isTrue);
      expect(base.endsWith('/'), isFalse);
    });

    test('baseUrl adapts depending on release vs debug platform', () {
      if (kReleaseMode) {
        expect(ApiConfig.baseUrl, ApiConfig.ngrokUrl);
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        expect(ApiConfig.baseUrl, 'http://10.0.2.2:8000');
      } else {
        expect(ApiConfig.baseUrl, 'http://127.0.0.1:8000');
      }
    });

    test('resolveMediaUrl correctly uses baseUrl for local paths', () {
      final resolved = ApiConfig.resolveMediaUrl('/uploads/patient.jpg');
      expect(resolved, '${ApiConfig.baseUrl}/uploads/patient.jpg');
    });

    test('resolveMediaUrl replaces localhost with active baseUrl', () {
      final resolved = ApiConfig.resolveMediaUrl('http://localhost:8000/uploads/avatar.png');
      expect(resolved, '${ApiConfig.baseUrl}/uploads/avatar.png');
    });
  });
}
