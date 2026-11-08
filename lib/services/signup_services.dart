import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Course {
  final int id;
  final String name;
  final int duration;

  const Course({required this.id, required this.name, required this.duration});

  factory Course.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['course_name'] ?? json['name'];
    final duration = json['duration'];
    if (id is! int ||
        name is! String ||
        name.trim().isEmpty ||
        duration is! int ||
        duration < 1) {
      throw const FormatException('Invalid course returned by the API');
    }
    return Course(id: id, name: name, duration: duration);
  }
}

class SignUpResult {
  final bool success;
  final String message;

  SignUpResult({required this.success, required this.message});
}

class SignUpService {
  const SignUpService();

  static const _configuredBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) {
      return _configuredBaseUrl;
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:5000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://127.0.0.1:5000';
    }
    return 'http://127.0.0.1:5000';
  }

  Future<List<Course>> fetchCourses() async {
    final uri = Uri.parse('$baseUrl/courses');
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception(
        'GET $uri failed (${response.statusCode}): ${response.body}',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Courses API response must be a JSON list');
    }
    return decoded.map((course) {
      if (course is! Map<String, dynamic>) {
        throw const FormatException('Invalid course returned by the API');
      }
      return Course.fromJson(course);
    }).toList();
  }

  Future<SignUpResult> signUp({
    required String studentNumber,
    required String email,
    required String courseName,
    required int yearOfStudy,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/signup'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'student_id': studentNumber,
            'email': email,
            'course_name': courseName,
            'year_of_study': yearOfStudy,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    final message = body['message']?.toString() ?? 'Unknown error';

    if (response.statusCode == 201) {
      return SignUpResult(success: true, message: message);
    }
    return SignUpResult(success: false, message: message);
  }

  Future<SignUpResult> signUpLecturer({
    required String firstName,
    required String lastName,
    required String email,
    required List<int> courseIds,
    required String password,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/signup/lecturer'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'first_name': firstName,
            'last_name': lastName,
            'email': email,
            'course_ids': courseIds,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Lecturer signup response must be a JSON object',
      );
    }

    final message = decoded['message']?.toString() ?? 'Unknown error';
    if (response.statusCode == 201) {
      return SignUpResult(success: true, message: message);
    }
    return SignUpResult(success: false, message: message);
  }
}
