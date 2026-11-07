import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_connect/services/login_service.dart';
import 'package:uni_connect/views/login/login_screen.dart';

class _FakeLoginService extends LoginService {
  bool called = false;

  @override
  Future<LoginResult> login({
    required String role,
    required String username,
    required String password,
  }) async {
    called = true;
    expect(role, 'student');
    expect(username, '123456');
    expect(password, 'password123');
    return const LoginResult(success: true, message: 'Welcome');
  }
}

void main() {
  testWidgets('login submits credentials and opens the student portal', (
    tester,
  ) async {
    final service = _FakeLoginService();
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(role: 'student', service: service),
        routes: {'/student': (_) => const Text('Student Portal')},
      ),
    );
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '123456');
    await tester.enterText(fields.at(1), 'password123');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(service.called, isTrue);
    expect(find.text('Student Portal'), findsOneWidget);
  });
}
