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
        .map((e) => EmployeeModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// POST /api/employees — Création (admin)
  Future<EmployeeModel> createEmployee(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConfig.employees, data: data);
    return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// GET /api/employees/{id}
  Future<EmployeeModel> getEmployee(dynamic id) async {
    final response = await _dio.get(ApiConfig.employee(id));
    return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// PUT /api/employees/{id}
  Future<EmployeeModel> updateEmployee(
      dynamic id, Map<String, dynamic> data) async {
    final response = await _dio.put(ApiConfig.employee(id), data: data);
    return EmployeeModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// DELETE /api/employees/{id}
  Future<void> deleteEmployee(dynamic id) async {
    await _dio.delete(ApiConfig.employee(id));
  }

  /// POST /api/employees/{id}/patients — Assignation de patients
  Future<void> assignPatients(dynamic employeeId, List<dynamic> patientIds) async {
    await _dio.post(
      ApiConfig.employeePatients(employeeId),
      data: {'patient_ids': patientIds},
    );
  }
}
