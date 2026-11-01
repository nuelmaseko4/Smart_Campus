import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

import 'package:uni_connect/services/login_service.dart';
import 'package:uni_connect/widgets/app_button.dart';
import 'package:uni_connect/widgets/app_text_field.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.role,
    required this.onAuthenticated,
    this.service = const LoginService(),
  });

  final String role; // 'student' or 'lecturer'
  final VoidCallback onAuthenticated;
  final LoginService service;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    try {
      // The service handles sending the correct JSON based on the role
      final result = await widget.service.login(
        role: widget.role,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      setState(() => _submitting = false);

      if (!result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text(result.message),
          ),
        );
        return;
      }

      widget.onAuthenticated();
    } catch (error, stackTrace) {
      debugPrint('Login request failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: const Text('Could not log in. Check the API and try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 👈 1. Determine what to show based on the role
    final isStudent = widget.role == 'student';
    final inputHint = isStudent ? 'Student ID number' : 'Username';
    final inputIcon = isStudent ? Icons.badge_outlined : Icons.person_outline;
    final buttonText = isStudent ? 'Login' : 'Login as Lecturer';

    return FadeInUp(
      duration: const Duration(milliseconds: 1400),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(225, 95, 27, .3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // --- ID / Username Field ---
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: AppTextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: inputHint, // 👈 Dynamic hint
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: Icon(inputIcon), // 👈 Dynamic icon
                    border: InputBorder.none,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter your $inputHint'
                      : null,
                ),
              ),

              // --- Password Field ---
              Container(
                padding: const EdgeInsets.all(10),
                child: AppTextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.lock_outline),
                    border: InputBorder.none,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Enter your password'
                      : null,
                ),
              ),

              // --- Reusable Submit Button ---
              Padding(
                padding: const EdgeInsets.all(10),
                child: AppButton(
                  text: buttonText, // 👈 Dynamic button text
                  icon: isStudent ? Icons.school : Icons.work,
                  isLoading: _submitting,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
