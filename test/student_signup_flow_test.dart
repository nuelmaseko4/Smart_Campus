import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_connect/services/login_service.dart';
import 'package:uni_connect/services/signup_services.dart';
import 'package:uni_connect/views/login/login_screen.dart';
import 'package:uni_connect/views/signup/student_signup_screen.dart';

class _FakeSignUpService extends SignUpService {
  bool coursesRequested = false;
  bool signupCalled = false;
  String? submittedStudentNumber;
  String? submittedEmail;
  String? submittedCourse;

  @override
  Future<List<Course>> fetchCourses() async {
    coursesRequested = true;
    return const [Course(id: 1, name: 'Computer Science')];
  }

  @override
  Future<SignUpResult> signUp({
    required String studentNumber,
    required String email,
    required String courseName,
    required String password,
  }) async {
    signupCalled = true;
    submittedStudentNumber = studentNumber;
    submittedEmail = email;
    submittedCourse = courseName;
    return SignUpResult(success: true, message: 'Created');
  }
}

class _FakeLoginService extends LoginService {
  bool loginCalled = false;

  @override
  Future<LoginResult> login({
    required String role,
    required String username,
    required String password,
  }) async {
    loginCalled = true;
    expect(role, 'student');
    expect(username, '123456');
    expect(password, 'password123');
    return const LoginResult(success: true, message: 'Welcome');
  }
}

void main() {
  testWidgets('login sign-up link opens student registration', (tester) async {
    final service = _FakeSignUpService();
    await tester.pumpWidget(
      MaterialApp(
        home: const LoginScreen(),
        routes: {
          '/student-signup': (_) => StudentSignUpScreen(service: service),
        },
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sign up'));
    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Student Sign Up'), findsOneWidget);
    expect(find.text('Student number'), findsOneWidget);
    expect(find.text('Course'), findsOneWidget);
    expect(service.coursesRequested, isTrue);
  });

  testWidgets(
    'student signup creates the account, logs in, and opens the portal',
    (tester) async {
      final service = _FakeSignUpService();
      final loginService = _FakeLoginService();
      await tester.pumpWidget(
        MaterialApp(
          home: StudentSignUpScreen(
            service: service,
            loginService: loginService,
          ),
          routes: {'/student': (_) => const Text('Student Portal')},
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '123456');
      await tester.enterText(fields.at(1), 'student@example.com');
      await tester.enterText(fields.at(2), 'password123');
      await tester.enterText(fields.at(3), 'password123');

      await tester.tap(find.byType(DropdownMenuFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Computer Science').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(service.signupCalled, isTrue);
      expect(service.submittedStudentNumber, '123456');
      expect(service.submittedEmail, 'student@example.com');
      expect(service.submittedCourse, 'Computer Science');
      expect(loginService.loginCalled, isTrue);
      expect(find.text('Student Portal'), findsOneWidget);
      expect(find.text('Student Sign Up'), findsNothing);
    },
  );
}
