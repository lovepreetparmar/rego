import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/login_header.dart';
import '../widgets/logo_language_selector.dart';
import '../widgets/login_form_field.dart';
import '../widgets/error_message.dart';
import '../widgets/footer_text.dart';
import '../utils/app_strings.dart';
import '../utils/app_enums.dart';
import '../screens/login.dart';
import 'package:http/http.dart' as http;
import '../providers/language_provider.dart';
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  String? _errorMessage;
  bool _isPressed = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://regodemo.com/api/forgot.php'),
        );

        request.fields['username'] = username;

        var response = await request.send();
        var responseString = await response.stream.bytesToString();
        var responseData = json.decode(responseString);

        if (responseData["status"] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
          // Also show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData["msg"]),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          setState(() {
            _errorMessage = responseData["msg"] ?? 'An error occurred';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LoginHeader(language: selectedLanguage),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    LogoLanguageSelector(
                      selectedLanguage: selectedLanguage,
                      onLanguageChanged: _handleLanguageChange,
                    ),
                    const SizedBox(height: 24),
                    LoginFormField(
                      controller: _usernameController,
                      autoFocus: true,
                      label: AppStrings.getString('username', selectedLanguage),
                      errorText: AppStrings.getString(
                          'pleaseEnterUsername', selectedLanguage),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        _handleLogin();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A64A9),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppStrings.getString(
                            'forgotPasswordTitle', selectedLanguage),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      ErrorMessage(language: selectedLanguage),
                    ],
                    FooterText(language: selectedLanguage),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
