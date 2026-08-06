import 'dart:async';
import 'package:get/get.dart';
import '../models/parent_model.dart';
import '../services/parent_service.dart';

class ParentsListeController extends GetxController {
  final ParentService _parentService = ParentService();

  final RxList<ParentModel> allParents = <ParentModel>[].obs;
  final RxString status = 'loading'.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    loadParents();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  Future<void> loadParents() async {
    try {
      status.value = 'loading';
      final list = await _parentService.getParents();
      allParents.value = list;
      status.value = list.isEmpty ? 'empty' : 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  List<ParentModel> get filteredParents {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return allParents;
    return allParents.where((p) {
      final name = p.fullName.toLowerCase();
      final tel = (p.telephone ?? '').toLowerCase();
      return name.contains(q) || tel.contains(q);
    }).toList();
  }

  void search(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 200), () {
      searchQuery.value = query;
    });
  }
}