import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../services/cache_manager.dart';
import '../services/parent_service.dart';
import '../utils/json_utils.dart';

class EditParentController extends GetxController {
 final ParentService _parentService = ParentService();

  // Mode: création (null) ou édition (id fourni)
  dynamic parentId;

  final nom = ''.obs;
  final prenom = ''.obs;
  final telephone = ''.obs;
  final etatCivil = 'Marié(e)'.obs;
  final adresse = ''.obs;
  // Rôle familial — valeurs supportées par le backend
  final role = 'pere'.obs;

  final RxString status = 'success'.obs;
  final RxString errorMessage = ''.obs;

  // Dropdown choices
  static List<Map<String, String>> get etatCivilChoices => [
        {'value': 'Marié(e)', 'label': 'Marié(e)'.tr},
        {'value': 'Célibataire', 'label': 'Célibataire'.tr},
        {'value': 'Divorcé(e)', 'label': 'Divorcé(e)'.tr},
        {'value': 'Veuf(ve)', 'label': 'Veuf(ve)'.tr},
        {'value': 'Séparé(e)', 'label': 'Séparé(e)'.tr},
        {'value': 'Autre', 'label': 'Autre'.tr},
        {'value': 'Non spécifié', 'label': 'Non spécifié'.tr},
      ];

  static List<Map<String, String>> get roleChoices => [
        {'value': 'pere', 'label': 'Père'.tr},
        {'value': 'mere', 'label': 'Mère'.tr},
        {'value': 'tuteur', 'label': 'Tuteur légal'.tr},
        {'value': 'oncle', 'label': 'Oncle'.tr},
        {'value': 'tante', 'label': 'Tante'.tr},
        {'value': 'grand_pere', 'label': 'Grand-père'.tr},
        {'value': 'grand_mere', 'label': 'Grand-mère'.tr},
        {'value': 'autre', 'label': 'Autre'.tr},
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
      if (parent.etatCivil != null && parent.etatCivil!.trim().isNotEmpty) {
        final raw = parent.etatCivil!.trim();
        if (raw == 'Marié' || raw == 'Mariée' || raw == 'Marié(e)') {
          etatCivil.value = 'Marié(e)';
        } else if (raw == 'Célibataire') {
          etatCivil.value = 'Célibataire';
        } else if (raw == 'Divorcé' || raw == 'Divorcée' || raw == 'Divorcé(e)') {
          etatCivil.value = 'Divorcé(e)';
        } else if (raw == 'Veuf' || raw == 'Veuve' || raw == 'Veuf(ve)') {
          etatCivil.value = 'Veuf(ve)';
        } else if (raw == 'Séparé' || raw == 'Séparée' || raw == 'Séparé(e)') {
          etatCivil.value = 'Séparé(e)';
        } else if (raw == 'Autre') {
          etatCivil.value = 'Autre';
        } else if (raw == 'Non spécifié') {
          etatCivil.value = 'Non spécifié';
        } else {
          etatCivil.value = raw;
        }
      } else {
        etatCivil.value = 'Marié(e)';
      }
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

    if (telephone.value.trim().isEmpty) {
      Get.snackbar(
        'Téléphone requis',
       'Veuillez renseigner le numéro de téléphone du parent.',
       snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      status.value = 'loading';
      String mappedEtatCivil = 'autre';
      final rawEc = etatCivil.value.toLowerCase();
      if (rawEc.contains('mari')) {
        mappedEtatCivil = 'marie';
      } else if (rawEc.contains('divorc') || rawEc.contains('spar') || rawEc.contains('sépar')) {
        mappedEtatCivil = 'divorce';
      } else {
        mappedEtatCivil = 'autre';
      }

      final cleanTel = telephone.value.replaceAll(RegExp(r'[\s\-\.]'), '').trim();
      final data = {
        'nom': nom.value.trim(),
        'prenom': prenom.value.trim(),
        'telephone': cleanTel,
        'etat_civil': mappedEtatCivil,
        'adresse': adresse.value.trim().isEmpty ? '' : adresse.value.trim(),
      };

      if (parentId != null) {
        await _parentService.updateParent(parentId!, data);
      } else {
        await _parentService.createParent(data, findExisting: false);
      }

      AppCacheManager.invalidateTag(CacheTags.parents);
      AppCacheManager.invalidateTag(CacheTags.patients);

      status.value = 'success';
      Get.back(result: true);
      Get.snackbar(
        'Succès'.tr,
        parentId != null ? 'Parent mis à jour avec succès.'.tr : 'Parent enregistré avec succès.'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on DioException catch (e) {
      status.value = 'error';
      if (e.response?.statusCode == 409) {
        errorMessage.value = 'Un parent avec ce numéro de téléphone existe déjà.'.tr;
      } else if (e.response?.statusCode == 422) {
        final dynamic detail = e.response?.data?['detail'];
        String msg = 'Veuillez renseigner un numéro de téléphone valide et l\'état civil.'.tr;
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          final field = (first['loc'] as List?)?.last?.toString() ?? '';
          final m = first['msg']?.toString() ?? '';
          if (field.isNotEmpty) {
            msg = 'Champ invalide ($field) : $m'.tr;
          }
        }
        errorMessage.value = msg;
      } else {
        errorMessage.value = e.message ?? 'Erreur lors de l\'enregistrement.'.tr;
      }
      Get.snackbar(
        'Erreur'.tr,
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
