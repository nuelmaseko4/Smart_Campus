import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_connect/views/lecture/lecture_signup_screen.dart';
import 'package:uni_connect/views/login/login_screen.dart';
import 'package:uni_connect/views/options/option_dart.dart';

void main() {
  testWidgets('lecturer option opens lecturer signup form', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const OptionDart(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/lecturer-signup': (_) => const LectureSignUpScreen(),
        },
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Lecturer'));
    await tester.pumpAndSettle();

    expect(find.text('Lecturer Sign Up'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
  });

  testWidgets('student option still opens the shared login screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const OptionDart(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/lecturer-signup': (_) => const LectureSignUpScreen(),
        },
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Student'));
    await tester.pumpAndSettle();

    expect(find.text('Forgot Password?'), findsOneWidget);
  });
}
