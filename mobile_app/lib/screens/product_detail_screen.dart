import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'package:flutter_html/flutter_html.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with TickerProviderStateMixin {
  final ProductService _productService = ProductService();
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  Product? _product;
  List<Product> _relatedProducts = [];
  List<ProductComment> _comments = [];

  bool _isLoading = true;
  bool _isLoadingRelated = false;
  bool _isLoadingComments = false;

  int _currentImageIndex = 0;
  int _selectedStorageIndex = 0;
  int _selectedColorIndex = 0;

  String _selectedTab = 'info'; // info, comments, related

  @override
  void initState() {
    super.initState();
    _loadProductDetail();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProductDetail() async {
    setState(() => _isLoading = true);

    try {
      final product = await _productService.getProductById(widget.productId);
      setState(() {
        _product = product;
        _isLoading = false;
      });

      // Load related data
      _loadRelatedProducts();
      _loadComments();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Lỗi khi tải chi tiết sản phẩm: $e');
    }
  }

  Future<void> _loadRelatedProducts() async {
    if (_product == null) return;

    setState(() => _isLoadingRelated = true);

    try {
      final related = await _productService.getRelatedProducts(
        productId: _product!.id!,
        trademarkId: _product!.tradeMark?.id,
        categoryId: _product!.category?.id,
      );
      setState(() {
        _relatedProducts = related;
        _isLoadingRelated = false;
      });
    } catch (e) {
      setState(() => _isLoadingRelated = false);
    }
  }

  Future<void> _loadComments() async {
    setState(() => _isLoadingComments = true);

    try {
      final comments = await _productService.getProductComments(widget.productId);
      setState(() {
        _comments = comments;
        _isLoadingComments = false;
      });
    } catch (e) {
      setState(() => _isLoadingComments = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _formatPrice(double? price) {
    if (price == null) return '0';
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  double _getCurrentPrice() {
    if (_product?.productStorages?.isNotEmpty == true &&
        _selectedStorageIndex < _product!.productStorages!.length &&
        _product!.productStorages![_selectedStorageIndex].productColors?.isNotEmpty == true &&
        _selectedColorIndex < _product!.productStorages![_selectedStorageIndex].productColors!.length) {
      return _product!.productStorages![_selectedStorageIndex].productColors![_selectedColorIndex].price ?? _product!.price ?? 0;
    }
    return _product?.price ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
        body: const Center(child: Text('Không tìm thấy sản phẩm')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_product!.name ?? 'Chi tiết sản phẩm'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(),
                  _buildProductInfo(),
                  _buildStorageSelection(),
                  _buildColorSelection(),
                  _buildTabSection(),
                  _buildTabContent(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    List<String> images = [];

    if (_product!.imageBanner?.isNotEmpty == true) {
      images.add(_product!.imageBanner!);
    }

    if (_product!.productImages?.isNotEmpty == true) {
      images.addAll(_product!.productImages!.map((img) => img.linkImage ?? '').where((link) => link.isNotEmpty));
    }

    if (images.isEmpty) {
      return Container(
        height: 300,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.image_not_supported, size: 64)),
      );
    }

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentImageIndex = index),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  );
                },
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: images.asMap().entries.map((entry) {
                  return Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == entry.key ? Colors.white : Colors.white54,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _product!.name ?? '',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (_product!.tradeMark?.name != null)
            Text(
              'Thương hiệu: ${_product!.tradeMark!.name!}',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                '${_formatPrice(_getCurrentPrice())} đ',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              if (_product!.oldPrice != null && _product!.oldPrice! > _getCurrentPrice())
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    '${_formatPrice(_product!.oldPrice)} đ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (_product!.quantitySold != null)
            Text(
              'Đã bán: ${_product!.quantitySold}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildStorageSelection() {
    if (_product!.productStorages?.isEmpty == true) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dung lượng:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _product!.productStorages!.asMap().entries.map((entry) {
              final index = entry.key;
              final storage = entry.value;
              final isSelected = index == _selectedStorageIndex;

              return ChoiceChip(
                label: Text('${storage.ram}/${storage.rom}'),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedStorageIndex = index;
                    _selectedColorIndex = 0; // Reset color selection
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildColorSelection() {
    if (_product!.productStorages?.isEmpty == true ||
        _selectedStorageIndex >= _product!.productStorages!.length ||
        _product!.productStorages![_selectedStorageIndex].productColors?.isEmpty == true) {
      return const SizedBox();
    }

    final colors = _product!.productStorages![_selectedStorageIndex].productColors!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Màu sắc:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: colors.asMap().entries.map((entry) {
              final index = entry.key;
              final color = entry.value;
              final isSelected = index == _selectedColorIndex;

              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (color.image?.isNotEmpty == true)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          color.image!,
                          width: 20,
                          height: 20,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 20,
                              height: 20,
                              color: Colors.grey[300],
                            );
                          },
                        ),
                      ),
                    if (color.image?.isNotEmpty == true) const SizedBox(width: 4),
                    Text(color.name ?? 'Màu ${index + 1}'),
                  ],
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedColorIndex = index);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          _buildTabButton('Thông tin', 'info'),
          _buildTabButton('Đánh giá (${_comments.length})', 'comments'),
          _buildTabButton('Sản phẩm tương tự', 'related'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, String tabKey) {
    final isSelected = _selectedTab == tabKey;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTab = tabKey),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 'info':
        return _buildInfoTab();
      case 'comments':
        return _buildCommentsTab();
      case 'related':
        return _buildRelatedProductsTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mô tả sản phẩm:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          // Chỉ hiển thị HTML
          Html(
            data: _product!.description ?? 'Chưa có mô tả',
            style: {
              "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
            },
          ),
          const SizedBox(height: 16),
          const Text('Thông tin chi tiết:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildInfoRow('Mã sản phẩm', _product!.code),
          _buildInfoRow('Danh mục', _product!.category?.name),
          _buildInfoRow('Thương hiệu', _product!.tradeMark?.name),
          _buildInfoRow('Ngày tạo', _product!.createdDate),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value?.isEmpty != false) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(child: Text(value!)),
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    if (_isLoadingComments) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.comment_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Chưa có đánh giá nào', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _comments.map((comment) => _buildCommentItem(comment)).toList(),
    );
  }

  Widget _buildCommentItem(ProductComment comment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: comment.user?.avatar?.isNotEmpty == true
                    ? NetworkImage(comment.user!.avatar!)
                    : null,
                child: comment.user?.avatar?.isEmpty != false
                    ? Text(comment.user?.fullname?.substring(0, 1).toUpperCase() ?? 'U')
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.user?.fullname ?? 'Người dùng',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < (comment.star ?? 0) ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          '${comment.createdDate ?? ''} ${comment.createdTime ?? ''}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content ?? ''),
          if (comment.productCommentImages?.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: comment.productCommentImages!.map((img) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      img.linkImage ?? '',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRelatedProductsTab() {
    if (_isLoadingRelated) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_relatedProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('Không có sản phẩm tương tự', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _relatedProducts.map((product) => _buildRelatedProductItem(product)).toList(),
    );
  }

  Widget _buildRelatedProductItem(Product product) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id!),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageBanner ?? '',
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatPrice(product.price)} đ',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Add to cart logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                );
              },
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Thêm vào giỏ'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Buy now logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mua ngay')),
                );
              },
              child: const Text('Mua ngay'),
            ),
          ),
        ],
      ),
    );
  }
}