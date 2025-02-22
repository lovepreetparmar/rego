import 'package:flutter/material.dart';
import '../utils/app_enums.dart';

class AppHeader extends StatelessWidget {
  final Language language;
  final String title;

  const AppHeader({
    Key? key,
    required this.language,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF3B5998),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
