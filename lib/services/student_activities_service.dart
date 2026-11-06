import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'signup_services.dart';

class StudentAttendance {
  const StudentAttendance({
    required this.unitName,
    required this.courseName,
    required this.status,
    required this.startTime,
  });

  final String unitName;
  final String courseName;
  final String status;
  final DateTime startTime;

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    final unitName = json['unit_name'];
    final courseName = json['course_name'];
    final status = json['status'];
    final startTime = json['start_time'];
    if (unitName is! String ||
        courseName is! String ||
        status is! String ||
        startTime is! String) {
      throw const FormatException('Invalid attendance record from the API');
    }

    return StudentAttendance(
      unitName: unitName,
      courseName: courseName,
      status: status,
      startTime: DateTime.parse(startTime),
    );
  }
}

class StudentGateEntry {
  const StudentGateEntry({
    required this.accessPoint,
    required this.scannedAt,
  });

  final String accessPoint;
  final DateTime scannedAt;

  factory StudentGateEntry.fromJson(Map<String, dynamic> json) {
    final accessPoint = json['access_point'];
    final scannedAt = json['scanned_at'];
    if (accessPoint is! String || scannedAt is! String) {
      throw const FormatException('Invalid gate entry from the API');
    }

    return StudentGateEntry(
      accessPoint: accessPoint,
      scannedAt: DateTime.parse(scannedAt),
    );
  }
}

class AvailableRoom {
  const AvailableRoom({
    required this.name,
    required this.building,
    required this.capacity,
  });

  final String name;
  final String building;
  final int capacity;

  factory AvailableRoom.fromJson(Map<String, dynamic> json) {
    final name = json['room_name'];
    final building = json['building'];
    final capacity = json['capacity'];
    if (name is! String || building is! String || capacity is! int) {
      throw const FormatException('Invalid room returned by the API');
    }
    return AvailableRoom(name: name, building: building, capacity: capacity);
  }
}

class StudentActivitiesService {
  const StudentActivitiesService();

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final token = await const FlutterSecureStorage().read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('Please log in again to view your student activities.');
    }

    final response = await http
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 10));
    final decoded = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw Exception(
        message ?? 'GET $uri failed (${response.statusCode})',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid response from the student API');
    }
    return decoded;
  }

  Future<List<StudentAttendance>> fetchAttendance() async {
    final response = await _get(
      Uri.parse('${SignUpService.baseUrl}/students/me/attendance'),
    );
    final records = response['records'];
    if (records is! List) {
      throw const FormatException('Attendance response has no records list');
    }
    return records.map((record) {
      if (record is! Map<String, dynamic>) {
        throw const FormatException('Invalid attendance record from the API');
      }
      return StudentAttendance.fromJson(record);
    }).toList();
  }

  Future<List<StudentGateEntry>> fetchGateEntries() async {
    final token = await const FlutterSecureStorage().read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('Please log in again to view your student activities.');
    }

    final uri = Uri.parse('${SignUpService.baseUrl}/students/me/gate-entries');
    final response = await http
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 10));
    final decoded = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw Exception(
        message ?? 'GET $uri failed (${response.statusCode})',
      );
    }
    if (decoded is! List) {
      throw const FormatException('Gate entries response must be a list');
    }
    return decoded.map((entry) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Invalid gate entry from the API');
      }
      return StudentGateEntry.fromJson(entry);
    }).toList();
  }

  Future<List<AvailableRoom>> findAvailableRooms({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final uri = Uri.parse('${SignUpService.baseUrl}/rooms/availability')
        .replace(
          queryParameters: {
            'start_time': startTime.toIso8601String(),
            'end_time': endTime.toIso8601String(),
          },
        );
    final token = await const FlutterSecureStorage().read(key: 'access_token');
    if (token == null || token.isEmpty) {
      throw Exception('Please log in again to check room availability.');
    }

    final response = await http
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 10));
    final decoded = jsonDecode(response.body);
    if (response.statusCode != 200) {
      final message = decoded is Map<String, dynamic>
          ? decoded['message']?.toString()
          : null;
      throw Exception(
        message ?? 'GET $uri failed (${response.statusCode})',
      );
    }
    if (decoded is! Map<String, dynamic> || decoded['rooms'] is! List) {
      throw const FormatException('Invalid room availability response');
    }
    return (decoded['rooms'] as List).map((room) {
      if (room is! Map<String, dynamic>) {
        throw const FormatException('Invalid room returned by the API');
      }
      return AvailableRoom.fromJson(room);
    }).toList();
  }
}
