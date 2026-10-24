import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1600),
      child: MaterialButton(
        onPressed: onPressed,
        height: 50,
        color: Colors.orange[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: const Center(
          child: Text(
            "Login",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
