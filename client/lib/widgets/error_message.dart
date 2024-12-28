import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../utils/app_enums.dart';

class ErrorMessage extends StatelessWidget {
  final Language language;

  const ErrorMessage({
    Key? key,
    required this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          AppStrings.getString('errorMessage', language),
          style: const TextStyle(
            color: Colors.red,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
