import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_connect/utils/id_input_formatter.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _showInvalidIdWarning = false;
  bool _passwordLimitReached = false;

  @override
  Widget build(BuildContext context) {
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
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: TextField(
                keyboardType: TextInputType.text,
                inputFormatters: [
                  IdInputFormatter(
                    onInvalidInput: (hasInvalidInput) {
                      if (_showInvalidIdWarning != hasInvalidInput) {
                        setState(() {
                          _showInvalidIdWarning = hasInvalidInput;
                        });
                      }
                    },
                  ),
                  LengthLimitingTextInputFormatter(15),
                ],
                decoration: InputDecoration(
                  hintText: "ID number",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: InputBorder.none,
                  errorText: _showInvalidIdWarning
                      ? 'Only letters and numbers are allowed.'
                      : null,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                obscureText: true,
                onChanged: (value) {
                  final limitReached = value.length >= 10;
                  if (_passwordLimitReached != limitReached) {
                    setState(() {
                      _passwordLimitReached = limitReached;
                    });
                  }
                },
                inputFormatters: [LengthLimitingTextInputFormatter(10)],
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: InputBorder.none,
                  helperText: _passwordLimitReached
                      ? "Password limit reached (10 characters)."
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
