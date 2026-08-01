import 'package:get/get.dart';
import '../models/parent_model.dart';
import '../services/parent_service.dart';

class ParentsListeController extends GetxController {
  final ParentService _parentService = ParentService();

  final RxList<ParentModel> parents = <ParentModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadParents();
  }

  Future<void> loadParents() async {
    try {
      status.value = 'loading';
      final list = await _parentService.getParents(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      parents.value = list;
      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  void search(String query) {
    searchQuery.value = query;
    loadParents();
  }
}