import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uni_connect/widgets/app_text_field.dart';

void main() {
  testWidgets('AppTextField applies input options and validation', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: AppTextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Required' : null,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).keyboardType,
      TextInputType.emailAddress,
    );
    expect(formKey.currentState!.validate(), isFalse);

    controller.text = 'student@example.com';
    expect(formKey.currentState!.validate(), isTrue);
  });
}
