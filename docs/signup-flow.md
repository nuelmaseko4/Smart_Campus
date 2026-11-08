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
6. The screen displays the result and navigates back after success.

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
- Selecting a course and completing valid fields enables submission.
- `SignUpController.submit()` passes the student number, email, course, and
  password to `SignUpService.signUp()`.
- The service sends a `POST` request to `/signup` and returns a success flag
  and message. The form shows that message and returns `true` to the previous
  screen on success.

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
