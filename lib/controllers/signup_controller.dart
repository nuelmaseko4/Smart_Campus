import 'package:flutter/material.dart';
import 'package:uni_connect/models/signup_role.dart';
import 'package:uni_connect/services/signup_services.dart';

class SignUpSubmissionResult {
  const SignUpSubmissionResult({required this.success, required this.message});

  final bool success;
  final String message;
}

class SignUpController extends ChangeNotifier {
  SignUpController({required this.role, this.service = const SignUpService()});

  static const _lecturerCourses = [
    'Computer Science',
    'Information Technology',
    'Software Engineering',
    'Business Administration',
    'Accounting and Finance',
    'Civil Engineering',
    'Electrical Engineering',
    'Nursing',
    'Education',
    'Law',
  ];

  final SignUpRole role;
  final SignUpService service;
  final identityController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  List<Course> _courses = [];
  String? selectedCourse;
  String? courseLoadError;
  bool isLoadingCourses = false;
  bool isSubmitting = false;
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool _isDisposed = false;

  bool get isStudent => role == SignUpRole.student;
  List<String> get courseOptions => isStudent
      ? _courses.map((course) => course.name).toList()
      : _lecturerCourses;
  List<String> get yearOfStudyOptions {
    final course = _selectedCourse;
    if (course == null) return [];
    return List.generate(course.duration, (index) => '${index + 1}');
  }

  Course? get _selectedCourse {
    for (final course in _courses) {
      if (course.name == selectedCourse) return course;
    }
    return null;
  }

  int? selectedYearOfStudy;

  Future<void> loadCourses() async {
    if (!isStudent) return;

    isLoadingCourses = true;
    courseLoadError = null;
    _notifyIfActive();

    try {
      _courses = await service.fetchCourses();
      if (_isDisposed) return;
      isLoadingCourses = false;
      _notifyIfActive();
    } catch (error, stackTrace) {
      debugPrint('Could not load courses: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (_isDisposed) return;
      isLoadingCourses = false;
      courseLoadError =
          'Could not load courses from ${SignUpService.baseUrl}. '
          'Check that Flask is running and USB port forwarding is active, then retry.';
      _notifyIfActive();
    }
  }

  String? validateIdentity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return isStudent
          ? 'Please enter your student number'
          : 'Please enter your username';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? validateCourse(String? value) {
    return value == null ? 'Please select your course' : null;
  }

  void selectCourse(String? value) {
    selectedCourse = value;
    selectedYearOfStudy = null;
    _notifyIfActive();
  }

  void selectYearOfStudy(String? value) {
    selectedYearOfStudy = value == null ? null : int.tryParse(value);
  }

  void togglePasswordVisibility() {
    hidePassword = !hidePassword;
    _notifyIfActive();
  }

  void toggleConfirmPasswordVisibility() {
    hideConfirmPassword = !hideConfirmPassword;
    _notifyIfActive();
  }

  Future<SignUpSubmissionResult> submit() async {
    if (isStudent && (isLoadingCourses || courseLoadError != null)) {
      return const SignUpSubmissionResult(
        success: false,
        message: 'Courses are unavailable. Please try again.',
      );
    }

    if (!isStudent) {
      return const SignUpSubmissionResult(
        success: false,
        message: 'Lecturer signup is not connected yet.',
      );
    }
    if (selectedCourse == null) {
      return const SignUpSubmissionResult(
        success: false,
        message: 'Please select your course.',
      );
    }
    if (selectedYearOfStudy == null) {
      return const SignUpSubmissionResult(
        success: false,
        message: 'Please select your year of study.',
      );
    }

    isSubmitting = true;
    _notifyIfActive();

    try {
      final result = await service.signUp(
        studentNumber: identityController.text.trim(),
        email: emailController.text.trim(),
        courseName: selectedCourse!,
        yearOfStudy: selectedYearOfStudy!,
        password: passwordController.text,
      );
      return SignUpSubmissionResult(
        success: result.success,
        message: result.message,
      );
    } catch (error, stackTrace) {
      debugPrint('Student signup failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return const SignUpSubmissionResult(
        success: false,
        message: 'Could not create account. Please try again.',
      );
    } finally {
      if (!_isDisposed) {
        isSubmitting = false;
        _notifyIfActive();
      }
    }
  }

  void _notifyIfActive() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    identityController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
