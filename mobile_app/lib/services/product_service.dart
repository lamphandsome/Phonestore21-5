import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'dart:developer' as developer;

class ProductService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Map<String, String> _headersWithAuth(String? token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // Lấy danh sách sản phẩm mới
  Future<List<Product>> getNewProducts({int page = 0, int size = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/public/new-product?page=$page&size=$size'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> content = data['content'] ?? [];
        return content.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Không thể tải danh sách sản phẩm mới');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Lấy danh sách phụ kiện
  Future<List<Product>> getAccessories({int page = 0, int size = 10}) async {
    try {
      final url = '$baseUrl/product/public/phu-kien?page=$page&size=$size';
      developer.log('Calling API: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      developer.log('Response status: ${response.statusCode}');
      developer.log('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> content = data['content'] ?? [];
        developer.log('Found ${content.length} products');
        return content.map((json) => Product.fromJson(json)).toList();
      } else {
        developer.log('Error response: ${response.body}');
        throw Exception('Không thể tải danh sách phụ kiện - Status: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Exception occurred: $e');
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Lấy danh sách sản phẩm bán chạy
  Future<List<Product>> getBestSellers({int page = 0, int size = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/public/best-saler?page=$page&size=$size'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> content = data['content'] ?? [];
        return content.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Không thể tải danh sách sản phẩm bán chạy');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Lấy chi tiết sản phẩm theo ID
  Future<Product> getProductById(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product/public/findById?id=$productId'),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Product.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy sản phẩm');
      } else {
        throw Exception('Không thể tải chi tiết sản phẩm');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Lấy danh sách sản phẩm liên quan
  Future<List<Product>> getRelatedProducts({
    int? trademarkId,
    int? categoryId,
    required int productId,
    int page = 0,
    int size = 10,
  }) async {
    try {
      String url = '$baseUrl/product/public/san-pham-lienquan?id=$productId&page=$page&size=$size';

      if (trademarkId != null) {
        url += '&idtrademark=$trademarkId';
      }
      if (categoryId != null) {
        url += '&idcategory=$categoryId';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> content = data['content'] ?? [];
        return content.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Không thể tải danh sách sản phẩm liên quan');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Lọc sản phẩm theo các tiêu chí
  Future<List<Product>> filterProducts({
    double? minPrice,
    double? maxPrice,
    int? categoryId,
    String? trademark,
    String? search,
    int page = 0,
    int size = 10,
  }) async {
    try {
      String url = '$baseUrl/product/public/loc-san-pham?page=$page&size=$size';

      if (minPrice != null) {
        url += '&small=$minPrice';
      }
      if (maxPrice != null) {
        url += '&large=$maxPrice';
      }
      if (categoryId != null) {
        url += '&idcategory=$categoryId';
      }
      if (trademark != null && trademark.isNotEmpty) {
        url += '&trademark=${Uri.encodeComponent(trademark)}';
      }
      if (search != null && search.isNotEmpty) {
        url += '&search=${Uri.encodeComponent(search)}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> content = data['content'] ?? [];
        return content.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Không thể lọc sản phẩm');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  Future<List<Product>> searchProducts({
    required String keyword,
    int page = 0,
    int size = 10,
  }) async {
    try {
      print('Searching with keyword: $keyword, page: $page, size: $size');

      // URL đúng: baseUrl + /public/find-by-product
      final url = '$baseUrl/public/find-by-product?idproduct=$keyword&page=$page&size=$size';
      print('Full URL: $url'); // Debug log

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      print('Search response status: ${response.statusCode}');
      print('Search response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['result'] ?? [];
        return data.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in searchProducts: $e');
      throw e;
    }
  }

  // Lấy danh sách bình luận của sản phẩm
  Future<List<ProductComment>> getProductComments(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product-comment/public/find-by-product?idproduct=$productId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ProductComment.fromJson(json)).toList();
      } else {
        throw Exception('Không thể tải danh sách bình luận');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Tạo bình luận mới (cần token)
  Future<ProductComment> createComment({
    required int productId,
    required double star,
    required String content,
    List<String> imageLinks = const [],
    String? token,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'productId': productId,
        'star': star,
        'content': content,
        'listLink': imageLinks,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/product-comment/user/create'),
        headers: _headersWithAuth(token),
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ProductComment.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Bạn cần đăng nhập để bình luận');
      } else {
        throw Exception('Không thể tạo bình luận');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Cập nhật bình luận (cần token)
  Future<ProductComment> updateComment({
    required int commentId,
    required int productId,
    required double star,
    required String content,
    List<String> imageLinks = const [],
    String? token,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'id': commentId,
        'productId': productId,
        'star': star,
        'content': content,
        'listLink': imageLinks,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/product-comment/user/update'),
        headers: _headersWithAuth(token),
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ProductComment.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Bạn không có quyền chỉnh sửa bình luận này');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy bình luận');
      } else {
        throw Exception('Không thể cập nhật bình luận');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Xóa bình luận (cần token)
  Future<void> deleteComment(int commentId, String? token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/product-comment/user/delete?id=$commentId'),
        headers: _headersWithAuth(token),
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Bạn không có quyền xóa bình luận này');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy bình luận');
      } else {
        throw Exception('Không thể xóa bình luận');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }

  // Lấy thông tin bình luận theo ID (cần token)
  Future<ProductComment> getCommentById(int commentId, String? token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/product-comment/user/findById?id=$commentId'),
        headers: _headersWithAuth(token),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ProductComment.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Bạn không có quyền xem bình luận này');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy bình luận');
      } else {
        throw Exception('Không thể tải bình luận');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}