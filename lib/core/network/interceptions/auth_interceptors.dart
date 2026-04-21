import 'package:crud_getx_demo/core/constants/key_constants.dart';
import 'package:crud_getx_demo/data/database/secure_storage_helper.dart';
import 'package:crud_getx_demo/navigator/app_page.dart';
import 'package:crud_getx_demo/navigator/app_routes.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

class AuthInterceptors extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorageHelper.instance.getToken();

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final errorKey = err.response?.data?['error_key'];
    final statusCode = err.response?.statusCode;
    final isInvalidToken =
        statusCode == 401 && errorKey == KeyConstants.errInvalidAccessToken;
    final isWrongAuthHeader =
        statusCode == 400 && errorKey == KeyConstants.errWrongAuthHeader;

    if (isInvalidToken || isWrongAuthHeader) {
      await _forceLogout();
      return handler.next(err);
    }

    handler.next(err);
  }

  Future<void> _forceLogout() async {
    await SecureStorageHelper.instance.clearAccessToken();
    final authController = Get.find<AuthController>();
    authController.markUnauthenticated();

    if (Get.currentRoute != AppRoutes.login) {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
