import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../config/api_config.dart';
import 'dio_client.dart';

/// Service d'upload de fichiers médias.
///
/// Stratégie :
///   1. Compression  → images compressées avant upload (économise ~80% d'espace)
///   2. Upload direct → Cloudinary (CDN mondial, contourne limite 4.5 MB Vercel)
///   3. Fallback      → POST /api/uploads via Vercel (si Cloudinary échoue)
class UploadService {
  final dio.Dio _dio = DioClient.instance;

  // Cloudinary upload utilise son propre client Dio (sans auth JWT)
  final dio.Dio _cloudinaryDio = dio.Dio(dio.BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 120),
  ));

  // Extensions autorisées (aligné avec le backend)
  static const _allowedExts = {
    'jpg', 'jpeg', 'png', 'gif', 'webp',
    'mp4', 'mov', 'avi', 'pdf',
  };

  /// Upload un fichier et retourne son URL publique permanente.
  ///
  /// [file]           — fichier local à uploader
  /// [onSendProgress] — callback de progression (count, total en octets)
  Future<String> uploadFile(
    File file, {
    void Function(int count, int total)? onSendProgress,
  }) async {
    final fileName = file.path.split(RegExp(r'[\\/]')).last;
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'jpg';

    if (!_allowedExts.contains(ext)) {
      throw Exception(
        'Extension non autorisée : .$ext\n'
        'Extensions acceptées : ${_allowedExts.join(', ')}',
      );
    }

    // ── 1. Compression (images uniquement) ──────────────────────────────────
    final fileToUpload = await _compressIfNeeded(file, ext);

    // ── 2. Upload direct vers Cloudinary ────────────────────────────────────
    try {
      return await _uploadToCloudinary(fileToUpload, fileName, ext,
          onSendProgress: onSendProgress);
    } on Exception {
      // Fallback → Vercel /api/uploads
      return await _uploadToVercel(fileToUpload, fileName, ext,
          onSendProgress: onSendProgress);
    }
  }

  // ── Compression ─────────────────────────────────────────────────────────────
  /// Compresse les images avant upload. Vidéos et PDFs sont ignorés.
  /// Résultat typique : photo iPhone 6 MB → 300-600 KB (qualité visuelle intacte).
  static const _imageExts = {'jpg', 'jpeg', 'png', 'webp'};
  static const _compressQuality = 85;   // 85% — bon compromis qualité/poids
  static const _compressMaxDim = 1920;  // max 1920px sur le grand côté

  Future<File> _compressIfNeeded(File file, String ext) async {
    if (!_imageExts.contains(ext)) return file; // vidéo/PDF → pas de compression

    final originalSize = await file.length();
    if (originalSize < 300 * 1024) return file; // déjà < 300 KB → inutile

    final targetFormat = switch (ext) {
      'png'  => CompressFormat.png,
      'webp' => CompressFormat.webp,
      _      => CompressFormat.jpeg,
    };

    final compressed = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: _compressQuality,
      minWidth: _compressMaxDim,
      minHeight: _compressMaxDim,
      format: targetFormat,
    );

    if (compressed == null || compressed.length >= originalSize) return file;

    // Sauvegarde dans un fichier temporaire
    final tmpPath =
        '${file.parent.path}/compressed_${file.uri.pathSegments.last}';
    final tmpFile = File(tmpPath);
    await tmpFile.writeAsBytes(compressed);
    return tmpFile;
  }

  // ── Upload Cloudinary ───────────────────────────────────────────────────────
  Future<String> _uploadToCloudinary(
    File file,
    String fileName,
    String ext, {
    void Function(int count, int total)? onSendProgress,
  }) async {
    final formData = dio.FormData.fromMap({
      'file': await dio.MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: dio.DioMediaType.parse(_contentType(ext)),
      ),
      'upload_preset': ApiConfig.cloudinaryUploadPreset,
    });

    final response = await _cloudinaryDio.post(
      ApiConfig.cloudinaryUploadUrl,
      data: formData,
      onSendProgress: onSendProgress,
    );

    final data = response.data;
    final url = (data is Map)
        ? (data['secure_url'] ?? data['url'] ?? '').toString()
        : '';

    if (url.isEmpty) {
      throw Exception('Cloudinary : réponse invalide — $data');
    }

    return url;
  }

  // ── Fallback : upload via Vercel /api/uploads ───────────────────────────────
  Future<String> _uploadToVercel(
    File file,
    String fileName,
    String ext, {
    void Function(int count, int total)? onSendProgress,
  }) async {
    final mimeType = _mimeType(ext);
    dio.DioMediaType? mediaType;
    try {
      mediaType = dio.DioMediaType(mimeType.$1, mimeType.$2);
    } catch (_) {}

    final formData = dio.FormData.fromMap({
      'file': await dio.MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: mediaType,
      ),
    });

    final response = await _dio.post(
      ApiConfig.uploads,
      data: formData,
      options: dio.Options(
        contentType: 'multipart/form-data',
        headers: {'Accept': '*/*'},
      ),
      onSendProgress: onSendProgress,
    );

    final data = response.data;
    final raw = (data is Map)
        ? (data['url'] ?? data['path'] ?? data['photo_url'] ?? '').toString()
        : data?.toString() ?? '';

    if (raw.isEmpty) {
      throw Exception('Format de réponse upload invalide : $data');
    }

    return ApiConfig.resolveMediaUrl(raw);
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static String _contentType(String ext) {
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png'           => 'image/png',
      'gif'           => 'image/gif',
      'webp'          => 'image/webp',
      'pdf'           => 'application/pdf',
      'mp4'           => 'video/mp4',
      'mov'           => 'video/quicktime',
      'avi'           => 'video/x-msvideo',
      _               => 'application/octet-stream',
    };
  }

  static (String, String) _mimeType(String ext) {
    return switch (ext) {
      'mp4' || 'mov' || 'avi' => ('video', ext),
      'pdf'                   => ('application', 'pdf'),
      'png'                   => ('image', 'png'),
      'gif'                   => ('image', 'gif'),
      'webp'                  => ('image', 'webp'),
      _                       => ('image', 'jpeg'),
    };
  }
}
