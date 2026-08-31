import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/tache_model.dart';
import 'dio_client.dart';

class TacheService {
 final Dio _dio = DioClient.instance;

  /// GET /api/taches — Liste des tâches
  Future<List<TacheModel>> getTaches({
    bool? assigneesAMoi,
    dynamic patientId,
    String? statut,
  }) async {
    final queryParams = <String, dynamic>{};
    if (assigneesAMoi != null) queryParams['assigne_a_moi'] = assigneesAMoi;
   if (patientId != null) queryParams['patient_id'] = patientId;
   if (statut != null) queryParams['statut'] = statut;

    final response = await _dio.get(
      ApiConfig.taches,
      queryParameters: queryParams,
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TacheModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// POST /api/taches — Création
  Future<TacheModel> createTache(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConfig.taches, data: data);
    return TacheModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  /// GET /api/taches/{id}
  Future<TacheModel> getTache(dynamic id) async {
    final response = await _dio.get(ApiConfig.tache(id));
    return TacheModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  /// PUT /api/taches/{id}
  Future<TacheModel> updateTache(dynamic id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConfig.tache(id), data: data);
    return TacheModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  /// DELETE /api/taches/{id}
  Future<void> deleteTache(dynamic id) async {
    await _dio.delete(ApiConfig.tache(id));
  }
}
