import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/blog_models.dart';
import 'api_service.dart';

class BlogService {
  // Tạo blog mới (Admin only)
  static Future<BlogResponse> createBlog(BlogRequest blogRequest) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/blog/admin/create'),
        headers: ApiService.headers,
        body: json.encode(blogRequest.toJson()),
      );

      return ApiService.handleResponse(
        response,
        (data) => BlogResponse.fromJson(data),
      );
    } catch (e) {
      throw Exception('Failed to create blog: $e');
    }
  }

  // Cập nhật blog (Admin only)
  static Future<BlogResponse> updateBlog(BlogRequest blogRequest) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/blog/admin/update'),
        headers: ApiService.headers,
        body: json.encode(blogRequest.toJson()),
      );

      return ApiService.handleResponse(
        response,
        (data) => BlogResponse.fromJson(data),
      );
    } catch (e) {
      throw Exception('Failed to update blog: $e');
    }
  }

  // Xóa blog (Admin only)
  static Future<void> deleteBlog(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiService.baseUrl}/blog/admin/delete?id=$id'),
        headers: ApiService.headers,
      );

      await ApiService.handleVoidResponse(response);
    } catch (e) {
      throw Exception('Failed to delete blog: $e');
    }
  }

  // Lấy tất cả blog với phân trang (Public)
  static Future<PageResponse<BlogResponse>> getAllBlogs({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiService.baseUrl}/blog/public/findAll?page=$page&size=$size',
        ),
        headers: ApiService.headers,
      );

      return ApiService.handleResponse(
        response,
        (data) =>
            PageResponse.fromJson(data, (item) => BlogResponse.fromJson(item)),
      );
    } catch (e) {
      throw Exception('Failed to get blogs: $e');
    }
  }

  // Lấy blog theo ID (Public)
  static Future<BlogResponse> getBlogById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/blog/public/findById?id=$id'),
        headers: ApiService.headers,
      );

      return ApiService.handleResponse(
        response,
        (data) => BlogResponse.fromJson(data),
      );
    } catch (e) {
      throw Exception('Failed to get blog: $e');
    }
  }

  // Lấy blog primary (Public)
  static Future<BlogResponse> getPrimaryBlog() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/blog/public/findPrimaryBlog'),
        headers: ApiService.headers,
      );

      return ApiService.handleResponse(
        response,
        (data) => BlogResponse.fromJson(data),
      );
    } catch (e) {
      throw Exception('Failed to get primary blog: $e');
    }
  }
}
