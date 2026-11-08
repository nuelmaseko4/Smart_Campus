import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:uni_connect/controllers/signup_controller.dart';
import 'package:uni_connect/models/signup_role.dart';
import 'package:uni_connect/services/login_service.dart';
import 'package:uni_connect/services/signup_services.dart';
import 'package:uni_connect/widgets/app_button.dart';
import 'package:uni_connect/widgets/app_dropdown_field.dart';
import 'package:uni_connect/widgets/app_text_field.dart';
import 'package:uni_connect/widgets/signup_page_layout.dart';

class StudentSignUpScreen extends StatefulWidget {
  const StudentSignUpScreen({
    super.key,
    this.service = const SignUpService(),
    this.loginService = const LoginService(),
  });

  final SignUpService service;
  final LoginService loginService;

  @override
  State<StudentSignUpScreen> createState() => _StudentSignUpScreenState();
}

class _StudentSignUpScreenState extends State<StudentSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SignUpController _controller;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    _controller = SignUpController(
      role: SignUpRole.student,
      service: widget.service,
    );
    _controller.loadCourses();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _controller.submit();
    if (!mounted) return;

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(result.message),
        ),
      );
      return;
    }

    setState(() => _authenticating = true);
    try {
      final loginResult = await widget.loginService.login(
        role: 'student',
        identifier: _controller.identityController.text.trim(),
        password: _controller.passwordController.text,
      );
      if (!mounted) return;

      if (!loginResult.success) {
        _returnToLogin(
          'Account created, but automatic login failed: ${loginResult.message}',
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created. Welcome!')),
      );
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/student', (route) => false);
    } catch (error, stackTrace) {
      debugPrint('Automatic login after signup failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      _returnToLogin(
        'Account created, but automatic login failed. Please log in.',
      );
    } finally {
      if (mounted) setState(() => _authenticating = false);
    }
  }

  void _returnToLogin(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red.shade700, content: Text(message)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SignupPageLayout(
      title: 'Student Sign Up',
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) => Form(
          key: _formKey,
          child: Column(
            children: [
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: AppTextField(
                  controller: _controller.identityController,
                  label: 'Student number',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: _controller.validateIdentity,
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 1100),
                child: AppTextField(
                  controller: _controller.emailController,
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _controller.validateEmail,
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 1200),
                child: AppDropdownField(
                  label: 'Course',
                  icon: Icons.school_outlined,
                  helperText: 'Tap to search by course name',
                  options: _controller.courseOptions,
                  selectedValue: _controller.selectedCourse,
                  isLoading: _controller.isLoadingCourses,
                  onSelected: _controller.selectCourse,
                  validator: _controller.validateCourse,
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 1250),
                child: AppDropdownField(
                  label: 'Year of study',
                  icon: Icons.calendar_today_outlined,
                  helperText: 'Select your current year',
                  options: _controller.yearOfStudyOptions,
                  selectedValue: _controller.selectedYearOfStudy?.toString(),
                  onSelected: _controller.selectYearOfStudy,
                  validator: (value) =>
                      value == null ? 'Please select your year of study' : null,
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 1300),
                child: AppTextField(
                  controller: _controller.passwordController,
                  label: 'Password',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _visibilityButton(
                    isHidden: _controller.hidePassword,
                    onPressed: _controller.togglePasswordVisibility,
                  ),
                  obscureText: _controller.hidePassword,
                  validator: _controller.validatePassword,
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 1400),
                child: AppTextField(
                  controller: _controller.confirmPasswordController,
                  label: 'Confirm Password',
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: _visibilityButton(
                    isHidden: _controller.hideConfirmPassword,
                    onPressed: _controller.toggleConfirmPasswordVisibility,
                  ),
                  obscureText: _controller.hideConfirmPassword,
                  validator: _controller.validateConfirmPassword,
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                duration: const Duration(milliseconds: 1500),
                child: AppButton(
                  text: 'Sign Up',
                  onPressed: _submit,
                  isLoading:
                      _controller.isLoadingCourses ||
                      _controller.isSubmitting ||
                      _authenticating,
                  enabled: _controller.courseLoadError == null,
                ),
              ),
              if (_controller.courseLoadError != null)
                TextButton(
                  onPressed: _controller.loadCourses,
                  child: Text(_controller.courseLoadError!),
                ),
              const SizedBox(height: 12),
              _loginPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _visibilityButton({
    required bool isHidden,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isHidden ? Icons.visibility_off : Icons.visibility,
        color: Colors.grey,
      ),
    );
  }

  Widget _loginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.grey),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Login',
            style: TextStyle(
              color: Colors.orange.shade900,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
