import 'dart:convert';
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
    final ext = fileName.contains('.') ? fileName.split('.').last.toLowerCase() : 'jpg';
    final mimeSubtype = (ext == 'png')
        ? 'png'
        : (ext == 'webp')
            ? 'webp'
            : (ext == 'gif')
                ? 'gif'
                : (ext == 'mp4' || ext == 'mov' || ext == 'avi')
                    ? ext
                    : 'jpeg';
    final mimeType = (ext == 'mp4' || ext == 'mov' || ext == 'avi') ? 'video' : 'image';

    DioMediaType? mediaType;
    try {
      mediaType = DioMediaType(mimeType, mimeSubtype);
    } catch (_) {}

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: mediaType,
      ),
    });

    final response = await _dio.post(
      ApiConfig.uploads,
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Accept': '*/*',
        },
      ),
      onSendProgress: onSendProgress,
    );

    dynamic respData = response.data;
    if (respData is String) {
      try {
        respData = jsonDecode(respData);
      } catch (_) {}
    }

    String raw = '';
    if (respData is Map) {
      final map = Map<String, dynamic>.from(respData);
      raw = map['url'] as String? ??
          map['path'] as String? ??
          map['file_url'] as String? ??
          map['photo_url'] as String? ??
          map['photo'] as String? ??
          map['file'] as String? ??
          map['filename'] as String? ??
          '';
      if (raw.isEmpty && map['data'] is Map) {
        final nested = Map<String, dynamic>.from(map['data'] as Map);
        raw = nested['url'] as String? ??
            nested['path'] as String? ??
            nested['file_url'] as String? ??
            nested['photo_url'] as String? ??
            nested['photo'] as String? ??
            '';
      }
    } else if (respData is String && respData.isNotEmpty) {
      raw = respData;
    }

    if (raw.isEmpty) {
      throw Exception('Format de réponse upload invalide: $respData');
    }

    return ApiConfig.resolveMediaUrl(raw);
  }
}
