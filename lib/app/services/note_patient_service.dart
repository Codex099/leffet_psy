import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'dio_client.dart';

class NoteService {
  final Dio _dio = DioClient.instance;

  /// GET /api/patients/{id}/notes
  Future<List<Map<String, dynamic>>> getNotes(dynamic patientId) async {
    final response =
        await _dio.get(ApiConfig.patientNotes(patientId));
    return (response.data as List<dynamic>)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// POST /api/patients/{id}/notes
  Future<Map<String, dynamic>> createNote(
    dynamic patientId,
    Map<String, dynamic> data,
  ) async {
    final response =
        await _dio.post(ApiConfig.patientNotes(patientId), data: data);
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// DELETE /api/notes/{id}
  Future<void> deleteNote(dynamic noteId) async {
    await _dio.delete(ApiConfig.noteById(noteId));
  }
}
