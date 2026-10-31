import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:uni_connect/controllers/signup_controller.dart';
import 'package:uni_connect/models/signup_role.dart';
import 'package:uni_connect/widgets/app_button.dart';
import 'package:uni_connect/widgets/app_dropdown_field.dart';
import 'package:uni_connect/widgets/app_text_field.dart';
import 'package:uni_connect/widgets/signup_page_layout.dart';

class LectureSignUpScreen extends StatefulWidget {
  const LectureSignUpScreen({super.key});

  @override
  State<LectureSignUpScreen> createState() => _LectureSignUpScreenState();
}

class _LectureSignUpScreenState extends State<LectureSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SignUpController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignUpController(role: SignUpRole.lecturer);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _controller.submit();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: result.success
            ? Colors.orange.shade900
            : Colors.red.shade700,
        content: Text(result.message),
      ),
    );

    if (result.success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SignupPageLayout(
      title: 'Lecturer Sign Up',
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
                  label: 'Username',
                  prefixIcon: Icons.badge_outlined,
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
                  options: _controller.courseOptions,
                  selectedValue: _controller.selectedCourse,
                  onSelected: _controller.selectCourse,
                  validator: _controller.validateCourse,
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
                  isLoading: _controller.isSubmitting,
                ),
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
