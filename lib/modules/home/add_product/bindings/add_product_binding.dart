import 'package:crud_getx_demo/modules/home/add_product/controllers/add_product_controller.dart';
import 'package:get/get.dart';

class AddProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddProductController>(
      () => AddProductController(productRepos: Get.find()),
    );
  }
}
