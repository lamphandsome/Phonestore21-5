class BlogRequest {
  final int? id;
  final String title;
  final String description;
  final String content;
  final bool primaryBlog;
  final String imageBanner;

  BlogRequest({
    this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.primaryBlog,
    required this.imageBanner,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'primaryBlog': primaryBlog,
      'imageBanner': imageBanner,
    };
  }
}

class UserDto {
  final int? id;
  final String? username;
  final String? email;
  final String? fullName;

  UserDto({this.id, this.username, this.email, this.fullName});

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
    );
  }
}

class BlogResponse {
  final int id;
  final String createdDate;
  final String title;
  final String description;
  final String content;
  final bool primaryBlog;
  final String imageBanner;
  final UserDto? user;

  BlogResponse({
    required this.id,
    required this.createdDate,
    required this.title,
    required this.description,
    required this.content,
    required this.primaryBlog,
    required this.imageBanner,
    this.user,
  });

  factory BlogResponse.fromJson(Map<String, dynamic> json) {
    return BlogResponse(
      id: json['id'],
      createdDate: json['createdDate'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      primaryBlog: json['primaryBlog'] ?? false,
      imageBanner: json['imageBanner'] ?? '',
      user: json['user'] != null ? UserDto.fromJson(json['user']) : null,
    );
  }
}

class PageResponse<T> {
  final List<T> content;
  final bool first;
  final bool last;
  final int totalPages;
  final int totalElements;
  final int size;
  final int number;
  final int numberOfElements;

  PageResponse({
    required this.content,
    required this.first,
    required this.last,
    required this.totalPages,
    required this.totalElements,
    required this.size,
    required this.number,
    required this.numberOfElements,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PageResponse<T>(
      content:
          (json['content'] as List)
              .map((item) => fromJsonT(item as Map<String, dynamic>))
              .toList(),
      first: json['first'] ?? true,
      last: json['last'] ?? true,
      totalPages: json['totalPages'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      size: json['size'] ?? 0,
      number: json['number'] ?? 0,
      numberOfElements: json['numberOfElements'] ?? 0,
    );
  }
}
