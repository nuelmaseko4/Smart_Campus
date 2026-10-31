import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon; // Optional: Show an icon on the left
  final bool isLoading; // Optional: Show a spinning circle instead of text
  final bool enabled;
  final Color? backgroundColor; // Optional: Change color if needed

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.enabled = true,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55, // Keeps all buttons across the app the exact same height
      child: ElevatedButton(
        onPressed: isLoading || !enabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.orange.shade900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                // Show a little white loading spinner
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 22),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
