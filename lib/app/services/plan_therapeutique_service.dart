import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/plan_therapeutique_model.dart';
import 'dio_client.dart';

class PlanTherapeutiqueService {
  final Dio _dio = DioClient.instance;

  /// GET /api/patients/{id}/plans-therapeutiques
  Future<List<PlanTherapeutiqueModel>> getPlansPatient(dynamic patientId) async {
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
    dynamic patientId,
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
  Future<PlanTherapeutiqueModel> getPlan(dynamic planId) async {
    final response =
        await _dio.get(ApiConfig.planTherapeutique(planId));
    return PlanTherapeutiqueModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// PUT /api/plans-therapeutiques/{plan_id}
  Future<PlanTherapeutiqueModel> updatePlan(
    dynamic planId,
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
  Future<void> deletePlan(dynamic planId) async {
    await _dio.delete(ApiConfig.planTherapeutique(planId));
  }

  /// GET /api/plans-therapeutiques/{plan_id}/etapes
  Future<List<EtapePlanTherapeutiqueModel>> getEtapes(dynamic planId) async {
    final response = await _dio.get(ApiConfig.planEtapes(planId));
    final list = response.data as List<dynamic>;
    return list
        .map((e) => EtapePlanTherapeutiqueModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/plans-therapeutiques/{plan_id}/etapes
  Future<EtapePlanTherapeutiqueModel> createEtape(
    dynamic planId,
    Map<String, dynamic> data,
  ) async {
    final response =
        await _dio.post(ApiConfig.planEtapes(planId), data: data);
    return EtapePlanTherapeutiqueModel.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// PUT /api/plans-therapeutiques/{plan_id}/etapes/{etape_id}
  Future<EtapePlanTherapeutiqueModel> updateEtape(
    dynamic planId,
    dynamic etapeId,
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
  Future<void> deleteEtape(dynamic planId, dynamic etapeId) async {
    await _dio.delete(ApiConfig.planEtape(planId, etapeId));
  }

  /// POST /api/plans-therapeutiques/{plan_id}/etapes/{etape_id}/creer-tache
  Future<Map<String, dynamic>> creerTacheDepuisEtape(
    dynamic planId,
    dynamic etapeId,
  ) async {
    final response =
        await _dio.post(ApiConfig.planEtapeCreerTache(planId, etapeId));
    return response.data as Map<String, dynamic>;
  }
}
