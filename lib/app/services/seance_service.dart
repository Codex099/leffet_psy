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
        .map((e) => SeanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/seances — Création d'une séance
  Future<SeanceModel> createSeance(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConfig.seances, data: data);
    return SeanceModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/seances/{id} — Détail séance
  Future<SeanceModel> getSeance(dynamic id) async {
    final response = await _dio.get(ApiConfig.seance(id));
    return SeanceModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// PUT /api/seances/{id} — Mise à jour séance (compte-rendu)
  Future<SeanceModel> updateSeance(dynamic id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConfig.seance(id), data: data);
    return SeanceModel.fromJson(response.data as Map<String, dynamic>);
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
        response.data as Map<String, dynamic>);
  }

  /// POST /api/patients/{id}/planning-recurrent — Créer/modifier planning
  Future<PatientPlanningRecurrentModel> setPlanningRecurrent(
    dynamic patientId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(
      ApiConfig.patientPlanningRecurrent(patientId),
      data: data,
    );
    return PatientPlanningRecurrentModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// POST /api/patients/{id}/planning-recurrent/generer — Génération manuelle
  Future<void> genererSeances(dynamic patientId) async {
    await _dio.post(ApiConfig.patientPlanningRecurrentGenerer(patientId));
  }
}
