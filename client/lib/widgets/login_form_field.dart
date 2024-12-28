import 'package:flutter/material.dart';

class LoginFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String errorText;
  final bool isPassword;
  final bool autoFocus;
  const LoginFormField({
    Key? key,
    required this.controller,
    required this.label,
    required this.errorText,
    this.isPassword = false,
    this.autoFocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          autofocus: this.autoFocus,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return errorText;
            }
            return null;
          },
        ),
      ],
    );
  }
}
