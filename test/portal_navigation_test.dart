import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_connect/services/login_service.dart';
import 'package:uni_connect/services/student_activities_service.dart';
import 'package:uni_connect/services/student_profile_service.dart';
import 'package:uni_connect/views/lecture/lecture_home_page.dart';
import 'package:uni_connect/views/login/login_screen.dart';
import 'package:uni_connect/views/students/student_home_page.dart';
import 'package:uni_connect/widgets/app_navigation_bar.dart';

class _SuccessfulLoginService extends LoginService {
  @override
  Future<LoginResult> login({
    required String role,
    required String username,
    required String password,
  }) async {
    return const LoginResult(success: true, message: 'Welcome');
  }
}

class _LogoutTrackingService extends LoginService {
  bool didLogout = false;

  @override
  Future<void> logout() async {
    didLogout = true;
  }
}

class _StudentProfileStub extends StudentProfileService {
  @override
  Future<StudentProfile> fetchProfile() async {
    return const StudentProfile(
      studentId: 'STU123',
      email: 'student@example.com',
      courseName: 'Computer Science',
      courseCode: 'CS',
    );
  }
}

class _StudentActivitiesStub extends StudentActivitiesService {
  int roomSearchCount = 0;

  @override
  Future<List<StudentAttendance>> fetchAttendance() async => [];

  @override
  Future<List<StudentGateEntry>> fetchGateEntries() async => [];

  @override
  Future<List<AvailableRoom>> findAvailableRooms({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    roomSearchCount++;
    return const [AvailableRoom(name: 'R102', building: 'Main', capacity: 20)];
  }
}

void main() {
  testWidgets('student portal uses the shared navigation widget', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StudentHomePage(activitiesService: _StudentActivitiesStub()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppNavigationBar), findsOneWidget);
    expect(find.text('Student Portal'), findsOneWidget);
    expect(find.text('Student activities'), findsOneWidget);
    expect(find.text('Check attantance'), findsOneWidget);
    expect(find.text('Campus gate entry'), findsOneWidget);
    expect(find.text('Room availability'), findsOneWidget);

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    expect(find.text('Activity history'), findsOneWidget);
  });

  testWidgets('student profile confirms logout and opens login', (
    tester,
  ) async {
    final loginService = _LogoutTrackingService();
    await tester.pumpWidget(
      MaterialApp(
        home: StudentHomePage(
          activitiesService: _StudentActivitiesStub(),
          profileService: _StudentProfileStub(),
          loginService: loginService,
        ),
        routes: {
          '/login': (context) => const Scaffold(body: Text('Student login')),
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Student profile'), findsOneWidget);
    expect(find.text('STU123'), findsOneWidget);
    expect(find.text('student@example.com'), findsOneWidget);
    expect(find.text('Computer Science (CS)'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('student-logout')));
    await tester.pumpAndSettle();
    expect(loginService.didLogout, isFalse);

    await tester.tap(find.byKey(const ValueKey('confirm-logout')));
    await tester.pumpAndSettle();

    expect(loginService.didLogout, isTrue);
    expect(find.text('Student login'), findsOneWidget);
  });

  testWidgets('student can search and see available campus rooms', (
    tester,
  ) async {
    final service = _StudentActivitiesStub();
    await tester.pumpWidget(
      MaterialApp(home: StudentHomePage(activitiesService: service)),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('room-availability-search')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('room-availability-search')));
    await tester.pumpAndSettle();

    expect(service.roomSearchCount, 1);
    expect(find.text('R102'), findsOneWidget);
    expect(find.text('Main · Capacity 20'), findsOneWidget);
  });

  testWidgets('lecturer portal uses the shared navigation widget', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LectureHomePage()));

    expect(find.byType(AppNavigationBar), findsOneWidget);
    expect(find.text('Lecturer Portal'), findsOneWidget);
    expect(
      find.text('Your teaching overview will appear here.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Classes'));
    await tester.pumpAndSettle();

    expect(
      find.text('Your classes and timetable will appear here.'),
      findsOneWidget,
    );
  });

  testWidgets('lecturer login opens the lecturer portal', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(role: 'lecturer', service: _SuccessfulLoginService()),
        routes: {'/lecturer': (_) => const LectureHomePage()},
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'lecturer01');
    await tester.enterText(fields.at(1), 'password123');
    await tester.ensureVisible(find.text('Login as Lecturer'));
    await tester.tap(find.text('Login as Lecturer'));
    await tester.pumpAndSettle();

    expect(find.text('Lecturer Portal'), findsOneWidget);
    expect(find.byType(AppNavigationBar), findsOneWidget);
  });
}
