import 'package:crud_getx_demo/modules/auth/login/controllers/login_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
   
    Get.lazyPut<LoginController>(
      () => LoginController(authRepository: Get.find()),
    );
  }
}
