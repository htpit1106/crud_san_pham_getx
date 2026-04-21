import 'package:crud_getx_demo/modules/home/controllers/home_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () =>
          HomeController(productRepos: Get.find(), authController: Get.find()),
    );
  }
}
