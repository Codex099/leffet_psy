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
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  /// POST /api/patients/{id}/notes
  Future<Map<String, dynamic>> createNote(
    dynamic patientId,
    Map<String, dynamic> data,
  ) async {
    final response =
        await _dio.post(ApiConfig.patientNotes(patientId), data: data);
    return response.data as Map<String, dynamic>;
  }

  /// DELETE /api/notes/{id}
  Future<void> deleteNote(dynamic noteId) async {
    await _dio.delete(ApiConfig.noteById(noteId));
  }
}
