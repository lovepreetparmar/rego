import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../widgets/login_header.dart';
import '../widgets/logo_language_selector.dart';
import '../models/user_data.dart';
import '../utils/app_strings.dart';
import '../utils/app_enums.dart';
import '../providers/language_provider.dart';
import '../screens/web_view_screen.dart';
import '../services/session_service.dart';

class UserDetailsScreen extends StatelessWidget {
  final UserData userData;
  final String password;

  const UserDetailsScreen({
    Key? key,
    required this.userData,
    required this.password,
  }) : super(key: key);

  Future<void> _handleLogin(BuildContext context) async {
    final loginUrl = Uri.parse(
        'https://regodemo.com/mob/ajax/ajax_login.php?username=${userData.username}&password=$password');

    try {
      final response = await http.get(loginUrl);
      final setCookie = response.headers['set-cookie'];
      if (response.statusCode == 200 && response.body.contains('success')) {
        if (setCookie != null) {
          await SessionService.saveSessionCookie(setCookie);
        }
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(
              language: context.read<LanguageProvider>().currentLanguage,
              initialUrl: 'https://regodemo.com/mob/index.php?client=app',
              cookie: setCookie ?? '',
            ),
          ),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Network error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A64A9),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleLanguageChange(BuildContext context, Language language) {
    context.read<LanguageProvider>().setLanguage(language);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final selectedLanguage = languageProvider.currentLanguage;

    String fullName = '${userData.firstname} ${userData.lastname}'.trim();
    if (fullName.isEmpty) fullName = '-';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LoginHeader(language: selectedLanguage),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LogoLanguageSelector(
                    selectedLanguage: selectedLanguage,
                    onLanguageChanged: (language) =>
                        _handleLanguageChange(context, language),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    AppStrings.getString(
                        'registrationSuccessful', selectedLanguage),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF4A64A9),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(
                    AppStrings.getString('name', selectedLanguage),
                    fullName,
                  ),
                  _buildDetailRow(
                    AppStrings.getString('employeeId', selectedLanguage),
                    userData.empId.isNotEmpty ? userData.empId : '-',
                  ),
                  _buildDetailRow(
                    AppStrings.getString('username', selectedLanguage),
                    userData.username.isNotEmpty ? userData.username : '-',
                  ),
                  _buildDetailRow(
                    AppStrings.getString('emailAddress', selectedLanguage),
                    userData.emailAddress.isNotEmpty
                        ? userData.emailAddress
                        : '-',
                  ),
                  _buildDetailRow(
                    AppStrings.getString('phone', selectedLanguage),
                    userData.phone.isNotEmpty ? userData.phone : '-',
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => _handleLogin(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A64A9),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppStrings.getString('ok', selectedLanguage),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
