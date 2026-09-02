import 'dart:io';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'dio_client.dart';

class UploadService {
  final Dio _dio = DioClient.instance;

  /// POST /api/uploads — Upload un fichier photo/vidéo et retourne l'URL distante accessible.
  Future<String> uploadFile(
    File file, {
    ProgressCallback? onSendProgress,
  }) async {
    final fileName = file.path.split(RegExp(r'[\\/]')).last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _dio.post(
      ApiConfig.uploads,
      data: formData,
      onSendProgress: onSendProgress,
    );

    final data = Map<String, dynamic>.from(response.data as Map);
    final raw = data['url'] as String? ?? data['path'] as String? ?? '';
    return ApiConfig.resolveMediaUrl(raw);
  }
}
