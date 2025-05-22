class User {
  final int? id;
  final String? username;
  final String? email;
  final String? fullname;
  final String? phone;
  final bool? actived;
  final String? createdDate;
  final String? userType;

  User({
    this.id,
    this.username,
    this.email,
    this.fullname,
    this.phone,
    this.actived,
    this.createdDate,
    this.userType,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullname: json['fullname'],
      phone: json['phone'],
      actived: json['actived'],
      createdDate: json['createdDate'],
      userType: json['userType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullname': fullname,
      'phone': phone,
      'actived': actived,
      'createdDate': createdDate,
      'userType': userType,
    };
  }
}

class TokenResponse {
  final String token;
  final User user;

  TokenResponse({
    required this.token,
    required this.user,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}

class LoginRequest {
  final String username;
  final String password;
  final String? tokenFcm;

  LoginRequest({
    required this.username,
    required this.password,
    this.tokenFcm,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'tokenFcm': tokenFcm,
    };
  }
}

class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String fullname;
  final String? phone;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.fullname,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'fullname': fullname,
      'phone': phone,
    };
  }
}