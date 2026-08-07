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
        .map((e) => ParentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/parents — Création d'un parent
  Future<ParentModel> createParent(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConfig.parents, data: data);
    return ParentModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/parents/{id} — Fiche parent
  Future<ParentModel> getParent(dynamic id) async {
    final response = await _dio.get(ApiConfig.parentById(id));
    return ParentModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// PUT /api/parents/{id} — Mise à jour parent
  Future<ParentModel> updateParent(dynamic id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConfig.parentById(id), data: data);
    return ParentModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/parents/{id} — Suppression parent
  Future<void> deleteParent(dynamic id) async {
    await _dio.delete(ApiConfig.parentById(id));
  }
}
