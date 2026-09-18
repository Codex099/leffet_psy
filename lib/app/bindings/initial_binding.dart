import 'package:get/get.dart';
import '../controllers/accueil_controller.dart';
import '../controllers/agenda_controller.dart';
import '../controllers/patients_liste_controller.dart';
import '../controllers/profil_controller.dart';
import '../services/auth_service.dart';

/// Initial binding configurant les services et contrôleurs vitaux.
/// Les 4 onglets principaux sont marqués [permanent: true] pour ne jamais
/// être détruits par GetX, même lors d'un Get.offNamedUntil.
/// Cela garantit que onInit() ne retourne qu'une seule fois → 0 rechargement.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services centraux
    Get.put<AuthService>(AuthService(), permanent: true);

    // Contrôleurs des 4 onglets principaux — enregistrés en lazyPut (fenix: true)
    // pour ne se charger que lorsque l'utilisateur est connecté et accède à la vue
    Get.lazyPut<AccueilController>(() => AccueilController(), fenix: true);
    Get.lazyPut<PatientsListeController>(() => PatientsListeController(), fenix: true);
    Get.lazyPut<AgendaController>(() => AgendaController(), fenix: true);
    Get.lazyPut<ProfilController>(() => ProfilController(), fenix: true);
  }
}
