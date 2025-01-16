import 'package:flutter/material.dart';
import '../utils/app_enums.dart';

class LogoLanguageSelector extends StatelessWidget {
  final Language selectedLanguage;
  final void Function(Language) onLanguageChanged;
  final bool showLock;

  const LogoLanguageSelector({
    Key? key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    this.showLock = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/logo.png',
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'Language: ',
                  style: TextStyle(
                    color: Color(0xFF3B5998),
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: DropdownButton<Language>(
                    value: selectedLanguage,
                    onChanged: (Language? language) {
                      if (language != null) {
                        onLanguageChanged(language);
                      }
                    },
                    isDense: true,
                    padding: EdgeInsets.zero,
                    underline: Container(),
                    itemHeight: 48,
                    items: const [
                      DropdownMenuItem(
                        value: Language.en,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('EN', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 8),
                            SizedBox(
                              height: 16,
                              child: Image(
                                  image: AssetImage('assets/flag_en.png')),
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: Language.th,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('TH', style: TextStyle(fontSize: 14)),
                            SizedBox(width: 8),
                            SizedBox(
                              height: 16,
                              child: Image(
                                  image: AssetImage('assets/flag_th.png')),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Stack(
          alignment: Alignment.center,
          children: [
            const Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFF3B5998),
            ),
            if (showLock)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: const Icon(
                  Icons.lock_outline,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
