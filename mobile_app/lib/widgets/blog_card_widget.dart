import 'package:flutter/material.dart';
import '../models/blog_models.dart';

class BlogCardWidget extends StatelessWidget {
  final BlogResponse blog;
  final VoidCallback onTap;

  const BlogCardWidget({Key? key, required this.blog, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[300],
                ),
                child:
                    blog.imageBanner.isNotEmpty
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            blog.imageBanner,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.article, size: 40);
                            },
                          ),
                        )
                        : Icon(Icons.article, size: 40, color: Colors.grey),
              ),

              SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Primary blog indicator
                    if (blog.primaryBlog)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        margin: EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Nổi bật',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    // Title
                    Text(
                      blog.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4),

                    // Description
                    Text(
                      blog.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 8),

                    // Date and author
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 4),
                        Text(
                          blog.createdDate,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        if (blog.user?.fullName != null) ...[
                          SizedBox(width: 8),
                          Icon(Icons.person, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              blog.user!.fullName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
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
}
