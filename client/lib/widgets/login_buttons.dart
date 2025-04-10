import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../utils/app_enums.dart';

class LoginButtons extends StatelessWidget {
  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final Language language;
  final Color buttonColor;

  const LoginButtons({
    Key? key,
    required this.onLogin,
    required this.onForgotPassword,
    required this.language,
    this.buttonColor = const Color(0xFF6f9ed1),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: onLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            AppStrings.getString('login', language),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: onForgotPassword,
          style: TextButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            AppStrings.getString('forgotPassword', language),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
