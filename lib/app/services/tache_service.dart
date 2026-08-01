import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/tache_model.dart';
import '../models/evenement_calendrier_model.dart';
import 'dio_client.dart';

class TacheService {
  final Dio _dio = DioClient.instance;

  /// GET /api/taches — Liste des tâches
  Future<List<TacheModel>> getTaches({
    bool? assigneesAMoi,
    int? patientId,
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
        .map((e) => TacheModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/taches — Création
  Future<TacheModel> createTache(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConfig.taches, data: data);
    return TacheModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/taches/{id}
  Future<TacheModel> getTache(int id) async {
    final response = await _dio.get(ApiConfig.tache(id));
    return TacheModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// PUT /api/taches/{id}
  Future<TacheModel> updateTache(int id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConfig.tache(id), data: data);
    return TacheModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/taches/{id}
  Future<void> deleteTache(int id) async {
    await _dio.delete(ApiConfig.tache(id));
  }
}

class CalendrierService {
  final Dio _dio = DioClient.instance;

  /// GET /api/calendrier — Liste des événements
  Future<List<EvenementCalendrierModel>> getEvenements({
    String? dateDebut,
    String? dateFin,
  }) async {
    final queryParams = <String, dynamic>{};
    if (dateDebut != null) queryParams['date_debut'] = dateDebut;
    if (dateFin != null) queryParams['date_fin'] = dateFin;

    final response = await _dio.get(
      ApiConfig.calendrier,
      queryParameters: queryParams,
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) =>
            EvenementCalendrierModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/calendrier — Création d'un événement (admin)
  Future<EvenementCalendrierModel> createEvenement(
      Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConfig.calendrier, data: data);
    return EvenementCalendrierModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// PUT /api/calendrier/{id}
  Future<EvenementCalendrierModel> updateEvenement(
      int id, Map<String, dynamic> data) async {
    final response =
        await _dio.put(ApiConfig.evenementCalendrier(id), data: data);
    return EvenementCalendrierModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// DELETE /api/calendrier/{id}
  Future<void> deleteEvenement(int id) async {
    await _dio.delete(ApiConfig.evenementCalendrier(id));
  }
}
