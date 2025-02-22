import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/login_header.dart';
import '../widgets/logo_language_selector.dart';
import '../widgets/login_form_field.dart';
import '../widgets/footer_text.dart';
import '../utils/app_strings.dart';
import '../utils/app_enums.dart';
import '../screens/login.dart';
import '../models/user_data.dart';
import 'package:http/http.dart' as http;
import '../providers/language_provider.dart';
import 'dart:convert';

class ResetPassword extends StatefulWidget {
  const ResetPassword({
    Key? key,
    required this.code,
    required this.userData,
  }) : super(key: key);

  final String code;
  final UserData userData;

  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      final newPassword = _newPasswordController.text;
      final confirmPassword = _confirmPasswordController.text;
      final selectedLanguage = context.read<LanguageProvider>().currentLanguage;

      if (newPassword != confirmPassword) {
        setState(() {
          _errorMessage =
              AppStrings.getString('passwordsDoNotMatch', selectedLanguage);
        });
        return;
      }

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('https://regodemo.com/api/password.php'),
        );
        request.fields['code'] = widget.code;
        request.fields['npassword'] = newPassword;
        request.fields['cpassword'] = confirmPassword;

        var response = await request.send();
        var responseString = await response.stream.bytesToString();
        var responseData = json.decode(responseString);

        if (responseData["status"] == true) {
          if (!context.mounted) return;

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData["msg"] ?? 'Password reset successful'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to Login screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        } else {
          setState(() {
            _errorMessage = responseData["msg"] ?? 'Password reset failed';
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
                      controller: _newPasswordController,
                      label:
                          AppStrings.getString('newPassword', selectedLanguage),
                      errorText: AppStrings.getString(
                          'pleaseEnterNewPassword', selectedLanguage),
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),
                    LoginFormField(
                      controller: _confirmPasswordController,
                      label: AppStrings.getString(
                          'confirmPassword', selectedLanguage),
                      errorText: AppStrings.getString(
                          'pleaseConfirmPassword', selectedLanguage),
                      isPassword: true,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleResetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A64A9),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppStrings.getString('resetPassword', selectedLanguage),
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
