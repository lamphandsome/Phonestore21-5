import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/blog_provider.dart';
import '../widgets/blog_card_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'blog_detail_screen.dart';

class BlogListScreen extends StatefulWidget {
  @override
  _BlogListScreenState createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlogProvider>().loadBlogs(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      context.read<BlogProvider>().loadBlogs();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tin tức'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<BlogProvider>(
        builder: (context, blogProvider, child) {
          if (blogProvider.blogs.isEmpty && blogProvider.isLoading) {
            return LoadingWidget();
          }

          if (blogProvider.error != null && blogProvider.blogs.isEmpty) {
            return ErrorWidgetCustom(
              message: blogProvider.error!,
              onRetry: () => blogProvider.loadBlogs(refresh: true),
            );
          }

          return RefreshIndicator(
            onRefresh: () => blogProvider.loadBlogs(refresh: true),
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  blogProvider.blogs.length +
                  (blogProvider.hasNextPage ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == blogProvider.blogs.length) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final blog = blogProvider.blogs[index];
                return BlogCardWidget(
                  blog: blog,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlogDetailScreen(blogId: blog.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
