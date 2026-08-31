import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/evenement_calendrier_model.dart';
import 'dio_client.dart';

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
            EvenementCalendrierModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// POST /api/calendrier — Création d'un événement (admin)
  Future<EvenementCalendrierModel> createEvenement(
      Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConfig.calendrier, data: data);
    return EvenementCalendrierModel.fromJson(
        Map<String, dynamic>.from(response.data as Map));
  }

  /// PUT /api/calendrier/{id}
  Future<EvenementCalendrierModel> updateEvenement(
      dynamic id, Map<String, dynamic> data) async {
    final response =
        await _dio.put(ApiConfig.evenementCalendrier(id), data: data);
    return EvenementCalendrierModel.fromJson(
        Map<String, dynamic>.from(response.data as Map));
  }

  /// DELETE /api/calendrier/{id}
  Future<void> deleteEvenement(dynamic id) async {
    await _dio.delete(ApiConfig.evenementCalendrier(id));
  }
}
