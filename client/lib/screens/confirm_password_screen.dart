import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/login_header.dart';
import '../widgets/logo_language_selector.dart';
import '../widgets/login_form_field.dart';
import '../widgets/footer_text.dart';
import '../utils/app_strings.dart';
import '../utils/app_enums.dart';
import '../models/user_data.dart';
import '../screens/web_view_screen.dart';
import '../providers/language_provider.dart';
import 'package:http/http.dart' as http;
import '../services/session_service.dart';

class ConfirmPasswordScreen extends StatefulWidget {
  final UserData userData;

  const ConfirmPasswordScreen({
    Key? key,
    required this.userData,
  }) : super(key: key);

  @override
  _ConfirmPasswordScreenState createState() => _ConfirmPasswordScreenState();
}

class _ConfirmPasswordScreenState extends State<ConfirmPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmPassword() async {
    if (_formKey.currentState!.validate()) {
      final password = _passwordController.text;

      try {
        final loginUrl = Uri.parse(
            'https://regodemo.com/mob/ajax/ajax_login.php?username=${widget.userData.username}&password=$password');

        final response = await http.get(loginUrl);
        final setCookie = response.headers['set-cookie'];

        if (response.statusCode == 200 && response.body.contains('success')) {
          if (!context.mounted) return;

          if (setCookie != null) {
            await SessionService.saveSessionCookie(setCookie);
          }

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Login successful'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to WebView screen
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
          setState(() {
            _errorMessage = 'Invalid password';
          });
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Network error: $e';
        });
      }
    }
  }

  void _handleLanguageChange(Language language) {
    context.read<LanguageProvider>().setLanguage(language);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final selectedLanguage = languageProvider.currentLanguage;

    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                      onLanguageChanged: _handleLanguageChange,
                    ),
                    const SizedBox(height: 24),
                    LoginFormField(
                      controller:
                          TextEditingController(text: widget.userData.username),
                      label: AppStrings.getString('username', selectedLanguage),
                      errorText: '',
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    LoginFormField(
                      controller: _passwordController,
                      label: AppStrings.getString('password', selectedLanguage),
                      errorText: AppStrings.getString(
                          'pleaseEnterPassword', selectedLanguage),
                      isPassword: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleConfirmPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A64A9),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppStrings.getString('login', selectedLanguage),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    FooterText(language: selectedLanguage),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
