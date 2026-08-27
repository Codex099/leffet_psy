import 'package:flutter_test/flutter_test.dart';
import 'package:leffet_psy/app/config/api_config.dart';
import 'package:leffet_psy/app/services/dio_client.dart';
import 'package:leffet_psy/app/widgets/state_placeholder.dart';

void main() {
  group('ApiConfig & DioClient Tests', () {
    test('ApiConfig URLs are properly constructed', () {
      expect(ApiConfig.baseUrl, isNotEmpty);
      expect(ApiConfig.authLogin, '/api/auth/login');
      expect(ApiConfig.authMe, '/api/auth/me');
      expect(ApiConfig.patients, '/api/patients');
      expect(ApiConfig.patient(12), '/api/patients/12');
      expect(ApiConfig.patientDossierMedical(12), '/api/patients/12/dossier-medical');
      expect(ApiConfig.patientPlanningRecurrent(12), '/api/patients/12/planning-recurrent');
      expect(ApiConfig.patientStatutHistorique(12), '/api/patients/12/statut-historique');
      expect(ApiConfig.groupes, '/api/groupes');
      expect(ApiConfig.groupe(5), '/api/groupes/5');
      expect(ApiConfig.seances, '/api/seances');
      expect(ApiConfig.seance(100), '/api/seances/100');
      expect(ApiConfig.taches, '/api/taches');
      expect(ApiConfig.tache(7), '/api/taches/7');
      expect(ApiConfig.calendrier, '/api/calendrier');
      expect(ApiConfig.employees, '/api/employees');
      expect(ApiConfig.employee(3), '/api/employees/3');
      expect(ApiConfig.uploads, '/api/uploads');
    });

    test('DioClient instance creates properly and can be reset', () {
      final dio1 = DioClient.instance;
      expect(dio1, isNotNull);
      expect(dio1.options.baseUrl, ApiConfig.baseUrl);
      expect(dio1.options.headers['Content-Type'], ApiConfig.contentType);

      DioClient.reset();
      final dio2 = DioClient.instance;
      expect(dio2, isNotNull);
    });

    test('StatePlaceholder error message sanitization', () {
      expect(
        StatePlaceholder.sanitizeErrorMessage('DioException [bad response]: 403'),
        contains('Accès restreint'),
      );
      expect(
        StatePlaceholder.sanitizeErrorMessage('connection timeout exceeded'),
        contains('délai d\'attente'),
      );
      expect(
        StatePlaceholder.sanitizeErrorMessage('SocketException: connection error'),
        contains('Impossible de joindre le serveur'),
      );
      expect(
        StatePlaceholder.sanitizeErrorMessage('404 Not Found introuvable'),
        contains('n\'ont pas été trouvées'),
      );
      expect(
        StatePlaceholder.sanitizeErrorMessage(''),
        contains('Impossible de charger les données'),
      );
    });
  });
}
