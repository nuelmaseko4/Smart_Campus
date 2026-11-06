import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'signup_services.dart';

class LoginResult {
  const LoginResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class LoginService {
  const LoginService();

  Future<void> logout() {
    return const FlutterSecureStorage().delete(key: 'access_token');
  }

  Future<LoginResult> login({
    required String role,
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('${SignUpService.baseUrl}/login');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'role': role,
            'username': username,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid login response from the API');
    }

    final message =
        decoded['message']?.toString() ??
        (response.statusCode == 200 ? 'Login successful' : 'Login failed');
    if (response.statusCode != 200) {
      return LoginResult(success: false, message: message);
    }

    final token = decoded['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Login response did not contain a token');
    }

    await const FlutterSecureStorage().write(key: 'access_token', value: token);
    return LoginResult(success: true, message: message);
  }
}
