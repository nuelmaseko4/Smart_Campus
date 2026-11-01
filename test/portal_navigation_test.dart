import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_connect/services/login_service.dart';
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

void main() {
  testWidgets('student portal uses the shared navigation widget', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: StudentHomePage()));

    expect(find.byType(AppNavigationBar), findsOneWidget);
    expect(find.text('Student Portal'), findsOneWidget);
    expect(find.text('Your campus activity will appear here.'), findsOneWidget);

    await tester.tap(find.text('History').last);
    await tester.pumpAndSettle();

    expect(
      find.text('Your attendance and activity history will appear here.'),
      findsOneWidget,
    );
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
