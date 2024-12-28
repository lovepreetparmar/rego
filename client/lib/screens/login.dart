import 'package:flutter/material.dart';
import '../widgets/login_header.dart';
import '../widgets/logo_language_selector.dart';
import '../widgets/login_form_field.dart';
import '../widgets/remember_me_switch.dart';
import '../widgets/login_buttons.dart';
import '../widgets/error_message.dart';
import '../widgets/footer_text.dart';
import '../utils/app_strings.dart';
import '../utils/app_enums.dart';
import '../screens/web_view_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  String? _errorMessage;
  Language _selectedLanguage = Language.en;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewScreen(language: _selectedLanguage),
        ),
      );
    }
  }

  void _handleLanguageChange(Language language) {
    setState(() {
      _selectedLanguage = language;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LoginHeader(language: _selectedLanguage),
                const SizedBox(height: 24),
                LogoLanguageSelector(
                  selectedLanguage: _selectedLanguage,
                  onLanguageChanged: _handleLanguageChange,
                ),
                const SizedBox(height: 24),
                LoginFormField(
                  controller: _usernameController,
                  autoFocus: true,
                  label: AppStrings.getString('username', _selectedLanguage),
                  errorText: AppStrings.getString(
                      'pleaseEnterUsername', _selectedLanguage),
                ),
                const SizedBox(height: 16),
                LoginFormField(
                  controller: _passwordController,
                  label: AppStrings.getString('password', _selectedLanguage),
                  errorText: AppStrings.getString(
                      'pleaseEnterPassword', _selectedLanguage),
                  isPassword: true,
                ),
                const SizedBox(height: 16),
                RememberMeSwitch(
                  value: _rememberMe,
                  language: _selectedLanguage,
                  onChanged: (value) => setState(() => _rememberMe = value),
                ),
                const SizedBox(height: 16),
                LoginButtons(
                  onLogin: _handleLogin,
                  onForgotPassword: () {},
                  language: _selectedLanguage,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  ErrorMessage(language: _selectedLanguage),
                ],
                FooterText(language: _selectedLanguage),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
