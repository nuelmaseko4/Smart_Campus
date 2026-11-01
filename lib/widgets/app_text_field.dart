import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.decoration,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  }) : assert(decoration != null || label != null);

  final TextEditingController controller;
  final InputDecoration? decoration;
  final String? label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration:
          decoration ??
          appFieldDecoration(
            context,
            label: label!,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ),
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
    );
  }
}

InputDecoration appFieldDecoration(
  BuildContext context, {
  required String label,
  IconData? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: TextStyle(color: Colors.grey.shade600),
    floatingLabelStyle: TextStyle(
      color: Colors.orange.shade800,
      fontWeight: FontWeight.w600,
    ),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, color: Colors.grey.shade600),
    suffixIcon: suffixIcon,
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
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
  );
}
