import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uni_connect/services/signup_services.dart';

class LecturerCourse {
  const LecturerCourse({
    required this.id,
    required this.code,
    required this.name,
  });

  final int id;
  final String code;
  final String name;

  factory LecturerCourse.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final code = json['code'];
    final name = json['name'];
    if (id is! int || code is! String || name is! String) {
      throw const FormatException('Invalid course in lecturer profile');
    }
    return LecturerCourse(id: id, code: code, name: name);
  }
}

class LecturerClass {
  const LecturerClass({
    required this.id,
    required this.unitName,
    required this.courseCode,
    required this.courseName,
    required this.room,
    required this.building,
    required this.startTime,
    required this.endTime,
  });

  final int id;
  final String unitName;
  final String courseCode;
  final String courseName;
  final String room;
  final String building;
  final DateTime startTime;
  final DateTime endTime;

  factory LecturerClass.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final unitName = json['unit_name'];
    final courseCode = json['course_code'];
    final courseName = json['course_name'];
    final room = json['room'];
    final building = json['building'];
    final startTime = json['start_time'];
    final endTime = json['end_time'];
    if (id is! int ||
        unitName is! String ||
        courseCode is! String ||
        courseName is! String ||
        room is! String ||
        building is! String ||
        startTime is! String ||
        endTime is! String) {
      throw const FormatException('Invalid class in lecturer profile');
    }
    return LecturerClass(
      id: id,
      unitName: unitName,
      courseCode: courseCode,
      courseName: courseName,
      room: room,
      building: building,
      startTime: DateTime.parse(startTime),
      endTime: DateTime.parse(endTime),
    );
  }
}

class LecturerProfile {
  const LecturerProfile({
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    required this.department,
    required this.courses,
    required this.classes,
  });

  final String firstName;
  final String lastName;
  final String name;
  final String? email;
  final String? department;
  final List<LecturerCourse> courses;
  final List<LecturerClass> classes;

  factory LecturerProfile.fromJson(Map<String, dynamic> json) {
    final firstName = json['first_name'];
    final lastName = json['last_name'];
    final name = json['name'];
    final email = json['email'];
    final department = json['department'];
    final courses = json['courses'];
    final classes = json['classes'];
    if (name is! String ||
        courses is! List ||
        classes is! List ||
        (firstName != null && firstName is! String) ||
        (lastName != null && lastName is! String) ||
        (email != null && email is! String) ||
        (department != null && department is! String)) {
      throw const FormatException('Invalid lecturer profile returned by API');
    }

    return LecturerProfile(
      firstName: firstName as String? ?? '',
      lastName: lastName as String? ?? '',
      name: name,
      email: email as String?,
      department: department as String?,
      courses: courses.map((course) {
        if (course is! Map<String, dynamic>) {
          throw const FormatException('Invalid course in lecturer profile');
        }
        return LecturerCourse.fromJson(course);
      }).toList(),
      classes: classes.map((entry) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('Invalid class in lecturer profile');
        }
        return LecturerClass.fromJson(entry);
      }).toList(),
    );
  }
}

class LecturerProfileService {
  const LecturerProfileService();

  Future<LecturerProfile> fetchProfile() async {
    final token = await const FlutterSecureStorage().read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw StateError('Sign in to load your lecturer dashboard.');
    }

    final uri = Uri.parse('${SignUpService.baseUrl}/lecturers/me');
    final response = await http
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 10));
    final decoded = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw Exception(message ?? 'Could not load lecturer profile');
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Lecturer profile API response is invalid');
    }
    return LecturerProfile.fromJson(decoded);
  }
}
