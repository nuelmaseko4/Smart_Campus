SMART UNIVERSITY MANAGEMENT SYSTEM — LOTTIE ANIMATION PACK

These are standalone Lottie JSON animations designed around the features described in the project presentation.

Files
1. 01_rfid_access.json — RFID campus entrance/access granted
2. 02_secure_attendance.json — RFID + face attendance verification
3. 03_wrong_class_alert.json — wrong classroom warning
4. 04_classroom_availability.json — room availability
5. 05_fire_detection_alert.json — IR fire detection + emergency alert
6. 06_secure_login_role.json — login + role-based access
7. 07_realtime_notifications.json — notification flow
8. 08_hardware_software_sync.json — hardware/software data synchronization
9. 09_smart_dashboard.json — animated dashboard overview
10. manifest.json — mapping of animations to project features

Flutter
Add the Lottie package to pubspec.yaml:
dependencies:
  lottie: ^3.3.1

Then place the JSON files under:
assets/animations/

and declare them in flutter:
  assets:
    - assets/animations/

Example:
import 'package:lottie/lottie.dart';

Lottie.asset(
  'assets/animations/01_rfid_access.json',
  repeat: true,
  fit: BoxFit.contain,
);

The animations are intentionally UI-neutral so you can place them inside your own Flutter screens without changing the project's architecture.
