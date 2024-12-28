import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../utils/app_enums.dart';

class RememberMeSwitch extends StatelessWidget {
  final bool value;
  final Language language;
  final ValueChanged<bool> onChanged;

  const RememberMeSwitch({
    Key? key,
    required this.value,
    required this.language,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
        ),
        Text(
          AppStrings.getString('rememberMe', language),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
