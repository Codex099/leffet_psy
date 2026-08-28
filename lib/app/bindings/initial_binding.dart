import 'package:get/get.dart';
import '../controllers/accueil_controller.dart';
import '../controllers/agenda_controller.dart';
import '../controllers/patients_liste_controller.dart';
import '../controllers/profil_controller.dart';
import '../services/auth_service.dart';

/// Initial binding configurant les services et contrôleurs vitaux
/// en mode permanent/fenix pour assurer un temps de réponse instantané (0ms).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services centraux
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);

    // Contrôleurs des 4 onglets principaux préservés en mémoire
    Get.lazyPut<AccueilController>(() => AccueilController(), fenix: true);
    Get.lazyPut<PatientsListeController>(() => PatientsListeController(), fenix: true);
    Get.lazyPut<AgendaController>(() => AgendaController(), fenix: true);
    Get.lazyPut<ProfilController>(() => ProfilController(), fenix: true);
  }
}
