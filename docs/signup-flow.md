# Signup code guide

This guide explains where the signup screen, reusable widgets, form behavior,
and API requests live.

## How the signup screen is built

1. `lib/main.dart` registers `/student-signup` and `/lecturer-signup`.
2. The matching screen in `lib/views/` chooses the page title and creates a
   controller for its role.
3. `SignupPageLayout` provides the shared gradient, header, and rounded white
   panel.
4. Each screen composes its own `AppTextField`, `AppDropdownField`, and
   `AppButton` widgets, passing labels, icons, controllers, validators, and
   callbacks.
5. The controller validates values and calls `SignUpService` when that role
   has an implemented backend flow.
6. After student signup succeeds, the screen signs the student in and opens the
   student portal. If automatic login fails, it returns to the login screen.

## Files and responsibilities

| File | Responsibility |
|---|---|
| `lib/views/signup/student_signup_screen.dart` | Student view: composes the student fields and connects them to a student controller. |
| `lib/views/lecture/lecture_signup_screen.dart` | Lecturer view: composes the lecturer fields and connects them to a lecturer controller. |
| `lib/widgets/signup_page_layout.dart` | Shared page design: gradient, title/back button, rounded panel, and scrolling. |
| `lib/widgets/app_text_field.dart` | Reusable text input. Pass a label, icon, controller, keyboard type, validator, and optional password behavior. |
| `lib/widgets/app_dropdown_field.dart` | Reusable styled dropdown for choosing a course or another option list. |
| `lib/widgets/app_button.dart` | Reusable button, including loading and disabled states. |
| `lib/controllers/signup_controller.dart` | Signup behavior: text controllers, validation, course loading, password visibility, and submission coordination. |
| `lib/models/signup_role.dart` | Defines the student and lecturer signup roles. |
| `lib/services/signup_services.dart` | HTTP calls and response parsing for fetching courses and creating student accounts. |

## Where to make common changes

### Add or remove a text field

1. Add or remove an `AppTextField` in the relevant view:
   `student_signup_screen.dart` or `lecture_signup_screen.dart`.
2. Pass the field's label, icon, controller, keyboard type, and validator to
   the reusable widget.
3. Add the matching `TextEditingController` and validation method in
   `lib/controllers/signup_controller.dart`.
4. If the value must be sent to the server, update the signup method in
   `lib/services/signup_services.dart` and the controller's `submit()` call.

The student and lecturer screens compose their fields independently. They can
have different labels and fields while reusing the same widgets and styling.

### Change appearance

- Change the overall signup page layout in
  `lib/widgets/signup_page_layout.dart`.
- Change the shared text input styling in
  `lib/widgets/app_text_field.dart`.
- Change the shared dropdown styling in
  `lib/widgets/app_dropdown_field.dart`.
- Change field order or labels in the relevant screen under `lib/views/`.
- Change the shared button appearance in `lib/widgets/app_button.dart`.

### Connect lecturer signup to a backend

The lecturer screen has its own field composition and a static course list,
but its `submit()` path intentionally returns “Lecturer signup is not
connected yet.” It does not create an account. Implement the lecturer request
in `SignUpService`, then call it from the lecturer branch in
`SignUpController.submit()`.

## Current student signup flow

- `SignUpController.loadCourses()` asks `SignUpService.fetchCourses()` for
  courses when the student form opens.
- Selecting a course enables the year-of-study picker, whose options run from
  year 1 through that course's duration.
- `SignUpController.submit()` passes the student number, email, course, year
  of study, and password to `SignUpService.signUp()`.
- The service sends a `POST` request to `/signup` and returns a success flag
  and message. On success, the signup screen sends the same student number and
  password to `/login`; a successful login opens the student portal directly.
- The course picker is searchable on Android: tap the field and type part of a
  course name.

## Student and lecturer portal navigation

- `lib/widgets/app_navigation_bar.dart` provides the shared bottom navigation
  widget and accepts each portal's own destinations.
