import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_connect/widgets/signup_widgets/signup_form.dart';

void main() {
  testWidgets('course dropdown opens and allows selecting a course', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: SignUpForm())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownMenu<String>));
    await tester.pumpAndSettle();

    expect(find.text('Computer Science'), findsOneWidget);

    await tester.tap(find.text('Computer Science'));
    await tester.pumpAndSettle();

    expect(find.text('Computer Science'), findsOneWidget);
  });
}
