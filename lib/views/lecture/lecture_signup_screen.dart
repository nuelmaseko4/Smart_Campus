import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:uni_connect/controllers/signup_controller.dart';
import 'package:uni_connect/models/signup_role.dart';
import 'package:uni_connect/services/login_service.dart';
import 'package:uni_connect/services/signup_services.dart';
import 'package:uni_connect/widgets/app_button.dart';
import 'package:uni_connect/widgets/app_text_field.dart';
import 'package:uni_connect/widgets/signup_page_layout.dart';

class LectureSignUpScreen extends StatefulWidget {
  const LectureSignUpScreen({
    super.key,
    this.service = const SignUpService(),
    this.loginService = const LoginService(),
  });

  final SignUpService service;
  final LoginService loginService;

  @override
  State<LectureSignUpScreen> createState() => _LectureSignUpScreenState();
}

class _LectureSignUpScreenState extends State<LectureSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SignUpController _controller;
  bool _authenticating = false;

  @override
  void initState() {
    super.initState();
    _controller = SignUpController(
      role: SignUpRole.lecturer,
      service: widget.service,
    );
    _controller.loadCourses();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _controller.submit();
    if (!mounted) return;

    if (result.success) {
      setState(() => _authenticating = true);
      try {
        final loginResult = await widget.loginService.login(
          role: 'lecturer',
          identifier: _controller.emailController.text.trim(),
          password: _controller.passwordController.text,
        );
        if (!mounted) return;
        if (loginResult.success) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/lecturer', (route) => false);
          return;
        }
        Navigator.pop(
          context,
          '${result.message}. Automatic sign-in failed: '
          '${loginResult.message}. Please sign in with your email and password.',
        );
        return;
      } catch (error, stackTrace) {
        debugPrint('Automatic lecturer sign-in failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        if (!mounted) return;
        Navigator.pop(
          context,
          '${result.message}. Automatic sign-in failed. '
          'Please sign in with your email and password.',
        );
        return;
      } finally {
        if (mounted) setState(() => _authenticating = false);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text(result.message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SignupPageLayout(
      title: 'Sign Up',
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, child) => Form(
          key: _formKey,
          child: Column(
            children: [
              FadeInUp(
                duration: const Duration(milliseconds: 1000),
                child: AppTextField(
                  controller: _controller.firstNameController,
                  label: 'First name',
                  prefixIcon: Icons.badge_outlined,
                  validator: _controller.validateFirstName,
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 1100),
                child: AppTextField(
                  controller: _controller.lastNameController,
                  label: 'Last name',
                  prefixIcon: Icons.badge_outlined,
                  validator: _controller.validateLastName,
                ),
              ),
              const SizedBox(height: 20),
              FadeInUp(
                duration: const Duration(milliseconds: 1150),
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
                child: _courseSelector(),
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
                duration: const Duration(milliseconds: 1350),
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
                duration: const Duration(milliseconds: 1400),
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

  Widget _courseSelector() {
    return FormField<List<int>>(
      validator: (_) => _controller.validateSelectedCourses(),
      builder: (field) {
        final selectedCourses = _controller.selectedCourses;
        final helperText = _controller.isLoadingCourses
            ? 'Loading courses...'
            : _controller.courseLoadError == null
            ? 'Search and select each course you teach'
            : 'Could not load courses';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_controller.courses.isNotEmpty)
              DropdownMenu<int>(
                key: ValueKey(selectedCourses.length),
                initialSelection: null,
                dropdownMenuEntries: _controller.courses
                    .map(
                      (course) => DropdownMenuEntry<int>(
                        value: course.id,
                        label: course.name,
                      ),
                    )
                    .toList(),
                enableFilter: true,
                enableSearch: true,
                requestFocusOnTap: true,
                expandedInsets: EdgeInsets.zero,
                menuHeight: 300,
                decorationBuilder: (context, menuController) =>
                    appFieldDecoration(
                      context,
                      label: 'Courses you teach',
                      prefixIcon: Icons.school_outlined,
                      suffixIcon: const Icon(Icons.search),
                    ).copyWith(
                      helperText: helperText,
                      errorText: field.errorText,
                    ),
                onSelected: (courseId) {
                  if (courseId == null) return;
                  _controller.toggleCourse(courseId, true);
                  field.didChange(
                    _controller.selectedCourses
                        .map((course) => course.id)
                        .toList(),
                  );
                },
              )
            else
              InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Courses you teach',
                  helperText: helperText,
                  prefixIcon: const Icon(Icons.school_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: _controller.isLoadingCourses
                    ? const LinearProgressIndicator()
                    : const SizedBox.shrink(),
              ),
            if (selectedCourses.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: selectedCourses.map((course) {
                  return InputChip(
                    avatar: const Icon(Icons.school_outlined, size: 18),
                    label: Text(course.name),
                    onDeleted: () {
                      _controller.toggleCourse(course.id, false);
                      field.didChange(
                        _controller.selectedCourses
                            .map((selectedCourse) => selectedCourse.id)
                            .toList(),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
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
