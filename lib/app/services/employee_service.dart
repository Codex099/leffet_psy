import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/employee_model.dart';
import 'dio_client.dart';

class EmployeeService {
 final Dio _dio = DioClient.instance;

  /// GET /api/employees — Liste des employés (admin)
  Future<List<EmployeeModel>> getEmployees({String? search}) async {
    final queryParams = <String, dynamic>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

   final response = await _dio.get(
      ApiConfig.employees,
      queryParameters: queryParams,
    );
    final list = response.data as List<dynamic>;
    return list
        .map((e) => EmployeeModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// POST /api/employees — Création (admin)
  Future<EmployeeModel> createEmployee(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConfig.employees, data: data);
    return EmployeeModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  /// GET /api/employees/{id}
  Future<EmployeeModel> getEmployee(dynamic id) async {
    final response = await _dio.get(ApiConfig.employee(id));
    return EmployeeModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  /// PUT /api/employees/{id}
  Future<EmployeeModel> updateEmployee(
      dynamic id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConfig.employee(id), data: data);
    return EmployeeModel.fromJson(Map<String, dynamic>.from(response.data as Map));
  }

  /// DELETE /api/employees/{id}
  Future<void> deleteEmployee(dynamic id) async {
    await _dio.delete(ApiConfig.employee(id));
  }

  /// POST /api/employees/{id}/patients — Assignation / synchronisation des patients
  Future<void> assignPatients(dynamic employeeId, List<dynamic> patientIds) async {
    await _dio.post(
      ApiConfig.employeePatients(employeeId),
      data: {'patient_ids': patientIds.map((e) => e.toString()).toList()},
    );
  }

  /// GET /api/employees/{id}/visibilite-patients — Détails visibilité (Admin)
  Future<Map<String, dynamic>> getVisibilitePatients(dynamic employeeId) async {
    final response = await _dio.get(
      ApiConfig.employeeVisibilitePatients(employeeId),
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  /// POST /api/employees/visibilite-globale — Accorder ou révoquer la visibilité globale (Admin)
  Future<Map<String, dynamic>> applyGlobalVisibility(
    String action, {
    List<dynamic>? employeeIds,
  }) async {
    final response = await _dio.post(
      ApiConfig.employeesVisibiliteGlobale,
      data: {
        'action': action,
        if (employeeIds != null)
          'employee_ids': employeeIds.map((e) => e.toString()).toList(),
      },
    );
    return Map<String, dynamic>.from(response.data as Map);
  }
}
