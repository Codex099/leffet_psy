import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leffet_psy/app/config/api_config.dart';
import 'package:leffet_psy/app/models/patient_model.dart';
import 'package:leffet_psy/app/widgets/patient_avatar.dart';

void main() {
  group('ApiConfig.resolveMediaUrl Tests', () {
    test('Handles relative paths with leading slash', () {
      final res = ApiConfig.resolveMediaUrl('/uploads/patient_123.jpg');
      expect(res, '${ApiConfig.baseUrl}/uploads/patient_123.jpg');
    });

    test('Handles relative paths without leading slash', () {
      final res = ApiConfig.resolveMediaUrl('uploads/patient_123.jpg');
      expect(res, '${ApiConfig.baseUrl}/uploads/patient_123.jpg');
    });

    test('Handles Windows backslashes in paths', () {
      final res = ApiConfig.resolveMediaUrl(r'uploads\patient_123.jpg');
      expect(res, '${ApiConfig.baseUrl}/uploads/patient_123.jpg');

      final res2 = ApiConfig.resolveMediaUrl(r'/uploads\sub\patient_123.jpg');
      expect(res2, '${ApiConfig.baseUrl}/uploads/sub/patient_123.jpg');
    });

    test('Replaces localhost:8000 with ApiConfig.baseUrl', () {
      final res = ApiConfig.resolveMediaUrl('http://localhost:8000/uploads/patient_123.jpg');
      expect(res, '${ApiConfig.baseUrl}/uploads/patient_123.jpg');
    });

    test('Replaces 127.0.0.1:8000 with ApiConfig.baseUrl', () {
      final res = ApiConfig.resolveMediaUrl('http://127.0.0.1:8000/uploads/patient_123.jpg');
      expect(res, '${ApiConfig.baseUrl}/uploads/patient_123.jpg');
    });

    test('Replaces 0.0.0.0:8000 with ApiConfig.baseUrl', () {
      final res = ApiConfig.resolveMediaUrl('http://0.0.0.0:8000/uploads/patient_123.jpg');
      expect(res, '${ApiConfig.baseUrl}/uploads/patient_123.jpg');
    });

    test('Preserves already valid remote URLs on other domains', () {
      const externalUrl = 'https://images.unsplash.com/photo-123.jpg';
      final res = ApiConfig.resolveMediaUrl(externalUrl);
      expect(res, externalUrl);
    });

    test('Preserves local file URIs', () {
      const fileUri = 'file:///data/user/0/com.psycare/cache/pic.jpg';
      final res = ApiConfig.resolveMediaUrl(fileUri);
      expect(res, fileUri);
    });

    test('Returns empty string for null or empty input', () {
      expect(ApiConfig.resolveMediaUrl(null), '');
      expect(ApiConfig.resolveMediaUrl(''), '');
      expect(ApiConfig.resolveMediaUrl('   '), '');
    });
  });

  group('PatientModel Photo Serialization & Resolution Tests', () {
    test('Parses photo from standard photo field', () {
      final model = PatientModel.fromJson({
        'id': 'p1',
        'nom': 'Benali',
        'prenom': 'Sami',
        'photo': '/uploads/photo1.jpg',
      });
      expect(model.photo, '/uploads/photo1.jpg');
      expect(model.photoUrl, '${ApiConfig.baseUrl}/uploads/photo1.jpg');
    });

    test('Parses photo from photo_url field if backend uses snake_case', () {
      final model = PatientModel.fromJson({
        'id': 'p2',
        'nom': 'Dupont',
        'prenom': 'Jean',
        'photo_url': '/uploads/photo2.jpg',
      });
      expect(model.photo, '/uploads/photo2.jpg');
      expect(model.photoUrl, '${ApiConfig.baseUrl}/uploads/photo2.jpg');
    });

    test('Parses photo from avatar field if backend uses avatar', () {
      final model = PatientModel.fromJson({
        'id': 'p3',
        'nom': 'Martin',
        'prenom': 'Lucas',
        'avatar': 'uploads/avatar3.jpg',
      });
      expect(model.photo, 'uploads/avatar3.jpg');
      expect(model.photoUrl, '${ApiConfig.baseUrl}/uploads/avatar3.jpg');
    });

    test('toJson serializes both photo and photo_url', () {
      final model = PatientModel(
        id: 'p4',
        nom: 'Test',
        prenom: 'User',
        photo: '/uploads/saved.jpg',
      );
      final json = model.toJson();
      expect(json['photo'], '/uploads/saved.jpg');
      expect(json['photo_url'], '/uploads/saved.jpg');
    });
  });

  group('PatientAvatar Widget Tests', () {
    testWidgets('Renders fallback gradient with initials when photoUrl is null or empty',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PatientAvatar(
              initials: 'SB',
              photoUrl: null,
            ),
          ),
        ),
      );

      expect(find.text('SB'), findsOneWidget);
    });

    testWidgets('Renders without crashing when photoUrl is a relative path',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PatientAvatar(
              initials: 'JD',
              photoUrl: '/uploads/patient.jpg',
            ),
          ),
        ),
      );

      // Should not crash, and initially displays the fallback while loading or on test network
      expect(find.byType(PatientAvatar), findsOneWidget);
    });
  });
}
