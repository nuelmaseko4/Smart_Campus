import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:uni_connect/services/signup_services.dart';

class TimetableEntry {
  const TimetableEntry({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.unitName,
    required this.room,
    required this.building,
    required this.lecturer,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
  });

  final int id;
  final String courseCode;
  final String courseName;
  final String unitName;
  final String room;
  final String building;
  final String lecturer;
  final DateTime startTime;
  final DateTime endTime;
  final String dayOfWeek;

  factory TimetableEntry.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final courseCode = json['course_code'];
    final courseName = json['course_name'];
    final unitName = json['unit_name'];
    final room = json['room'];
    final building = json['building'];
    final lecturer = json['lecturer'];
    final startTime = json['start_time'];
    final endTime = json['end_time'];
    final dayOfWeek = json['day_of_week'];
    if (id is! int ||
        courseCode is! String ||
        courseName is! String ||
        unitName is! String ||
        room is! String ||
        building is! String ||
        lecturer is! String ||
        startTime is! String ||
        endTime is! String ||
        dayOfWeek is! String) {
      throw const FormatException('Invalid timetable entry returned by API');
    }
    return TimetableEntry(
      id: id,
      courseCode: courseCode,
      courseName: courseName,
      unitName: unitName,
      room: room,
      building: building,
      lecturer: lecturer,
      startTime: DateTime.parse(startTime),
      endTime: DateTime.parse(endTime),
      dayOfWeek: dayOfWeek,
    );
  }
}

class TimetableSchedule {
  const TimetableSchedule({
    required this.entries,
    this.courseName,
    this.year,
    this.semester,
  });

  final List<TimetableEntry> entries;
  final String? courseName;
  final int? year;
  final int? semester;
}

class TimetableService {
  const TimetableService();

  Future<TimetableSchedule> fetchSchedule({int? year, int? semester}) async {
    final token = await const FlutterSecureStorage().read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw StateError('Please log in again to view your timetable.');
    }

    final uri = Uri.parse('${SignUpService.baseUrl}/timetable').replace(
      queryParameters: {
        if (year != null) 'year': '$year',
        if (semester != null) 'semester': '$semester',
      },
    );
    final response = await http
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 10));
    final decoded = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString() ?? decoded['error']?.toString()
          : null;
      throw Exception(message ?? 'GET $uri failed (${response.statusCode})');
    }
    if (decoded is! Map<String, dynamic> || decoded['schedule'] is! List) {
      throw const FormatException('Invalid timetable response from API');
    }

    return TimetableSchedule(
      courseName: decoded['course_name'] as String?,
      year: decoded['year'] as int?,
      semester: decoded['semester'] as int?,
      entries: (decoded['schedule'] as List).map((entry) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('Invalid timetable entry from API');
        }
        return TimetableEntry.fromJson(entry);
      }).toList(),
    );
  }
}
