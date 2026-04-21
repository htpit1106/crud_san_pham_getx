import 'package:crud_getx_demo/core/constants/asset_constants.dart';
import 'package:crud_getx_demo/core/extensions/num_extension.dart';
import 'package:crud_getx_demo/core/utils/validator_utils.dart';
import 'package:crud_getx_demo/core/widget/button/app_icon_text_button.dart';
import 'package:crud_getx_demo/core/widget/button/app_password_text_field.dart';
import 'package:crud_getx_demo/core/widget/button/app_text_field.dart';
import 'package:crud_getx_demo/core/widget/image/app_svg_image.dart';
import 'package:crud_getx_demo/core/widget/textfield/app_text_button.dart';
import 'package:crud_getx_demo/modules/auth/login/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class LoginView extends GetView<LoginController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildGroupButton(),
    );
  }

  Widget _buildBody() {
    return Padding(padding: 16.paddingAll, child: _buildLoginForm());
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      child: AutofillGroup(
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              73.height,
              _buildListInputField(),
              32.height,
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListInputField() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSvgImage(AssetConstants.logoApp),
        Obx(
          () => AppTextField(
            controller: controller.accountController,
            labelText: "Tài khoản",
            hintText: "Tài khoản",
            validator: (value) =>
                ValidatorUtils.validateRequiredField(value, title: "Tài khoản"),

            autovalidateMode: controller.isSubmit.value
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) {
              // FocusScope.of(context).requestFocus(_cubit.passwordFocusNode);
            },
          ),
        ),
        12.height,
        Obx(
          () => AppPasswordTextField(
            controller: controller.passwordController,
            obscureTextController: controller.obscureController,
            labelText: "Mật khẩu",
            hintText: "Mật khẩu",
            validator: (value) => ValidatorUtils.validatePassword(value),
            enableSuffixIcon: true,
            autofillHints: [AutofillHints.password],

            autovalidateMode: controller.isSubmit.value
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            textInputAction: TextInputAction.done,
            onSubmitted: () {
              controller.onSubmit();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGroupButton() {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 21),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        spacing: 8,
        children: [
          AppIconTextButton(),
          AppIconTextButton(iconPath: AssetConstants.facebook, label: "Group"),
          AppIconTextButton(iconPath: AssetConstants.search, label: "Tra cứu"),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return AppTextButton(
      width: double.infinity,
      title: "Đăng nhâp",
      onTap: () {
        controller.onSubmit();
      },
    );
  }
}
