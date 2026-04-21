import 'package:crud_getx_demo/core/configs/app_configs.dart';
import 'package:crud_getx_demo/core/network/api_util.dart';
import 'package:crud_getx_demo/core/theme/app_themes.dart';
import 'package:crud_getx_demo/core/utils/utils.dart';
import 'package:crud_getx_demo/data/repositories/auth_repository.dart';
import 'package:crud_getx_demo/data/repositories/product_repository.dart';
import 'package:crud_getx_demo/navigator/app_page.dart';
import 'package:crud_getx_demo/navigator/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/instance_manager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiUtil.apiClient;
    return GestureDetector(
      onTap: () => hideKeyboard(context),
      child: GetMaterialApp(
        title: AppConfigs.appName,
        themeMode: ThemeMode.system,
        darkTheme: AppThemes(isDarkMode: true).theme,
        initialRoute: AppRoutes.splash,
        getPages: [...AppPage.pages],
        initialBinding: BindingsBuilder(() {
          Get.put<AuthController>(AuthController());
          Get.put<ProductRepository>(
            ProductRepositoryImpl(apiClient: apiClient),
            permanent: true,
          );
          Get.put<AuthRepository>(
            AuthRepositoryImpl(apiClient: apiClient),
            permanent: true,
          );
        }),
      ),
    );
  }
}
