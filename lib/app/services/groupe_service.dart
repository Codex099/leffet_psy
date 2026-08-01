import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/groupe_model.dart';
import 'dio_client.dart';

class GroupeService {
  final Dio _dio = DioClient.instance;

  /// GET /api/groupes — Liste des groupes
  Future<List<GroupeModel>> getGroupes({String? search}) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _dio.get(
      ApiConfig.groupes,
      queryParameters: queryParams,
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => GroupeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/groupes — Création d'un groupe
  Future<GroupeModel> createGroupe(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConfig.groupes, data: data);
    return GroupeModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/groupes/{id} — Détail groupe
  Future<GroupeModel> getGroupe(int id) async {
    final response = await _dio.get(ApiConfig.groupe(id));
    return GroupeModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// PUT /api/groupes/{id} — Mise à jour groupe
  Future<GroupeModel> updateGroupe(int id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConfig.groupe(id), data: data);
    return GroupeModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/groupes/{id} — Suppression groupe
  Future<void> deleteGroupe(int id) async {
    await _dio.delete(ApiConfig.groupe(id));
  }

  /// POST /api/groupes/{id}/planning-recurrent — Définir le planning fixe
  Future<GroupePlanningRecurrentModel> setPlanningRecurrent(
    int groupeId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(
      ApiConfig.groupePlanningRecurrent(groupeId),
      data: data,
    );
    return GroupePlanningRecurrentModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// POST /api/groupes/{id}/patients — Ajouter un patient au groupe
  Future<void> addPatientToGroupe(int groupeId, int patientId) async {
    await _dio.post(
      ApiConfig.groupePatients(groupeId),
      data: {'patient_id': patientId},
    );
  }

  /// DELETE patient from groupe
  Future<void> removePatientFromGroupe(int groupeId, int patientId) async {
    await _dio.delete(
      '${ApiConfig.groupePatients(groupeId)}/$patientId',
    );
  }
}
