// lib/main_blog_test.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/blog_provider.dart';
import 'screens/blog_list_screen.dart';
import 'screens/blog_detail_screen.dart';
import 'services/api_service.dart';

void main() {
  // Cấu hình API base URL
  // Thay đổi IP này thành IP máy chủ của bạn
  // ApiService.baseUrl = 'http://192.168.1.100:8080/api';

  runApp(BlogTestApp());
}

class BlogTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BlogProvider()),
      ],
      child: MaterialApp(
        title: 'Blog Test App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        home: BlogTestHomeScreen(),
        routes: {
          '/blog-list': (context) => BlogListScreen(),
          '/blog-detail': (context) => BlogDetailScreen(
            blogId: ModalRoute.of(context)!.settings.arguments as int,
          ),
        },
      ),
    );
  }
}

class BlogTestHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Test Menu'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thông tin kết nối
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin kết nối API',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Base URL: ${ApiService.baseUrl}'),
                    Text('Status: Chưa kết nối'),
                    SizedBox(height: 8),
                    Text(
                      'Lưu ý: Hãy đảm bảo backend đang chạy và cập nhật đúng IP trong api_service.dart',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Menu buttons
            Text(
              'Chọn chức năng để test:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 16),

            // Blog List Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BlogListScreen()),
                );
              },
              icon: Icon(Icons.list),
              label: Text('Test Danh sách Blog'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            SizedBox(height: 12),

            // Blog Detail Button
            ElevatedButton.icon(
              onPressed: () {
                _showBlogIdDialog(context);
              },
              icon: Icon(Icons.article),
              label: Text('Test Chi tiết Blog'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            SizedBox(height: 12),

            // Primary Blog Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrimaryBlogTestScreen()),
                );
              },
              icon: Icon(Icons.star),
              label: Text('Test Blog Nổi bật'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            SizedBox(height: 12),

            // API Test Button
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ApiTestScreen()),
                );
              },
              icon: Icon(Icons.network_check),
              label: Text('Test kết nối API'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            Spacer(),

            // Instructions
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hướng dẫn test:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('1. Cập nhật IP server trong services/api_service.dart'),
                  Text('2. Đảm bảo backend Spring Boot đang chạy'),
                  Text('3. Chọn chức năng muốn test ở trên'),
                  Text('4. Kiểm tra console để xem log lỗi (nếu có)'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBlogIdDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nhập ID Blog'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Blog ID',
            hintText: 'Ví dụ: 1',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              final id = int.tryParse(controller.text);
              if (id != null) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlogDetailScreen(blogId: id),
                  ),
                );
              }
            },
            child: Text('Xem'),
          ),
        ],
      ),
    );
  }
}

// Screen test Primary Blog
class PrimaryBlogTestScreen extends StatefulWidget {
  @override
  _PrimaryBlogTestScreenState createState() => _PrimaryBlogTestScreenState();
}

class _PrimaryBlogTestScreenState extends State<PrimaryBlogTestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlogProvider>().loadPrimaryBlog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blog Nổi bật'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Consumer<BlogProvider>(
        builder: (context, blogProvider, child) {
          if (blogProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (blogProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text('Lỗi: ${blogProvider.error}'),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => blogProvider.loadPrimaryBlog(),
                    child: Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final blog = blogProvider.primaryBlog;
          if (blog == null) {
            return Center(child: Text('Không có blog nổi bật'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (blog.imageBanner.isNotEmpty)
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(blog.imageBanner),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                SizedBox(height: 16),
                Text(
                  blog.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  blog.description,
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 16),
                Text(
                  blog.content,
                  style: TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Screen test API connection
class ApiTestScreen extends StatefulWidget {
  @override
  _ApiTestScreenState createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _status = 'Chưa test';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test API Connection'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin API',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Base URL: ${ApiService.baseUrl}'),
                    Text('Endpoint: /blog/public/findAll'),
                    SizedBox(height: 8),
                    Text('Status: $_status'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isLoading ? null : _testConnection,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Test kết nối'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),

            SizedBox(height: 16),

            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Checklist trước khi test:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('✓ Backend Spring Boot đã chạy'),
                  Text('✓ Port 8080 đã mở'),
                  Text('✓ IP trong api_service.dart đã đúng'),
                  Text('✓ Điện thoại/emulator cùng mạng với server'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _status = 'Đang test...';
    });

    try {
      final blogs = await context.read<BlogProvider>().loadBlogs(refresh: true);
      setState(() {
        _status = 'Kết nối thành công!';
      });
    } catch (e) {
      setState(() {
        _status = 'Lỗi: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}