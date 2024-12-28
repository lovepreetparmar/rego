import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../utils/app_enums.dart';
import 'app_header.dart';

class LoginHeader extends StatelessWidget {
  final Language language;

  const LoginHeader({
    Key? key,
    required this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppHeader(
      language: language,
      title: AppStrings.getString('loginTitle', language),
    );
  }
}