- `lib/views/students/student_home_page.dart` is the student portal page.
- `lib/views/lecture/lecture_home_page.dart` uses the same navigation widget
  for the lecturer portal.
- Successful student and lecturer logins open their matching portal routes.

## Run the student flow on an Android phone with Flask

The Flask API lives in `lib/api`. For USB debugging, start it from that folder
on the development computer:

```powershell
Set-Location lib\api
python -m flask --app app run --host 127.0.0.1 --port 5000 --no-debugger
```

In VS Code, select **UniConnect (Android phone via USB)** in Run and Debug.
Its pre-launch task runs `adb reverse` for port 5000, and its Dart define points
the app at `http://127.0.0.1:5000` on the phone. Keep the phone connected with
USB debugging enabled. The API should respond at `/` and `/courses` on the
development computer before launching the Flutter app.

Debug Android builds allow cleartext HTTP for this local development API. That
setting is limited to `src/debug`; use HTTPS and a production server for
release builds. The phone and computer can instead communicate over Wi-Fi, but
that requires Flask to listen on the computer's LAN interface and the app's
`API_BASE_URL` Dart define to use the computer's current LAN IP.

For Wi-Fi debugging, select **UniConnect (Android phone via Wi-Fi)** in Run and
Debug. Update the `API_BASE_URL` in `.vscode/launch.json` to the computer's
current IPv4 address if it is different from `192.168.1.145`. Connect both
devices to the same trusted Wi-Fi network. Flask must listen on `0.0.0.0`, and
Windows Firewall must allow inbound TCP port 5000 on the Private profile.

### Standalone profile APK over Wi-Fi

For a standalone, non-debuggable test build, connect the phone and computer to
the same trusted Wi-Fi network. Find the computer's current IPv4 address with
`ipconfig`, then allow inbound TCP port 5000 through Windows Firewall on the
Private profile only (run PowerShell as Administrator):

```powershell
New-NetFirewallRule -DisplayName "UniConnect Flask (Private Wi-Fi)" `
  -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5000 `
  -Profile Private
```

Start Flask so it listens on the LAN interface:

```powershell
Set-Location lib\api
python -m flask --app app run --host 0.0.0.0 --port 5000 --no-debugger
```

Replace `192.168.1.145` below with the computer's current IPv4 address. Open
`http://192.168.1.145:5000/` in the phone's browser first; it should show
`uni_connect API is running`. Then build a standalone profile APK:

```powershell
flutter build apk --profile `
  --dart-define=API_BASE_URL=http://192.168.1.145:5000
```

Install `build\app\outputs\flutter-apk\app-profile.apk` on the phone (for
example, copy it to the phone and open it). Profile builds permit cleartext
HTTP only to support this trusted-LAN test setup. Do not distribute that
profile APK or use HTTP beyond a trusted local network; use HTTPS for release
builds. The app needs rebuilding if the computer's LAN IP changes.

The Flutter student service expects:

- `GET /courses` to return a JSON list containing integer `id`, string
  `course_name`, and integer `duration` values.
- `POST /signup` to accept `student_id`, `email`, `course_name`,
  `year_of_study`, and `password`. The year must be between 1 and the selected
  course's duration. Successful requests return HTTP 201 and a JSON `message`.
- `POST /login` to accept `role`, `username` (the student number for students),
  and `password`, returning HTTP 200 with a non-empty `token`.

## Tests

- `test/student_signup_flow_test.dart` covers student course loading,
  submission, and navigation.
- `test/role_selection_navigation_test.dart` covers opening the lecturer
  signup page from role selection.
- `test/signup_controller_test.dart` covers the unimplemented lecturer
  submission result.
- `test/app_text_field_test.dart` covers the reusable text input.

Run the signup-related tests with:

```powershell
flutter test test\student_signup_flow_test.dart test\role_selection_navigation_test.dart test\signup_controller_test.dart test\app_text_field_test.dart
```
