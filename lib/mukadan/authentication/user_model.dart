

class AuthResponse {
  final String token;
  final bool isNewUser;
  final User user;

  AuthResponse({
    required this.token,
    required this.isNewUser,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      isNewUser: json['is_new_user'] as bool,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'is_new_user': isNewUser,
      'user': user.toJson(),
    };
  }
}

class User {
  final int id;
  final String username;
  final String fullName;
  final String mobileNumber;
  final String role;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.mobileNumber,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      fullName: json['full_name'] as String,
      mobileNumber: json['mobile_number'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'mobile_number': mobileNumber,
      'role': role,
    };
  }
}