class LoginRequest {
  final String deviceName;
  final String username;
  final String password;

  const LoginRequest({
    required this.deviceName,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceName': deviceName,
      'username': username,
      'password': password,
    };
  }
}

class LoginSuccessResponse {
  final String username;
  final String environment;
  final String role;
  final String? aisSessionCookie;
  final String? token;
  final bool adminAuthorized;
  final bool passwordAboutToExpire;

  const LoginSuccessResponse({
    required this.username,
    required this.environment,
    required this.role,
    required this.aisSessionCookie,
    required this.token,
    required this.adminAuthorized,
    required this.passwordAboutToExpire,
  });

  factory LoginSuccessResponse.fromJson(Map<String, dynamic> json) {
    final userInfo = (json['userInfo'] is Map<String, dynamic>)
        ? json['userInfo'] as Map<String, dynamic>
        : <String, dynamic>{};

    return LoginSuccessResponse(
      username: (json['username'] ?? '').toString(),
      environment: (json['environment'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      aisSessionCookie: json['aisSessionCookie']?.toString(),
      token: userInfo['token']?.toString(),
      adminAuthorized: json['adminAuthorized'] == true,
      passwordAboutToExpire: json['passwordAboutToExpire'] == true,
    );
  }
}

class LoginFailureResponse {
  final String message;
  final String? exception;
  final String? status;
  final String? exceptionId;

  const LoginFailureResponse({
    required this.message,
    this.exception,
    this.status,
    this.exceptionId,
  });

  factory LoginFailureResponse.fromJson(Map<String, dynamic> json) {
    return LoginFailureResponse(
      message: (json['message'] ?? 'Login failed').toString(),
      exception: json['exception']?.toString(),
      status: json['status']?.toString(),
      exceptionId: json['exceptionId']?.toString(),
    );
  }
}
