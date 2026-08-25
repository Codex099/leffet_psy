import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/seance_groupe_model.dart';
import 'dio_client.dart';

class SeanceGroupeService {
  final Dio _dio = DioClient.instance;

  /// GET /api/seances-groupe — Liste des séances de groupe
  Future<List<SeanceGroupeModel>> getSeancesGroupe({
    String? date,
    dynamic groupeId,
    dynamic employeId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (date != null) queryParams['date'] = date;
    if (groupeId != null) queryParams['groupe_id'] = groupeId;
    if (employeId != null) queryParams['employe_id'] = employeId;

    final response = await _dio.get(
      ApiConfig.seancesGroupe,
      queryParameters: queryParams,
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => SeanceGroupeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/seances-groupe — Création d'une séance de groupe
  Future<SeanceGroupeModel> createSeanceGroupe(
      Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConfig.seancesGroupe, data: data);
    return SeanceGroupeModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/seances-groupe/{id} — Détail
  Future<SeanceGroupeModel> getSeanceGroupe(dynamic id) async {
    final response = await _dio.get(ApiConfig.seanceGroupe(id));
    return SeanceGroupeModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// PUT /api/seances-groupe/{id} — Mise à jour
  Future<SeanceGroupeModel> updateSeanceGroupe(
      dynamic id, Map<String, dynamic> data) async {
    final response =
        await _dio.put(ApiConfig.seanceGroupe(id), data: data);
    return SeanceGroupeModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/seances-groupe/{id}
  Future<void> deleteSeanceGroupe(dynamic id) async {
    await _dio.delete(ApiConfig.seanceGroupe(id));
  }

  /// PUT /api/seances-groupe/{id}/participants/{patient_id}
  /// Mise à jour de la présence/note d'un participant
  Future<SeanceGroupeParticipantModel> updateParticipant(
    dynamic seanceId,
    dynamic patientId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put(
      ApiConfig.seanceGroupeParticipant(seanceId, patientId),
      data: data,
    );
    return SeanceGroupeParticipantModel.fromJson(
        response.data as Map<String, dynamic>);
  }
}
