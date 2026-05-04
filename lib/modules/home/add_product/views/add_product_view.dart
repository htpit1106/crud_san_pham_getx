import 'package:crud_getx_demo/core/utils/validator_utils.dart';
import 'package:crud_getx_demo/core/widget/button/app_dropdown_button_form_field.dart';
import 'package:crud_getx_demo/core/widget/button/app_text_field.dart';
import 'package:crud_getx_demo/data/model/entities/category_entity.dart';
import 'package:crud_getx_demo/data/model/entities/product_entity.dart';
import 'package:crud_getx_demo/modules/home/add_product/controllers/add_product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProductView extends GetView<AddProductController> {
  final ProductEntity? productEntity;
  const AddProductView({super.key, this.productEntity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const Row(
            children: [
              Icon(Icons.inventory_2_outlined),
              SizedBox(width: 8),
              Text(
                'Thêm sản phẩm',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              controller: controller.scrollController,
              children: [
                _buildRequiredTextField(
                  controller: controller.nameController,
                  label: 'Tên sản phẩm',
                  hint: 'Nhập tên sản phẩm',
                ),

                const SizedBox(height: 12),
                _buildRequiredTextField(
                  controller: controller.codeController,
                  label: 'Mã sản phẩm (SKU)',
                  hint: 'VD: SKU-0001',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildRequiredTextField(
                        controller: controller.priceController,
                        label: 'Giá',
                        hint: '0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildRequiredTextField(
                        controller: controller.stockController,
                        label: 'Tồn kho',
                        hint: '0',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() {
                  final categoryItems = _buildDistinctCategoryItems(
                    controller.categories,
                  );

                  final selectedCategory = _resolveCategoryValue(
                    currentValue: controller.selectedCategory.value,
                    items: categoryItems,
                  );

                  return AppDropdownButtonFormField(
                    value: selectedCategory,
                    labelText: 'Danh mục',
                    hintText: 'Chọn danh mục',
                    items: categoryItems,
                    onChanged: (value) {
                      controller.onChangeCategory(value);
                    },
                  );
                }),

                const SizedBox(height: 12),
                AppDropdownButtonFormField(
                  value: controller.selectedStatus.value,
                  labelText: 'Trạng thái',
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Kích hoạt')),
                    DropdownMenuItem(value: 0, child: Text('Vô hiệu hóa')),
                  ],
                  onChanged: (value) {
                    // _cubit.onChangeStatus(value);
                  },
                ),
                const SizedBox(height: 12),
                _buildRequiredTextField(
                  controller: controller.descriptionController,
                  label: 'Mô tả',
                  hint: 'Nhập mô tả sản phẩm',
                  minLines: 4,
                  maxLines: 6,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Huỷ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (controller.product != null) {
                      await controller.updateProduct();
                    } else {
                      await controller.addProduct();
                    }
                  },
                  child: const Text('Lưu'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredTextField({
    required String label,
    required String hint,
    TextInputType? keyboardType,
    Function(String?)? validator,
    TextEditingController? controller,
    FocusNode? focusNode,
    int? maxLines = 1,
    int? minLines,
  }) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      labelText: label,
      hintText: hint,
      validator: (value) =>
          validator?.call(value) ??
          ValidatorUtils.validateRequiredField(value, title: label),

      textInputAction: TextInputAction.next,
      maxLines: maxLines,
      keyboardType: keyboardType,
      minLines: minLines ?? 1,
    );
  }

  List<DropdownMenuItem<CategoryEntity?>> _buildDistinctCategoryItems(
    List<CategoryEntity>? categories,
  ) {
    final source = categories ?? const <CategoryEntity>[];
    final items = <DropdownMenuItem<CategoryEntity?>>[];
    final seen = <int?>{};

    for (final category in source) {
      final id = category.id;
      if (seen.contains(id)) continue;
      seen.add(id);
      items.add(
        DropdownMenuItem<CategoryEntity?>(
          value: category,
          child: Text(category.name ?? ''),
        ),
      );
    }

    return items;
  }

  CategoryEntity? _resolveCategoryValue({
    required CategoryEntity? currentValue,
    required List<DropdownMenuItem<CategoryEntity?>> items,
  }) {
    if (currentValue == null) return null;

    try {
      return items
          .map((e) => e.value)
          .firstWhere((item) => item?.id == currentValue.id);
    } catch (e) {
      return null;
    }
  }
}
