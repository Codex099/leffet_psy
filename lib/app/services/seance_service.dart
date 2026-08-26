import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/seance_model.dart';
import 'dio_client.dart';

class SeanceService {
  final Dio _dio = DioClient.instance;

  /// GET /api/seances — Liste des séances (avec filtres optionnels)
  Future<List<SeanceModel>> getSeances({
    String? date,
    dynamic patientId,
    dynamic employeId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (date != null) queryParams['date'] = date;
    if (patientId != null) queryParams['patient_id'] = patientId;
    if (employeId != null) queryParams['employe_id'] = employeId;

    final response = await _dio.get(
      ApiConfig.seances,
      queryParameters: queryParams,
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => SeanceModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// POST /api/seances — Création d'une séance
  Future<SeanceModel> createSeance(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConfig.seances, data: data);
    return SeanceModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  /// GET /api/seances/{id} — Détail séance
  Future<SeanceModel> getSeance(dynamic id) async {
    final response = await _dio.get(ApiConfig.seance(id));
    return SeanceModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  /// PUT /api/seances/{id} — Mise à jour séance (compte-rendu)
  Future<SeanceModel> updateSeance(dynamic id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConfig.seance(id), data: data);
    return SeanceModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  /// DELETE /api/seances/{id}
  Future<void> deleteSeance(dynamic id) async {
    await _dio.delete(ApiConfig.seance(id));
  }
}

class PlanningRecurrentService {
  final Dio _dio = DioClient.instance;

  /// GET /api/patients/{id}/planning-recurrent
  Future<PatientPlanningRecurrentModel?> getPlanningRecurrent(
      dynamic patientId) async {
    final response =
        await _dio.get(ApiConfig.patientPlanningRecurrent(patientId));
    if (response.data == null) return null;
    return PatientPlanningRecurrentModel.fromJson(
        Map<String, dynamic>.from(response.data as Map));
  }

  /// POST /api/patients/{id}/planning-recurrent — Créer/modifier planning
  Future<PatientPlanningRecurrentModel> setPlanningRecurrent(
    dynamic patientId,
    Map<String, dynamic> data,
  ) async {
    final now = DateTime.now();
    final todayStr = now.toIso8601String().split('T').first;
    final payload = Map<String, dynamic>.from(data);

    // Champs obligatoires selon le schéma FastAPI
    payload['date_debut'] ??= todayStr;
    payload['mode_generation'] ??= 'auto';
    payload['horizon_jours'] ??= 30;

    final response = await _dio.post(
      ApiConfig.patientPlanningRecurrent(patientId),
      data: payload,
    );
    return PatientPlanningRecurrentModel.fromJson(
        Map<String, dynamic>.from(response.data as Map));
  }

  /// POST /api/patients/{id}/planning-recurrent/generer — Génération manuelle
  Future<void> genererSeances(
    dynamic patientId, {
    String? dateDebut,
    String? dateFin,
  }) async {
    final now = DateTime.now();
    final dDebut = dateDebut ?? now.toIso8601String().split('T').first;
    final dFin = dateFin ??
        now.add(const Duration(days: 30)).toIso8601String().split('T').first;

    await _dio.post(
      ApiConfig.patientPlanningRecurrentGenerer(patientId),
      data: {
        'date_debut': dDebut,
        'date_fin': dFin,
      },
    );
  }
}
