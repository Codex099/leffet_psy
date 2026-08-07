import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../services/parent_service.dart';
import '../utils/json_utils.dart';

class EditParentController extends GetxController {
  final ParentService _parentService = ParentService();

  // Mode: création (null) ou édition (id fourni)
  dynamic parentId;

  final nom = ''.obs;
  final prenom = ''.obs;
  final telephone = ''.obs;
  final etatCivil = ''.obs;
  final adresse = ''.obs;
  // Rôle familial — valeurs supportées par le backend
  final role = 'pere'.obs;

  final RxString status = 'success'.obs;
  final RxString errorMessage = ''.obs;

  // Dropdown choices
  static const List<Map<String, String>> roleChoices = [
    {'value': 'pere', 'label': 'Père'},
    {'value': 'mere', 'label': 'Mère'},
    {'value': 'tuteur', 'label': 'Tuteur légal'},
    {'value': 'oncle', 'label': 'Oncle'},
    {'value': 'tante', 'label': 'Tante'},
    {'value': 'grand_pere', 'label': 'Grand-père'},
    {'value': 'grand_mere', 'label': 'Grand-mère'},
    {'value': 'autre', 'label': 'Autre'},
  ];

  @override
  void onInit() {
    super.onInit();
    // If an ID is passed (edit mode), load existing data
    parentId = extractIdParam(Get.arguments, Get.parameters);
    if (parentId != null) {
      _loadParent(parentId!);
    }
  }

  Future<void> _loadParent(dynamic id) async {
    try {
      status.value = 'loading';
      final parent = await _parentService.getParent(id);
      nom.value = parent.nom;
      prenom.value = parent.prenom;
      telephone.value = parent.telephone ?? '';
      etatCivil.value = parent.etatCivil ?? '';
      adresse.value = parent.adresse ?? '';
      status.value = 'success';
    } catch (e) {
      errorMessage.value = e.toString();
      status.value = 'error';
    }
  }

  Future<void> saveParent() async {
    if (nom.value.trim().isEmpty || prenom.value.trim().isEmpty) {
      Get.snackbar(
        'Champs requis',
        'Veuillez renseigner le prénom et le nom du parent.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      status.value = 'loading';
      final data = {
        'nom': nom.value.trim(),
        'prenom': prenom.value.trim(),
        'telephone': telephone.value.trim().isEmpty ? null : telephone.value.trim(),
        'etat_civil': etatCivil.value.trim().isEmpty ? null : etatCivil.value.trim(),
        'adresse': adresse.value.trim().isEmpty ? null : adresse.value.trim(),
        'role': role.value,
      };

      if (parentId != null) {
        await _parentService.updateParent(parentId!, data);
      } else {
        await _parentService.createParent(data);
      }

      status.value = 'success';
      Get.back(result: true);
      Get.snackbar(
        'Succès',
        parentId != null ? 'Parent mis à jour avec succès.' : 'Parent enregistré avec succès.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DioException catch (e) {
      status.value = 'error';
      if (e.response?.statusCode == 409) {
        errorMessage.value = 'Un parent avec ce numéro de téléphone existe déjà.';
      } else {
        errorMessage.value = e.message ?? 'Erreur lors de l\'enregistrement.';
      }
      Get.snackbar(
        'Erreur',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      status.value = 'error';
      errorMessage.value = e.toString();
      Get.snackbar('Erreur', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    }
  }
}