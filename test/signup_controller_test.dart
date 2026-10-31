import 'package:flutter_test/flutter_test.dart';
import 'package:uni_connect/controllers/signup_controller.dart';
import 'package:uni_connect/models/signup_role.dart';

void main() {
  test(
    'lecturer signup reports that backend integration is unavailable',
    () async {
      final controller = SignUpController(role: SignUpRole.lecturer);
      addTearDown(controller.dispose);

      final result = await controller.submit();

      expect(result.success, isFalse);
      expect(result.message, 'Lecturer signup is not connected yet.');
    },
  );
}
