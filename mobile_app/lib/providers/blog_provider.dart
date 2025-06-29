import 'package:flutter/material.dart';
import '../models/blog_models.dart';
import '../services/blog_service.dart';

class BlogProvider with ChangeNotifier {
  List<BlogResponse> _blogs = [];
  BlogResponse? _selectedBlog;
  BlogResponse? _primaryBlog;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 0;
  bool _hasNextPage = true;

  // Getters
  List<BlogResponse> get blogs => _blogs;
  BlogResponse? get selectedBlog => _selectedBlog;
  BlogResponse? get primaryBlog => _primaryBlog;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNextPage => _hasNextPage;
  int get currentPage => _currentPage;

  // Load blogs with pagination
  Future<void> loadBlogs({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _blogs.clear();
      _hasNextPage = true;
    }

    if (_isLoading || !_hasNextPage) return;

    _setLoading(true);
    _setError(null);

    try {
      final pageResponse = await BlogService.getAllBlogs(
        page: _currentPage,
        size: 10,
      );

      if (refresh) {
        _blogs = pageResponse.content;
      } else {
        _blogs.addAll(pageResponse.content);
      }

      _hasNextPage = !pageResponse.last;
      _currentPage++;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load blog by ID
  Future<void> loadBlogById(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      _selectedBlog = await BlogService.getBlogById(id);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Load primary blog
  Future<void> loadPrimaryBlog() async {
    _setLoading(true);
    _setError(null);

    try {
      _primaryBlog = await BlogService.getPrimaryBlog();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create blog (Admin)
  Future<bool> createBlog(BlogRequest request) async {
    _setLoading(true);
    _setError(null);

    try {
      final newBlog = await BlogService.createBlog(request);
      _blogs.insert(0, newBlog);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update blog (Admin)
  Future<bool> updateBlog(BlogRequest request) async {
    _setLoading(true);
    _setError(null);

    try {
      final updatedBlog = await BlogService.updateBlog(request);
      final index = _blogs.indexWhere((blog) => blog.id == updatedBlog.id);
      if (index != -1) {
        _blogs[index] = updatedBlog;
      }
      if (_selectedBlog?.id == updatedBlog.id) {
        _selectedBlog = updatedBlog;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete blog (Admin)
  Future<bool> deleteBlog(int id) async {
    _setLoading(true);
    _setError(null);

    try {
      await BlogService.deleteBlog(id);
      _blogs.removeWhere((blog) => blog.id == id);
      if (_selectedBlog?.id == id) {
        _selectedBlog = null;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedBlog() {
    _selectedBlog = null;
    notifyListeners();
  }
}
