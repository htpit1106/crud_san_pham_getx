import 'package:crud_getx_demo/core/widget/flushbar/app_notifier.dart';
import 'package:crud_getx_demo/data/model/entities/category_entity.dart';
import 'package:crud_getx_demo/data/model/entities/product_entity.dart';
import 'package:crud_getx_demo/data/repositories/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddProductController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  // reactive observables
  final isLoading = false.obs;
  final categories = <CategoryEntity>[].obs;
  final selectedCategory = Rxn<CategoryEntity>();
  final selectedStatus = 1.obs; // 1: active, 0: inactive

  // data
  ProductEntity? product;
  @override
  void onInit() {
    fetchCategories();
    final args = Get.arguments;
    product = args?['product'];
    if (product != null) {
      _fillData(product!);
    }
    super.onInit();
  }

  void _fillData(ProductEntity product) {
    nameController.text = product.name ?? '';
    codeController.text = product.code ?? '';
    descriptionController.text = product.description ?? '';
    priceController.text = product.price?.toString() ?? '';
    stockController.text = product.stock?.toString() ?? '';
    selectedStatus.value = product.status ?? 1;
    selectedCategory.value = product.category;
  }

  // repository
  final ProductRepository productRepos;
  AddProductController({required this.productRepos});
  Future<void> fetchCategories() async {
    final result = await productRepos.getCategories();
    result.fold((failure) {}, (response) {
      // update categories
      categories.assignAll(response.data ?? []);
    });
  }

  void onCategorySelected(CategoryEntity? category) {
    selectedCategory.value = category;
  }

  void onStatusChanged(int? status) {
    if (status != null) {
      selectedStatus.value = status;
    }
  }

  Future<void> addProduct() async {
    if (formKey.currentState?.validate() != true) {
      return;
    }
    final name = nameController.text.trim();
    final code = codeController.text.trim();
    final description = descriptionController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    final stock = int.tryParse(stockController.text.trim()) ?? 0;
    final status = selectedStatus.value;
    final product = ProductEntity(
      id: null,
      name: name,
      code: code,
      description: description,
      price: price,
      stock: stock,
      status: status,
      category: selectedCategory.value,
    );
    final result = await productRepos.createProduct(product);
    result.fold(
      (failure) {
        AppNotifier.showError(failure.message);
      },
      (success) {
        AppNotifier.showSuccess('Thêm sản phẩm thành công');
        Get.back(result: true);
      },
    );
  }

  Future<void> updateProduct() async {
    if (formKey.currentState?.validate() != true) {
      return;
    }
    final name = nameController.text.trim();
    final code = codeController.text.trim();
    final description = descriptionController.text.trim();
    final price = double.tryParse(priceController.text.trim()) ?? 0;
    final stock = int.tryParse(stockController.text.trim()) ?? 0;
    final status = selectedStatus.value;
    final updatedProduct = product?.copyWith(
      name: name,
      code: code,
      description: description,
      price: price,
      stock: stock,
      status: status,
      category: selectedCategory.value,
    );
    if (hasEdit() == false) {
      Get.back();
    }

    // call update API here and handle result
    productRepos.updateProduct(product!.id!, updatedProduct!).then((result) {
      result.fold(
        (failure) {
          AppNotifier.showError(failure.message);
        },
        (success) {
          AppNotifier.showSuccess('Cập nhật sản phẩm thành công');
          Get.back(result: true);
        },
      );
    });
  }

  bool hasEdit() {
    if (product == null) return false;
    return nameController.text.trim() != (product?.name ?? '') ||
        codeController.text.trim() != (product?.code ?? '') ||
        descriptionController.text.trim() != (product?.description ?? '') ||
        priceController.text.trim() != (product?.price?.toString() ?? '') ||
        stockController.text.trim() != (product?.stock?.toString() ?? '') ||
        selectedStatus.value != (product?.status ?? 1) ||
        selectedCategory.value?.id != (product?.category?.id ?? null);
  }

  void onChangeCategory(CategoryEntity? category) {
    selectedCategory.value = category;
  }

  void onChangeStatus(int? status) {
    if (status != null) {
      selectedStatus.value = status;
    }
  }
}
