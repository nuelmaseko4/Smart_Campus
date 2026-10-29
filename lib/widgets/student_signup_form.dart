import 'package:flutter/material.dart';
import 'package:uni_connect/services/signup_services.dart';

class StudentSignUpForm extends StatefulWidget {
  const StudentSignUpForm({super.key, this.service = const SignUpService()});

  final SignUpService service;

  @override
  State<StudentSignUpForm> createState() => _StudentSignUpFormState();
}

class _StudentSignUpFormState extends State<StudentSignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _studentNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  List<Course> _courses = [];
  String? _selectedCourse;
  String? _courseError;
  bool _loadingCourses = true;
  bool _submitting = false;
  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _studentNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadCourses() async {
    setState(() {
      _loadingCourses = true;
      _courseError = null;
    });

    try {
      final courses = await widget.service.fetchCourses();
      if (!mounted) return;
      setState(() {
        _courses = courses;
        _loadingCourses = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Could not load signup courses: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _courseError =
            'Could not load courses. Check your connection and retry.';
        _loadingCourses = false;
      });
    }
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade600),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.orange.shade800, width: 1.5),
      ),
    );
  }

  Future<void> _submit() async {
    if (_loadingCourses || _courses.isEmpty) return;
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() => _submitting = true);

    try {
      final result = await widget.service.signUp(
        studentNumber: _studentNumberController.text.trim(),
        email: _emailController.text.trim(),
        courseName: _selectedCourse!,
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (!result.success) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text(result.message),
          ),
        );
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error, stackTrace) {
      debugPrint('Student signup request failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: const Text(
            'Could not create account. Check your connection and try again.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _studentNumberController,
            keyboardType: TextInputType.number,
            decoration: _decoration('Student number', Icons.badge_outlined),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Please enter your student number'
                : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _decoration('Email', Icons.email_outlined),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Please enter your email';
              if (!email.contains('@') || !email.contains('.')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          if (_loadingCourses)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            )
          else if (_courseError != null)
            Column(
              children: [
                Text(
                  _courseError!,
                  style: TextStyle(color: Colors.red.shade700),
                  textAlign: TextAlign.center,
                ),
                TextButton(onPressed: _loadCourses, child: const Text('Retry')),
              ],
            )
          else if (_courses.isEmpty)
            const Text('No courses are available for registration.')
          else
            DropdownMenuFormField<String>(
              dropdownMenuEntries: _courses
                  .map(
                    (course) => DropdownMenuEntry<String>(
                      value: course.name,
                      label: course.name,
                    ),
                  )
                  .toList(),
              enableFilter: true,
              enableSearch: true,
              expandedInsets: EdgeInsets.zero,
              menuHeight: 300,
              decorationBuilder: (context, menuController) =>
                  _decoration('Course', Icons.school_outlined),
              onSaved: (value) => _selectedCourse = value,
              validator: (value) =>
                  value == null ? 'Please select your course' : null,
            ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: _hidePassword,
            decoration: _decoration(
              'Password',
              Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _hidePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _hidePassword = !_hidePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _hideConfirmPassword,
            decoration: _decoration(
              'Confirm password',
              Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _hideConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(
                  () => _hideConfirmPassword = !_hideConfirmPassword,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting || _loadingCourses || _courses.isEmpty
                  ? null
                  : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade900,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
