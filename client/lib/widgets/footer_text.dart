import 'package:flutter/material.dart';
import '../utils/app_strings.dart';
import '../utils/app_enums.dart';

class FooterText extends StatelessWidget {
  final Language language;

  const FooterText({
    Key? key,
    required this.language,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Text(
            AppStrings.getString('stayWithClients', language),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          Text(
            AppStrings.getString('alwaysAvailable', language),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
