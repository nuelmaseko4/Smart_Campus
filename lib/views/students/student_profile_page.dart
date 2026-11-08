import 'package:flutter/material.dart';
import 'package:uni_connect/services/signup_services.dart';
import 'package:uni_connect/services/student_profile_service.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({
    super.key,
    required this.service,
    required this.onLogout,
  });

  final StudentProfileService service;
  final VoidCallback onLogout;

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  late Future<StudentProfile> _profile;
  bool _loadingCourses = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.service.fetchProfile();
  }

  void _reloadProfile() {
    setState(() {
      _profile = widget.service.fetchProfile();
    });
  }

  Future<void> _editProfile(StudentProfile profile) async {
    setState(() => _loadingCourses = true);
    try {
      final courses = await widget.service.fetchCourses();
      if (!mounted) return;
      setState(() => _loadingCourses = false);

      final updatedProfile = await showDialog<StudentProfile>(
        context: context,
        builder: (context) => _EditProfileDialog(
          service: widget.service,
          profile: profile,
          courses: courses,
        ),
      );
      if (updatedProfile != null && mounted) {
        setState(() => _profile = Future.value(updatedProfile));
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingCourses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load courses: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StudentProfile>(
      future: _profile,
      builder: (context, snapshot) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: CircleAvatar(
                radius: 42,
                backgroundColor: Colors.orange.shade100,
                child: Icon(
                  Icons.person_outline,
                  size: 48,
                  color: Colors.orange.shade900,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Student profile',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(child: CircularProgressIndicator())
            else if (snapshot.hasError)
              _ProfileLoadError(
                message: snapshot.error.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
                onRetry: _reloadProfile,
              )
            else if (snapshot.hasData) ...[
              _ProfileInfoCard(
                profile: snapshot.data!,
                loadingCourses: _loadingCourses,
                onEdit: () => _editProfile(snapshot.data!),
              ),
            ],
            const SizedBox(height: 24),
            OutlinedButton.icon(
              key: const ValueKey('student-logout'),
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade700,
                side: BorderSide(color: Colors.red.shade300),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({
    required this.profile,
    required this.loadingCourses,
    required this.onEdit,
  });

  final StudentProfile profile;
  final bool loadingCourses;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _ProfileInfoRow(
            icon: Icons.badge_outlined,
            label: 'Student number',
            value: profile.studentId,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _ProfileInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: profile.email ?? 'Not provided',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          _ProfileInfoRow(
            icon: Icons.school_outlined,
            label: 'Course',
            value: '${profile.courseName} (${profile.courseCode})',
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                key: const ValueKey('edit-student-profile'),
                onPressed: loadingCourses ? null : onEdit,
                icon: loadingCourses
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.edit_outlined),
                label: Text(loadingCourses ? 'Loading courses' : 'Edit profile'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({
    required this.service,
    required this.profile,
    required this.courses,
  });

  final StudentProfileService service;
  final StudentProfile profile;
  final List<Course> courses;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late int _courseId;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(
      text: widget.profile.email ?? '',
    );
    _courseId = widget.profile.courseId;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _errorMessage = null;
    });
    try {
      final profile = await widget.service.updateProfile(
        email: _emailController.text.trim(),
        courseId: _courseId,
      );
      if (mounted) Navigator.of(context).pop(profile);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit student profile'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                key: const ValueKey('student-profile-email'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty ||
                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(email)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                key: const ValueKey('student-profile-course'),
                initialValue: _courseId,
                decoration: const InputDecoration(
                  labelText: 'Course',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
                items: widget.courses
                    .map(
                      (course) => DropdownMenuItem(
                        value: course.id,
                        child: Text(course.name),
                      ),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (courseId) {
                        if (courseId != null) {
                          setState(() => _courseId = courseId);
                        }
                      },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.orange.shade900),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}

class _ProfileLoadError extends StatelessWidget {
  const _ProfileLoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Try again'),
        ),
      ],
    );
  }
}
