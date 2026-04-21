import 'package:crud_getx_demo/data/model/enums/product_sort_filter.dart';
import 'package:crud_getx_demo/data/model/enums/product_status_filter.dart';
import 'package:crud_getx_demo/modules/home/controllers/home_controller.dart';
import 'package:crud_getx_demo/modules/home/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends GetWidget<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sản phẩm'),
        actions: [_buildButtonLogout()],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildButtonLogout() {
    return TextButton(
      onPressed: () {
        controller.onPressLogout();
      },
      child: const Text('Đăng xuất'),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildToolbar(),
        const SizedBox(height: 8),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await controller.refreshProducts();
            },
            child: _buildProductContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: controller.searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Tìm theo tên sản phẩm...',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  controller.onSearchChanged(value);
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildCategoryFilter()),
                  const SizedBox(width: 8),
                  Expanded(child: _buildStatusFilter()),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildSortFilter()),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      await controller.onPressAddProduct();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm sản phẩm'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<ProductStatusFilter>(
      value: controller.selectedActive.value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Trạng thái',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: ProductStatusFilter.all,
          child: Text('Tất cả trạng thái'),
        ),
        DropdownMenuItem(
          value: ProductStatusFilter.active,
          child: Text('Active'),
        ),
        DropdownMenuItem(
          value: ProductStatusFilter.inactive,
          child: Text('Inactive'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          controller.onStatusFilterChanged(value);
        }
      },
    );
  }

  Widget _buildSortFilter() {
    return DropdownButtonFormField<ProductSortOption>(
      value: controller.selectedSort.value,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Sắp xếp',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(
          value: ProductSortOption.latest,
          child: Text('Cập nhật mới nhất'),
        ),
        DropdownMenuItem(
          value: ProductSortOption.nameAsc,
          child: Text('Tên A → Z'),
        ),
        DropdownMenuItem(
          value: ProductSortOption.nameDesc,
          child: Text('Tên Z → A'),
        ),
        DropdownMenuItem(
          value: ProductSortOption.priceAsc,
          child: Text('Giá thấp → cao'),
        ),
        DropdownMenuItem(
          value: ProductSortOption.priceDesc,
          child: Text('Giá cao → thấp'),
        ),
        DropdownMenuItem(
          value: ProductSortOption.stockAsc,
          child: Text('Tồn kho thấp → cao'),
        ),
        DropdownMenuItem(
          value: ProductSortOption.stockDesc,
          child: Text('Tồn kho cao → thấp'),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          controller.onSortOptionChanged(value);
        }
      },
    );
  }

  Widget _buildCategoryFilter() {
    return Obx(
      () => DropdownButtonFormField<int?>(
        value: controller.selectedCategoryId.value,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Danh mục',
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<int?>(
            value: null,
            child: Text('Tất cả danh mục'),
          ),

          ...controller.categories.map(
            (category) => DropdownMenuItem<int?>(
              value: category.id,
              child: Text(category.name ?? 'Không tên'),
            ),
          ),
        ],
        onChanged: (int? value) {
          controller.onCategoryChange(value);
        },
      ),
    );
  }

  Widget _buildProductContent() {
    return Obx(() {
      final isLoading = controller.loadProductStatus.value.isLoading;
      final isLoadingMore = controller.loadProductStatus.value.isLoadingMore;

      if (isLoading && controller.products.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!isLoading && controller.products.isEmpty) {
        return const Center(child: Text('Không có sản phẩm nào'));
      }

      return ListView.builder(
        controller: controller.scrollController,
        itemCount: controller.products.length + (isLoadingMore ? 1 : 0),

        itemBuilder: (context, index) {
          if (index >= controller.products.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final item = controller.products[index];
          return ProductCard(
            onEdit: () => controller.onPressEditProduct(item),
            item: item,
            onDelete: () {
              controller.onPressDeleted(item.id ?? -1);
            },
          );
        },
      );
    });
  }
}
