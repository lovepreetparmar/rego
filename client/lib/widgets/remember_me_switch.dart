import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../utils/app_enums.dart';

class RememberMeSwitch extends StatelessWidget {
  final bool value;
  final Language language;
  final ValueChanged<bool> onChanged;
  final Color switchColor;

  const RememberMeSwitch({
    Key? key,
    required this.value,
    required this.language,
    required this.onChanged,
    this.switchColor = const Color(0xFF6f9ed1),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: switchColor,
          activeTrackColor: switchColor.withOpacity(0.5),
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
