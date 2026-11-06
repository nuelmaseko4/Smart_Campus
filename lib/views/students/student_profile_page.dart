import 'package:flutter/material.dart';
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
              _ProfileInfoCard(profile: snapshot.data!),
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
  const _ProfileInfoCard({required this.profile});

  final StudentProfile profile;

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
        ],
      ),
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
