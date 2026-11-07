import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

void main() {
  test('Secure attendance animation parses', () {
    final bytes = File(
      'assests/animations/from_claude/02_secure_attendance.json',
    ).readAsBytesSync();

    expect(
      LottieComposition.parseJsonBytes(bytes).duration.inMilliseconds,
      greaterThan(0),
    );
  });
}
