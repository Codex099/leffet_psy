import 'package:get/get.dart';
import '../models/employee_model.dart';
import '../services/employee_service.dart';

class EmployesListeController extends GetxController {
  final EmployeeService _employeeService = EmployeeService();

  final RxList<EmployeeModel> employees = <EmployeeModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    try {
      status.value = 'loading';
      final list = await _employeeService.getEmployees(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      employees.value = list;
      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  void search(String query) {
    searchQuery.value = query;
    loadEmployees();
  }
}