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

    // Contrôleurs des 4 onglets principaux — permanent = jamais détruit
    Get.put<AccueilController>(AccueilController(), permanent: true);
    Get.put<PatientsListeController>(PatientsListeController(), permanent: true);
    Get.put<AgendaController>(AgendaController(), permanent: true);
    Get.put<ProfilController>(ProfilController(), permanent: true);
  }
}
