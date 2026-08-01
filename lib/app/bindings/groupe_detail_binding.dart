import 'package:get/get.dart';
import '../controllers/groupe_detail_controller.dart';

class GroupeDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupeDetailController>(() => GroupeDetailController());
  }
}
