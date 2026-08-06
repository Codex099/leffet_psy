import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/patient_model.dart';
import '../models/parent_model.dart';
import '../models/patient_statut_historique_model.dart';
import '../models/dossier_medical_model.dart';
import 'dio_client.dart';

class PatientService {
  final Dio _dio = DioClient.instance;

  /// GET /api/patients — Liste des patients (filtrée selon les droits)
  Future<List<PatientModel>> getPatients({
    bool? actif,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (actif != null) queryParams['actif'] = actif;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _dio.get(
      ApiConfig.patients,
      queryParameters: queryParams,
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => PatientModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/patients — Création d'un patient
  Future<PatientModel> createPatient(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConfig.patients, data: data);
    return PatientModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/patients/{id} — Fiche patient
  Future<PatientModel> getPatient(dynamic id) async {
    final response = await _dio.get(ApiConfig.patient(id));
    return PatientModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// PATCH /api/patients/{id} — Mise à jour patient
  Future<PatientModel> updatePatient(dynamic id, Map<String, dynamic> data) async {
    final response = await _dio.patch(ApiConfig.patient(id), data: data);
    return PatientModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/patients/{id} — Suppression patient
  Future<void> deletePatient(dynamic id) async {
    await _dio.delete(ApiConfig.patient(id));
  }

  /// POST /api/patients/{id}/parents — Association parent au patient
  Future<void> addParentToPatient(
    dynamic patientId, {
    required dynamic parentId,
    required String role,
  }) async {
    await _dio.post(
      ApiConfig.patientParents(patientId),
      data: {'parent_id': parentId, 'role': role},
    );
  }

  /// GET /api/patients/{id}/parents — Parents liés au patient
  Future<List<PatientParentModel>> getPatientParents(dynamic patientId) async {
    final response = await _dio.get(ApiConfig.patientParents(patientId));
    final list = response.data as List<dynamic>;
    return list
        .map((e) => PatientParentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// PUT /api/patients/{id}/statut — Changer statut actif/inactif
  Future<void> updateStatut(dynamic id, {required bool estActif}) async {
    await _dio.put(
      ApiConfig.patientStatut(id),
      data: {'est_actif': estActif},
    );
  }

  /// GET /api/patients/{id}/statut-historique — Historique des statuts
  Future<List<PatientStatutHistoriqueModel>> getStatutHistorique(
      dynamic patientId) async {
    final response =
        await _dio.get(ApiConfig.patientStatutHistorique(patientId));
    final list = response.data as List<dynamic>;
    return list
        .map((e) => PatientStatutHistoriqueModel.fromJson(
            e as Map<String, dynamic>))
        .toList();
  }

  /// PUT /api/patients/{id}/statut-historique/{itemId} — Édition note_degradation
  Future<void> updateStatutHistoriqueNote(
    dynamic patientId,
    dynamic itemId, {
    required String noteDegradation,
  }) async {
    await _dio.put(
      ApiConfig.patientStatutHistoriqueItem(patientId, itemId),
      data: {'note_degradation': noteDegradation},
    );
  }

  /// GET /api/patients/{id}/dossier-medical — Dossier médical
  Future<DossierMedicalModel> getDossierMedical(dynamic patientId) async {
    final response =
        await _dio.get(ApiConfig.patientDossierMedical(patientId));
    return DossierMedicalModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// PATCH /api/patients/{id}/dossier-medical — Mise à jour dossier médical
  Future<DossierMedicalModel> updateDossierMedical(
    dynamic patientId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch(
      ApiConfig.patientDossierMedical(patientId),
      data: data,
    );
    return DossierMedicalModel.fromJson(
        response.data as Map<String, dynamic>);
  }
}
