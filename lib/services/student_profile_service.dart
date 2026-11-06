import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'signup_services.dart';

class StudentProfile {
  const StudentProfile({
    required this.studentId,
    required this.email,
    required this.courseName,
    required this.courseCode,
  });

  final String studentId;
  final String? email;
  final String courseName;
  final String courseCode;

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    final studentId = json['student_id'];
    final email = json['email'];
    final course = json['course'];
    if (studentId is! String ||
        (email != null && email is! String) ||
        course is! Map<String, dynamic> ||
        course['name'] is! String ||
        course['code'] is! String) {
      throw const FormatException('Invalid student profile returned by API');
    }

    return StudentProfile(
      studentId: studentId,
      email: email as String?,
      courseName: course['name'] as String,
      courseCode: course['code'] as String,
    );
  }
}

class StudentProfileService {
  const StudentProfileService();

  Future<StudentProfile> fetchProfile() async {
    final token = await _readAccessToken();
    final uri = Uri.parse('${SignUpService.baseUrl}/students/me');
    late final http.Response response;
    try {
      response = await http
          .get(uri, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));
    } on http.ClientException catch (error) {
      final phoneConnectionHint = uri.host == '127.0.0.1'
          ? ' On a physical phone, 127.0.0.1 is the phone itself: use the USB '
                'debug configuration with adb reverse, or the Wi-Fi '
                'configuration with your computer IP.'
          : '';
      throw Exception(
        'Could not reach the student API at $uri. Restart Flask and check '
        'that this device can reach the API address.$phoneConnectionHint '
        'Details: $error',
      );
    } on TimeoutException {
      throw Exception(
        'The student API at $uri did not respond within 10 seconds.',
      );
    }

    if (response.statusCode != 200) {
      if (response.statusCode == 404) {
        throw Exception(
          'The student profile endpoint was not found. Restart Flask from '
          'lib/api so it loads the latest student routes.',
        );
      }

      String? message;
      try {
        final errorBody = jsonDecode(response.body);
        message = errorBody is Map<String, dynamic>
            ? errorBody['message']?.toString()
            : null;
      } on FormatException {
        message = null;
      }
      throw Exception(message ?? 'GET $uri failed (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid student profile response from API');
    }
    return StudentProfile.fromJson(decoded);
  }

  Future<String> _readAccessToken() async {
    final token = await const FlutterSecureStorage().read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('Please log in again to view your student profile.');
    }
    return token;
  }
}
