import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/plan_therapeutique_model.dart';
import 'dio_client.dart';

class PlanTherapeutiqueService {
  final Dio _dio = DioClient.instance;

  /// GET /api/patients/{id}/plans-therapeutiques
  Future<List<PlanTherapeutiqueModel>> getPlansPatient(int patientId) async {
    final response =
        await _dio.get(ApiConfig.patientPlansTherapeutiques(patientId));
    final list = response.data as List<dynamic>;
    return list
        .map((e) =>
            PlanTherapeutiqueModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/patients/{id}/plans-therapeutiques
  Future<PlanTherapeutiqueModel> createPlan(
    int patientId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post(
      ApiConfig.patientPlansTherapeutiques(patientId),
      data: data,
    );
    return PlanTherapeutiqueModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// GET /api/plans-therapeutiques/{plan_id}
  Future<PlanTherapeutiqueModel> getPlan(int planId) async {
    final response =
        await _dio.get(ApiConfig.planTherapeutique(planId));
    return PlanTherapeutiqueModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// PUT /api/plans-therapeutiques/{plan_id}
  Future<PlanTherapeutiqueModel> updatePlan(
    int planId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put(
      ApiConfig.planTherapeutique(planId),
      data: data,
    );
    return PlanTherapeutiqueModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// DELETE /api/plans-therapeutiques/{plan_id}
  Future<void> deletePlan(int planId) async {
    await _dio.delete(ApiConfig.planTherapeutique(planId));
  }

  /// POST /api/plans-therapeutiques/{plan_id}/etapes
  Future<EtapePlanTherapeutiqueModel> createEtape(
    int planId,
    Map<String, dynamic> data,
  ) async {
    final response =
        await _dio.post(ApiConfig.planEtapes(planId), data: data);
    return EtapePlanTherapeutiqueModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// PUT /api/plans-therapeutiques/{plan_id}/etapes/{etape_id}
  Future<EtapePlanTherapeutiqueModel> updateEtape(
    int planId,
    int etapeId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.put(
      ApiConfig.planEtape(planId, etapeId),
      data: data,
    );
    return EtapePlanTherapeutiqueModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// DELETE /api/plans-therapeutiques/{plan_id}/etapes/{etape_id}
  Future<void> deleteEtape(int planId, int etapeId) async {
    await _dio.delete(ApiConfig.planEtape(planId, etapeId));
  }

  /// POST /api/plans-therapeutiques/{plan_id}/etapes/{etape_id}/creer-tache
  Future<Map<String, dynamic>> creerTacheDepuisEtape(
    int planId,
    int etapeId,
  ) async {
    final response =
        await _dio.post(ApiConfig.planEtapeCreerTache(planId, etapeId));
    return response.data as Map<String, dynamic>;
  }
}
