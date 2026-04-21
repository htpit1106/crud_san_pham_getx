import 'package:crud_getx_demo/modules/auth/login/bindings/login_binding.dart';
import 'package:crud_getx_demo/modules/auth/login/views/login_view.dart';
import 'package:crud_getx_demo/modules/home/add_product/bindings/add_product_binding.dart';
import 'package:crud_getx_demo/modules/home/add_product/views/add_product_view.dart';
import 'package:crud_getx_demo/modules/home/bindings/home_binding.dart';
import 'package:crud_getx_demo/modules/home/views/home_view.dart';
import 'package:crud_getx_demo/modules/intro/splash/bindings/splash_binding.dart';
import 'package:crud_getx_demo/modules/intro/splash/view/splash_view.dart';
import 'package:crud_getx_demo/navigator/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum AuthStatus { authenticated, unauthenticated, unknown }

class AuthController extends GetxController {
  final authStatus = AuthStatus.unknown.obs;
  void markAuthenticated() => authStatus.value = AuthStatus.authenticated;
  void markUnauthenticated() => authStatus.value = AuthStatus.unauthenticated;
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final auth = Get.find<AuthController>();
    final status = auth.authStatus.value;

    if (status == AuthStatus.unknown) {
      if (route == AppRoutes.splash) return null;
      return const RouteSettings(name: AppRoutes.splash);
    } else if (status == AuthStatus.unauthenticated) {
      if (route == AppRoutes.login) return null;
      return const RouteSettings(name: AppRoutes.login);
    } else if (status == AuthStatus.authenticated) {
      if (route == AppRoutes.login || route == AppRoutes.splash) {
        return const RouteSettings(name: AppRoutes.home);
      }
      return null;
    }

    return null;
  }
}

class AppPage {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => SplashView(),
      binding: SplashBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginView(),
      binding: LoginBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => HomeView(),
      middlewares: [AuthMiddleware()],
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.addProduct,
      page: () => AddProductView(),
      middlewares: [AuthMiddleware()],
      binding: AddProductBinding(),

    ),
  ];
}
