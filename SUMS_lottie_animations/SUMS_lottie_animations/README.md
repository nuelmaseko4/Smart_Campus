# Smart University Management System - 24 Lottie (JSON) animations

Made from SMART_UNIVERSITY_MANAGEMENT_SYSTEM.pptx (BSC 121). Colours follow the deck theme (dark teal, red, orange, yellow, green).
Every file is vector shapes only - no images, fonts, text, expressions or effects - so it plays in any Lottie player
(Flutter `lottie`, lottie-web, Android, iOS, LottieFiles) and stays tiny (95s of animation in about 473 KB).

## Contents
| # | File | Size | Length | Plays | Deck slides | Use it for |
|---|------|------|--------|-------|-------------|------------|
| 1 | `gate_access_granted.json` | 640x512 | 4.0s | loop | 10, 14, 19, 20 | Gate / campus-entrance scan result screen |
| 2 | `gate_access_denied.json` | 640x512 | 4.0s | loop | 4, 14, 20 | Gate / campus-entrance scan result screen |
| 3 | `rfid_card_scan.json` | 512x512 | 2.0s | loop | 10, 19, 21 | "Tap your card" prompt on gate and attendance scan screens |
| 4 | `face_recognition_scan.json` | 512x512 | 4.0s | once | 10, 21, 33 | Face-verification step of class attendance |
| 5 | `attendance_marked.json` | 512x512 | 4.0s | once | 10, 19, 33, 38 | Attendance confirmation after an RFID tap in class |
| 6 | `proxy_attendance_blocked.json` | 512x512 | 4.0s | once | 4, 14, 33 | Shown when a scanned card does not match the face in front of the camera |
| 7 | `wrong_classroom_alert.json` | 512x512 | 4.0s | once | 4, 33 | In-app warning when a card is scanned in the wrong room |
| 8 | `gate_queue_manual_vs_rfid.json` | 800x450 | 5.0s | once | 3, 4, 20 | Problem vs solution: slow manual ID checks against fast RFID scanning |
| 9 | `fire_detected_alert.json` | 512x512 | 4.0s | loop | 10, 21, 32 | Fire emergency screen: IR flame sensor triggers siren and notifies admin + security |
| 10 | `fire_alert_flow.json` | 800x450 | 5.0s | once | 32, 35 | Fire alert pipeline: flame sensor > network > server > dashboard, security phone and event log |
| 11 | `classroom_availability.json` | 512x512 | 5.0s | loop | 10, 30 | Live free / occupied classroom grid |
| 12 | `classroom_booking_confirmed.json` | 512x512 | 4.0s | once | 30, 31 | Book-a-classroom flow ending in a confirmation |
| 13 | `time_slot_conflict.json` | 512x512 | 4.0s | once | 30 | Booking rejected because the time slot is already taken |
| 14 | `secure_login.json` | 512x512 | 4.0s | once | 10, 19, 31 | Secure login: credentials typed, lock opens, access confirmed |
| 15 | `role_based_access.json` | 512x512 | 5.0s | once | 9, 10, 16, 17, 31 | Student, lecturer, admin and security guard with different permission levels |
| 16 | `push_notification_bell.json` | 512x512 | 3.0s | loop | 10, 20, 32 | Push-notification / alert bell for new messages and warnings |
| 17 | `attendance_report_dashboard.json` | 512x512 | 5.0s | once | 31, 38 | Attendance / usage report: bars grow, trend line draws, percentage ring fills |
| 18 | `system_architecture_layers.json` | 800x450 | 5.0s | once | 35 | Three-layer architecture (perception, network, application) with data packets flowing |
| 19 | `tech_stack_data_flow.json` | 800x450 | 5.0s | once | 25, 26 | Flutter app <> Python backend <> C++ bridge > Arduino hardware, with data and commands flowing |
| 20 | `smart_campus_intro.json` | 800x450 | 6.0s | loop | 1, 6, 40 | Hero / title animation: smart campus with orbiting card, flame, phone and bell |
| 21 | `sums_logo_splash.json` | 512x512 | 3.3s | once | 1, 40 | App splash / opening logo: shield, graduation cap and the SUMS wordmark |
| 22 | `success_check.json` | 256x256 | 2.0s | once | - | Generic success tick for forms, saves and confirmations |
| 23 | `error_cross.json` | 256x256 | 2.0s | once | - | Generic error cross for failed actions, denied access and validation errors |
| 24 | `loading_spinner.json` | 256x256 | 2.0s | loop | - | Seamless loop for waiting states while data loads |

## Use in your Flutter app (slide 25: Flutter + Dart front end)
```yaml
dependencies:
  lottie: ^3.1.0
flutter:
  assets:
    - assets/animations/
```
```dart
Lottie.asset('assets/animations/gate_access_granted.json', repeat: false)   // "once" files
Lottie.asset('assets/animations/loading_spinner.json', repeat: true)        // "loop" files
```

## Use on a web page
```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/lottie-web/5.12.2/lottie.min.js"></script>
<div id="a" style="width:300px"></div>
<script>lottie.loadAnimation({container: document.getElementById('a'), path: 'animations/rfid_card_scan.json', loop: true});</script>
```

## Use inside PowerPoint
PowerPoint cannot play Lottie JSON directly. Use the GIFs in `gif_previews/` (Insert > Pictures) to put the same animations on your slides.

## Preview everything
Open `preview.html` in a browser (needs internet for the lottie-web library). Click a card to replay it.
