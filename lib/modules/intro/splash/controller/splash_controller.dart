import 'package:crud_getx_demo/core/configs/app_configs.dart';
import 'package:crud_getx_demo/core/widget/flushbar/app_notifier.dart';
import 'package:crud_getx_demo/data/database/secure_storage_helper.dart';
import 'package:crud_getx_demo/data/repositories/product_repository.dart';
import 'package:crud_getx_demo/navigator/app_page.dart';
import 'package:crud_getx_demo/navigator/app_routes.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  DateTime _showTime = DateTime.now();

  @override
  void onInit() {
    autoLogin();
    super.onInit();
  }

  Future<void> autoLogin() async {
    final isLoggedIn = await checkLogin();
    await _ensureSplashSplashTime();
    final authController = Get.find<AuthController>();

    if (isLoggedIn) {
      authController.markAuthenticated();
      Get.offAllNamed(AppRoutes.home);
    } else {
      authController.markUnauthenticated();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Future<bool> checkLogin() async {
    _showTime = DateTime.now();
    final accessToken = await SecureStorageHelper.instance.getToken();
    if (accessToken == null) return false;
    final result = await Get.find<ProductRepository>().getProducts();
    result.fold(
      (failure) {
        AppNotifier.showError(failure.message);
      },
      (response) {
        return true;
      },
    );
    return false;
  }

  Future<void> _ensureSplashSplashTime() async {
    final elapsed = DateTime.now().difference(_showTime);
    const minDuration = AppConfigs.splashMinDisplayTime;
    if (elapsed < minDuration) {
      await Future.delayed(minDuration - elapsed);
    }
  }
}
