import 'dart:async';
import 'package:get/get.dart';
import '../models/groupe_model.dart';
import '../services/groupe_service.dart';

class GroupesListeController extends GetxController {
  final GroupeService _groupeService = GroupeService();

  final RxList<GroupeModel> groupes = <GroupeModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    loadGroupes();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  Future<void> loadGroupes() async {
    try {
      status.value = 'loading';
      final list = await _groupeService.getGroupes(
        search: searchQuery.value.isEmpty ? null : searchQuery.value,
      );
      groupes.value = list;
      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  void search(String query) {
    searchQuery.value = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      loadGroupes();
    });
  }
}