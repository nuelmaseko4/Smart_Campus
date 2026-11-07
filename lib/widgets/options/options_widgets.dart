import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class OptionsWidget extends StatelessWidget {
  final VoidCallback onLecturerTap;
  final VoidCallback onStudentTap;

  const OptionsWidget({
    super.key,
    required this.onLecturerTap,
    required this.onStudentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeInUp(
          duration: const Duration(milliseconds: 1000),
          child: _OptionButton(
            label: 'Lecturer',
            icon: Icons.school_outlined,
            onPressed: onLecturerTap,
          ),
        ),
        const SizedBox(height: 20),
        FadeInUp(
          duration: const Duration(milliseconds: 1100),
          child: _OptionButton(
            label: 'Student',
            icon: Icons.people_outline,
            onPressed: onStudentTap,
          ),
        ),
      ],
    );
  }
}

// one button design used for both options
class _OptionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _OptionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange.shade900,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}
