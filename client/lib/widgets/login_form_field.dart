import 'package:flutter/material.dart';

class LoginFormField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String errorText;
  final bool isPassword;
  final bool autoFocus;
  final bool enabled;

  const LoginFormField({
    Key? key,
    required this.controller,
    required this.label,
    required this.errorText,
    this.isPassword = false,
    this.autoFocus = false,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<LoginFormField> createState() => _LoginFormFieldState();
}

class _LoginFormFieldState extends State<LoginFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          autofocus: widget.autoFocus,
          enabled: widget.enabled,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
          validator: (value) {
            if (!widget.enabled) return null;
            if (value == null || value.isEmpty) {
              return widget.errorText;
            }
            return null;
          },
        ),
      ],
    );
  }
}
