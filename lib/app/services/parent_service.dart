import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/parent_model.dart';
import 'dio_client.dart';

class ParentService {
 final Dio _dio = DioClient.instance;

  /// GET /api/parents — Liste des parents
  Future<List<ParentModel>> getParents({String? search}) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

   final response = await _dio.get(
      ApiConfig.parents,
      queryParameters: queryParams,
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => ParentModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// POST /api/parents — Création d'un parent (ou récupération de l'existant si findExisting = true)
  Future<ParentModel> createParent(
    Map<String, dynamic> data, {
    bool findExisting = true,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.parents,
        data: data,
        queryParameters: findExisting ? {'find_existing': 'true'} : null,
      );
      return ParentModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      if (findExisting && e.response?.statusCode == 409) {
        final phone = data['telephone']?.toString().trim();
        if (phone != null && phone.isNotEmpty) {
          final existing = await getParentByPhone(phone);
          if (existing != null) return existing;
        }
      }
      rethrow;
    }
  }

  /// GET /api/parents/by-phone/{telephone} — Recherche d'un parent par téléphone
  Future<ParentModel?> getParentByPhone(String phone) async {
    try {
      final clean = phone.trim();
      final response = await _dio.get(ApiConfig.parentByPhone(clean));
      return ParentModel.fromJson(Map<String, dynamic>.from(response.data as Map));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      // Fallback recherche query si route spécifique non encore déployée
      final list = await getParents(search: phone.trim());
      for (final p in list) {
        if (p.telephone?.trim() == phone.trim()) return p;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// GET /api/parents/{id}/patients — Liste des enfants/patients rattachés à ce parent
  Future<List<Map<String, dynamic>>> getParentPatients(dynamic parentId) async {
    try {
      final response = await _dio.get(ApiConfig.parentPatients(parentId));
      final list = response.data as List<dynamic>;
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  /// GET /api/parents/{id} — Fiche parent
  Future<ParentModel> getParent(dynamic id) async {
    final response = await _dio.get(ApiConfig.parentById(id));
    return ParentModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  /// PUT /api/parents/{id} — Mise à jour parent
  Future<ParentModel> updateParent(dynamic id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConfig.parentById(id), data: data);
    return ParentModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  /// DELETE /api/parents/{id} — Suppression parent
  Future<void> deleteParent(dynamic id) async {
    await _dio.delete(ApiConfig.parentById(id));
  }
}
