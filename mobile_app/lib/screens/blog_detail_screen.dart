import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
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

                // Description with HTML support
                Html(
                  data: blog.description,
                  style: {
                    "body": Style(
                      fontSize: FontSize(16),
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    "p": Style(
                      margin: Margins.only(bottom: 8),
                    ),
                  },
                ),

                SizedBox(height: 16),

                // Content with HTML support
                Html(
                  data: blog.content,
                  style: {
                    "body": Style(
                      fontSize: FontSize(16),
                      lineHeight: LineHeight(1.5),
                      margin: Margins.zero,
                      padding: HtmlPaddings.zero,
                    ),
                    "p": Style(
                      margin: Margins.only(bottom: 12),
                    ),
                    "h1": Style(
                      fontSize: FontSize(24),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(top: 16, bottom: 8),
                    ),
                    "h2": Style(
                      fontSize: FontSize(20),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(top: 14, bottom: 6),
                    ),
                    "h3": Style(
                      fontSize: FontSize(18),
                      fontWeight: FontWeight.bold,
                      margin: Margins.only(top: 12, bottom: 4),
                    ),
                    "ul": Style(
                      margin: Margins.only(left: 16, bottom: 12),
                    ),
                    "ol": Style(
                      margin: Margins.only(left: 16, bottom: 12),
                    ),
                    "li": Style(
                      margin: Margins.only(bottom: 4),
                    ),
                    "blockquote": Style(
                      backgroundColor: Colors.grey[100],
                      padding: HtmlPaddings.all(12),
                      margin: Margins.only(bottom: 12),
                      border: Border(
                        left: BorderSide(
                          color: Colors.grey[400]!,
                          width: 4,
                        ),
                      ),
                    ),
                    "img": Style(
                      width: Width(double.infinity),
                      margin: Margins.only(bottom: 12),
                    ),
                    "a": Style(
                      color: Colors.blue,
                      textDecoration: TextDecoration.underline,
                    ),
                  },
                  onLinkTap: (url, attributes, element) {
                    // Handle link taps here if needed
                    print("Link tapped: $url");
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}