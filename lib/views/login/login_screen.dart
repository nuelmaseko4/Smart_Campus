import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:uni_connect/services/login_service.dart';
import 'package:uni_connect/widgets/login_widgets/login_form.dart';
import 'package:uni_connect/widgets/login_widgets/login_header.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
    this.role = 'student',
    this.service = const LoginService(),
  });

  final String role;
  final LoginService service;

  String get _normalizedRole =>
      role.trim().toLowerCase() == 'lecturer' ? 'lecturer' : 'student';

  Future<void> _openSignup(BuildContext context) async {
    final route = _normalizedRole == 'lecturer'
        ? '/lecturer-signup'
        : '/student-signup';
    final result = await Navigator.of(context).pushNamed(route);
    if (!context.mounted || result == null || result == false) return;

    final message = result is String && result.isNotEmpty
        ? result
        : 'Account created. Please log in.';
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange.shade900,
              Colors.orange.shade800,
              Colors.orange.shade400,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            const LoginHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        LoginForm(
                          role: _normalizedRole,
                          service: service,
                          onAuthenticated: () {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              _normalizedRole == 'lecturer'
                                  ? '/lecturer'
                                  : '/student',
                              (route) => false,
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1500),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeInUp(
                          duration: const Duration(milliseconds: 1600),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Don't have an account? ",
                                style: TextStyle(color: Colors.grey),
                              ),
                              TextButton(
                                onPressed: () => _openSignup(context),
                                child: Text(
                                  'Sign up',
                                  style: TextStyle(
                                    color: Colors.orange.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
