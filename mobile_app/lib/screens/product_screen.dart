import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import 'product_detail_screen.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> with TickerProviderStateMixin {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late TabController _tabController;

  // Danh sách gốc từ API
  List<Product> _allProducts = [];
  List<Product> _newProducts = [];
  List<Product> _accessories = [];
  List<Product> _bestSellers = [];

  // Danh sách hiển thị (sau khi filter/search)
  List<Product> _displayedProducts = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;

  int _currentPage = 0;
  final int _pageSize = 10;
  String _currentTab = 'new';
  String _searchKeyword = '';

  // Bộ lọc
  double? _minPrice;
  double? _maxPrice;
  int? _selectedCategoryId;
  String? _selectedTrademark;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);

    // Listener cho search
    _searchController.addListener(() {
      _performClientSideSearch();
    });

    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreData && _searchKeyword.isEmpty) {
        _loadMoreData();
      }
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _hasMoreData = true;
    });

    try {
      List<Product> products;
      switch (_currentTab) {
        case 'new':
          products = await _productService.getNewProducts(page: _currentPage, size: _pageSize);
          _newProducts.addAll(products);
          _allProducts = _newProducts;
          break;
        case 'accessories':
          products = await _productService.getAccessories(page: _currentPage, size: _pageSize);
          _accessories.addAll(products);
          _allProducts = _accessories;
          break;
        case 'bestseller':
          products = await _productService.getBestSellers(page: _currentPage, size: _pageSize);
          _bestSellers.addAll(products);
          _allProducts = _bestSellers;
          break;
        default:
          products = await _productService.getNewProducts(page: _currentPage, size: _pageSize);
          _allProducts = products;
      }

      setState(() {
        _displayedProducts = List.from(_allProducts);
        _hasMoreData = products.length == _pageSize;
        _isLoading = false;
      });

      // Nếu có search keyword, thực hiện search ngay
      if (_searchKeyword.isNotEmpty) {
        _performClientSideSearch();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Lỗi khi tải dữ liệu: $e');
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore || !_hasMoreData || _searchKeyword.isNotEmpty) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _currentPage++;
      List<Product> newProducts;

      switch (_currentTab) {
        case 'new':
          newProducts = await _productService.getNewProducts(page: _currentPage, size: _pageSize);
          _newProducts.addAll(newProducts);
          _allProducts = _newProducts;
          break;
        case 'accessories':
          newProducts = await _productService.getAccessories(page: _currentPage, size: _pageSize);
          _accessories.addAll(newProducts);
          _allProducts = _accessories;
          break;
        case 'bestseller':
          newProducts = await _productService.getBestSellers(page: _currentPage, size: _pageSize);
          _bestSellers.addAll(newProducts);
          _allProducts = _bestSellers;
          break;
        default:
          newProducts = await _productService.getNewProducts(page: _currentPage, size: _pageSize);
          _allProducts.addAll(newProducts);
      }

      setState(() {
        _displayedProducts = List.from(_allProducts);
        _hasMoreData = newProducts.length == _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
        _currentPage--;
      });
      _showErrorSnackBar('Lỗi khi tải thêm dữ liệu: $e');
    }
  }

  // Tìm kiếm client-side
  void _performClientSideSearch() {
    final keyword = _searchController.text.trim().toLowerCase();

    setState(() {
      _searchKeyword = keyword;

      if (keyword.isEmpty) {
        // Không có từ khóa tìm kiếm - hiển thị tất cả
        _displayedProducts = _applyFilters(_allProducts);
      } else {
        // Có từ khóa tìm kiếm
        List<Product> searchResults = _allProducts.where((product) {
          final name = product.name?.toLowerCase() ?? '';
          final trademark = product.tradeMark?.name?.toLowerCase() ?? '';
          final description = product.description?.toLowerCase() ?? '';

          return name.contains(keyword) ||
              trademark.contains(keyword) ||
              description.contains(keyword);
        }).toList();

        _displayedProducts = _applyFilters(searchResults);
      }
    });
  }

  // Áp dụng bộ lọc
  List<Product> _applyFilters(List<Product> products) {
    return products.where((product) {
      // Lọc theo giá
      if (_minPrice != null && (product.price ?? 0) < _minPrice!) return false;
      if (_maxPrice != null && (product.price ?? 0) > _maxPrice!) return false;

      // Lọc theo thương hiệu
      if (_selectedTrademark != null && _selectedTrademark!.isNotEmpty) {
        final trademark = product.tradeMark?.name?.toLowerCase() ?? '';
        if (!trademark.contains(_selectedTrademark!.toLowerCase())) return false;
      }

      // Lọc theo category (nếu cần)
      if (_selectedCategoryId != null) {
        if (product.category != _selectedCategoryId) return false;
      }

      return true;
    }).toList();
  }

  Future<void> _filterProducts() async {
    setState(() {
      _displayedProducts = _applyFilters(_allProducts);
    });

    // Nếu có search keyword, thực hiện search lại
    if (_searchKeyword.isNotEmpty) {
      _performClientSideSearch();
    }
  }

  // Load tất cả sản phẩm để search tốt hơn
  Future<void> _loadAllProductsForSearch() async {
    if (_allProducts.length < 50) { // Chỉ load thêm nếu data ít
      try {
        List<Product> moreProducts = [];
        for (int page = 1; page < 5; page++) { // Load thêm 4 pages
          List<Product> pageProducts;
          switch (_currentTab) {
            case 'new':
              pageProducts = await _productService.getNewProducts(page: page, size: _pageSize);
              break;
            case 'accessories':
              pageProducts = await _productService.getAccessories(page: page, size: _pageSize);
              break;
            case 'bestseller':
              pageProducts = await _productService.getBestSellers(page: page, size: _pageSize);
              break;
            default:
              pageProducts = await _productService.getNewProducts(page: page, size: _pageSize);
          }

          if (pageProducts.isEmpty) break;
          moreProducts.addAll(pageProducts);
        }

        setState(() {
          _allProducts.addAll(moreProducts);
        });

        // Thực hiện search lại với data nhiều hơn
        _performClientSideSearch();
      } catch (e) {
        print('Error loading more products for search: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bộ lọc sản phẩm'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Giá tối thiểu',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _minPrice = double.tryParse(value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Giá tối đa',
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _maxPrice = double.tryParse(value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Thương hiệu',
                    prefixIcon: Icon(Icons.business),
                  ),
                  onChanged: (value) {
                    _selectedTrademark = value.isEmpty ? null : value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _minPrice = null;
                  _maxPrice = null;
                  _selectedCategoryId = null;
                  _selectedTrademark = null;
                });
                Navigator.of(context).pop();
                _filterProducts();
              },
              child: const Text('Xóa bộ lọc'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _filterProducts();
              },
              child: const Text('Áp dụng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm'),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Thanh tìm kiếm
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm sản phẩm...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _searchKeyword = '';
                              _performClientSideSearch();
                            },
                          )
                              : IconButton(
                            icon: const Icon(Icons.download),
                            onPressed: _loadAllProductsForSearch,
                            tooltip: 'Tải thêm sản phẩm để search tốt hơn',
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        onChanged: (value) {
                          // Search real-time khi user gõ
                          if (value.length >= 2 || value.isEmpty) {
                            _performClientSideSearch();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterDialog,
                    ),
                  ],
                ),
              ),
              // Tab bar
              TabBar(
                controller: _tabController,
                onTap: (index) {
                  setState(() {
                    switch (index) {
                      case 0:
                        _currentTab = 'new';
                        _allProducts = _newProducts;
                        break;
                      case 1:
                        _currentTab = 'accessories';
                        _allProducts = _accessories;
                        break;
                      case 2:
                        _currentTab = 'bestseller';
                        _allProducts = _bestSellers;
                        break;
                    }
                    _searchController.clear();
                    _searchKeyword = '';
                  });
                  _loadInitialData();
                },
                tabs: const [
                  Tab(text: 'Mới nhất'),
                  Tab(text: 'Phụ kiện'),
                  Tab(text: 'Bán chạy'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Reset data và load lại
          _newProducts.clear();
          _accessories.clear();
          _bestSellers.clear();
          _allProducts.clear();
          await _loadInitialData();
        },
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _displayedProducts.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                  _searchKeyword.isNotEmpty ? Icons.search_off : Icons.shopping_bag_outlined,
                  size: 64,
                  color: Colors.grey
              ),
              SizedBox(height: 16),
              Text(
                  _searchKeyword.isNotEmpty
                      ? 'Không tìm thấy sản phẩm cho "$_searchKeyword"'
                      : 'Không có sản phẩm nào',
                  style: TextStyle(fontSize: 18, color: Colors.grey)
              ),
              if (_searchKeyword.isNotEmpty) ...[
                SizedBox(height: 8),
                TextButton(
                  onPressed: _loadAllProductsForSearch,
                  child: Text('Tải thêm sản phẩm để tìm kiếm'),
                ),
              ],
            ],
          ),
        )
            : ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: _displayedProducts.length + (_isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _displayedProducts.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final product = _displayedProducts[index];
            return ProductCard(
              product: product,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(productId: product.id!),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hình ảnh sản phẩm
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageBanner ?? '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Thông tin sản phẩm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? 'Tên sản phẩm',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.tradeMark?.name != null)
                      Text(
                        product.tradeMark!.name!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${_formatPrice(product.price)} đ',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        if (product.oldPrice != null && product.oldPrice! > product.price!)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              '${_formatPrice(product.oldPrice)} đ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (product.quantitySold != null)
                      Text(
                        'Đã bán: ${product.quantitySold}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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

  String _formatPrice(double? price) {
    if (price == null) return '0';
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }
}