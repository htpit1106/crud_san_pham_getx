import 'dart:async';

import 'package:crud_getx_demo/core/widget/dialogs/app_dialog.dart';
import 'package:crud_getx_demo/core/widget/flushbar/app_notifier.dart';
import 'package:crud_getx_demo/data/database/secure_storage_helper.dart';
import 'package:crud_getx_demo/data/model/entities/category_entity.dart';
import 'package:crud_getx_demo/data/model/entities/product_entity.dart';
import 'package:crud_getx_demo/data/model/enums/load_status.dart';
import 'package:crud_getx_demo/data/model/enums/product_sort_filter.dart';
import 'package:crud_getx_demo/data/model/enums/product_status_filter.dart';
import 'package:crud_getx_demo/data/repositories/product_repository.dart';
import 'package:crud_getx_demo/navigator/app_page.dart';
import 'package:crud_getx_demo/navigator/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ProductRepository productRepos;
  final AuthController authController;
  HomeController({required this.productRepos, required this.authController});

  final loadProductStatus = LoadStatus.initial.obs;
  final searchKeyword = ''.obs;
  final isRefreshing = false.obs;
  final currentPage = 1.obs;
  final hasMore = true.obs;
  final pageSize = 5.obs;
  final products = <ProductEntity>[].obs;
  final categories = <CategoryEntity>[].obs;
  final selectedActive = ProductStatusFilter.active.obs;
  final selectedSort = ProductSortOption.latest.obs;
  final selectedCategoryId = Rxn<int>();

  // controller
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // private
  Timer? _categoryDebounce;
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    init();
  }

  Future<void> init() async {
    fetchCategories();
    await fetchProducts(reset: true);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    searchController.dispose();
    _categoryDebounce?.cancel();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> fetchCategories() async {
    final result = await productRepos.getCategories();
    result.fold((failure) {}, (response) {
      // update categories
      categories.assignAll(response.data ?? []);
    });
  }

  Future<void> fetchProducts({bool reset = false}) async {
    if (loadProductStatus.value.isLoading ||
        loadProductStatus.value.isLoadingMore) {
      return;
    }

    if (!reset && !hasMore.value) return;

    loadProductStatus.value = reset
        ? LoadStatus.loading
        : LoadStatus.loadingMore;

    if (reset) {
      currentPage.value = 1;
      hasMore.value = true;

      products.clear();
    }

    final nextPage = reset ? 1 : currentPage.value;
    final result = await productRepos.getProducts(
      page: nextPage,
      keyword: searchKeyword.value,
      categoryId: selectedCategoryId.value,
      limit: pageSize.value,
    );
    result.fold(
      (failure) {
        loadProductStatus.value = LoadStatus.failure;
        AppNotifier.showError(failure.message);
      },
      (response) {
        // sort product by status
        final fetched = response.data ?? [];
        hasMore.value = fetched.isNotEmpty;
        final merged = reset ? fetched : [...products, ...fetched];
        // sort Products by  sort options
        final sorted = _sortProducts(
          products: merged,
          option: selectedSort.value,
        );
        products.assignAll(sorted ?? []);
        currentPage.value = nextPage + 1;

        loadProductStatus.value = LoadStatus.success;
      },
    );
  }

  List<ProductEntity>? _sortProducts({
    required List<ProductEntity> products,
    required ProductSortOption option,
  }) {
    final cloned = [...products];
    cloned.sort((a, b) {
      switch (option) {
        case ProductSortOption.nameAsc:
          return ((a.name ?? '').toLowerCase().compareTo(
            (b.name ?? '').toLowerCase(),
          ));

        case ProductSortOption.nameDesc:
          return (b.name ?? '').toLowerCase().compareTo(
            (a.name ?? '').toLowerCase(),
          );
        case ProductSortOption.priceAsc:
          return (a.price ?? 0).compareTo(b.price ?? 0);
        case ProductSortOption.priceDesc:
          return (b.price ?? 0).compareTo(a.price ?? 0);
        case ProductSortOption.stockAsc:
          return (a.stock ?? 0).compareTo(b.stock ?? 0);
        case ProductSortOption.stockDesc:
          return (b.stock ?? 0).compareTo(a.stock ?? 0);
        case ProductSortOption.latest:
          return (b.updatedAt ?? DateTime(1970)).compareTo(
            a.updatedAt ?? DateTime(1970),
          );
      }
    });
    return cloned;
  }

  void onStatusFilterChanged(ProductStatusFilter? filter) {
    if (filter == null) return;
    selectedActive.value = filter;
    fetchProducts(reset: true);
  }

  void onSortOptionChanged(ProductSortOption? option) {
    if (option == null) return;
    selectedSort.value = option;
    products.assignAll(
      _sortProducts(products: products, option: selectedSort.value) ?? [],
    );
  }

  void onCategoryChange(int? categoryId) {
    if (categoryId == selectedCategoryId.value) return;
    selectedCategoryId.value = categoryId;
    _categoryDebounce?.cancel();
    _categoryDebounce = Timer(const Duration(milliseconds: 150), () {
      fetchProducts(reset: true);
    });
  }

  Future<void> onPressDeleted(int id) async {
    AppDialog.show(
      message: 'Bạn có chắc chắn muốn xóa sản phẩm này không?',
      textConfirm: 'Xóa',
      textCancel: 'Hủy',
      onCancel: () => AppDialog.hide(),
      onConfirm: () async {
        final result = await productRepos.deleteProduct(id);
        result.fold(
          (failure) {
            AppNotifier.showError(failure.message);
          },
          (response) {
            AppNotifier.showSuccess('Xóa sản phẩm thành công');
            fetchProducts(reset: true);
          },
        );
      },
    );
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 200 &&
        hasMore.value &&
        loadProductStatus.value != LoadStatus.loading) {
      fetchProducts();
    }
  }

  Future<void> onPressAddProduct() async {
    final result = await Get.toNamed(AppRoutes.addProduct);
    if (result == true) {
      fetchProducts(reset: true);
    }
  }

  Future<void> onPressEditProduct(ProductEntity product) async {
    final result = await Get.toNamed(
      AppRoutes.addProduct,
      arguments: {'product': product, 'categories': categories.toList()},
    );
    if (result == true) {
      fetchProducts(reset: true);
    }
  }

  void onPressLogout() {
    AppDialog.show(
      message: 'Bạn có chắc chắn muốn đăng xuất không?',
      textConfirm: 'Đăng xuất',
      textCancel: 'Hủy',
      onConfirm: () async {
        await SecureStorageHelper.instance.clearAccessToken();
        authController.markUnauthenticated();
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }

  void onSearchChanged(String keyword) {
    searchKeyword.value = keyword;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      fetchProducts(reset: true);
    });
  }

  Future<void> refreshProducts() async {
    isRefreshing.value = true;
    await fetchProducts(reset: true);
    isRefreshing.value = false;
  }
}
