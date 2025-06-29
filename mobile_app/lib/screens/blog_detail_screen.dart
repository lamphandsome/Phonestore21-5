import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blog_provider.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';

class BlogDetailScreen extends StatefulWidget {
  final int blogId;

  const BlogDetailScreen({Key? key, required this.blogId}) : super(key: key);

  @override
  _BlogDetailScreenState createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlogProvider>().loadBlogById(widget.blogId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết tin tức'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<BlogProvider>(
        builder: (context, blogProvider, child) {
          if (blogProvider.isLoading) {
            return LoadingWidget();
          }

          if (blogProvider.error != null) {
            return ErrorWidgetCustom(
              message: blogProvider.error!,
              onRetry: () => blogProvider.loadBlogById(widget.blogId),
            );
          }

          final blog = blogProvider.selectedBlog;
          if (blog == null) {
            return Center(child: Text('Không tìm thấy bài viết'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image banner
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

                // Primary blog indicator
                if (blog.primaryBlog)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Bài viết nổi bật',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                SizedBox(height: 8),

                // Title
                Text(
                  blog.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 8),

                // Author and date
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      blog.user?.fullName ?? 'Ẩn danh',
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(width: 16),
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    SizedBox(width: 4),
                    Text(
                      blog.createdDate,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Description
                Text(
                  blog.description,
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                  ),
                ),

                SizedBox(height: 16),

                // Content
                Text(blog.content, style: TextStyle(fontSize: 16, height: 1.5)),
              ],
            ),
          );
        },
      ),
    );
  }
}
