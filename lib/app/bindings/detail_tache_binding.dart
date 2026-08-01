import 'package:get/get.dart';
import '../controllers/detail_tache_controller.dart';

class DetailTacheBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetailTacheController>(() => DetailTacheController());
  }
}
