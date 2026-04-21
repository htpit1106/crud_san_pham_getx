import 'package:crud_getx_demo/core/widget/button/app_password_text_field.dart';
import 'package:crud_getx_demo/core/widget/flushbar/app_notifier.dart';
import 'package:crud_getx_demo/data/database/secure_storage_helper.dart';
import 'package:crud_getx_demo/data/model/enums/load_status.dart';
import 'package:crud_getx_demo/data/repositories/auth_repository.dart';
import 'package:crud_getx_demo/navigator/app_page.dart';
import 'package:crud_getx_demo/navigator/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final AuthRepository authRepository;
  LoginController({required this.authRepository});

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final accountController = TextEditingController();
  final passwordController = TextEditingController();
  final obscureController = ObscureTextController();
  // state
  final isLoading = LoadStatus.initial.obs;
  final isSubmit = false.obs;

  Future<void> onSubmit() async {
    isSubmit.value = true;
    if (formKey.currentState?.validate() != true) {
      return;
    }
    if (isLoading.value == LoadStatus.loading) return;
    isLoading.value = LoadStatus.loading;
    final result = await authRepository.login(
      accountController.text,
      passwordController.text,
    );
    result.fold(
      (failure) {
        isLoading.value = LoadStatus.failure;
        Get.find<AuthController>().markUnauthenticated();
        AppNotifier.showError(failure.message);
      },
      (response) {
        isLoading.value = LoadStatus.success;
        final token = response.data;
        SecureStorageHelper.instance.saveAccessToken(token?.accessToken);
        Get.find<AuthController>().markAuthenticated();
        Get.offAllNamed(AppRoutes.home);
      },
    );
  }

  @override
  void onClose() {
    accountController.dispose();
    passwordController.dispose();
    obscureController.dispose();
    super.onClose();
  }
}
