import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
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
import '../screens/login_with_code.dart';
import '../screens/forgot_password.dart';
import 'package:http/http.dart' as http;
import '../providers/language_provider.dart';
import '../services/session_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _rememberMe = false;
  String? _errorMessage;
  bool _isPressed = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _checkSession();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      final username = await _storage.read(key: 'username');
      final password = await _storage.read(key: 'password');
      final rememberMe = await _storage.read(key: 'remember_me');

      if (username != null && password != null && rememberMe == 'true') {
        setState(() {
          _usernameController.text = username;
          _passwordController.text = password;
          _rememberMe = true;
        });
      }
    } catch (e) {
      // Handle error silently
      debugPrint('Error loading credentials: $e');
    }
  }

  Future<void> _saveCredentials() async {
    try {
      if (_rememberMe) {
        await _storage.write(key: 'username', value: _usernameController.text);
        await _storage.write(key: 'password', value: _passwordController.text);
        await _storage.write(key: 'remember_me', value: 'true');
      } else {
        await _storage.deleteAll();
      }
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  Future<void> _checkSession() async {
    final isValid = await SessionService.isSessionValid();
    if (isValid) {
      final cookie = await SessionService.getSessionCookie();
      if (cookie != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(
              language: context.read<LanguageProvider>().currentLanguage,
              initialUrl: 'https://regodemo.com/mob/index.php?client=app',
              cookie: cookie,
            ),
          ),
        );
        return;
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;

      final loginUrl = Uri.parse(
          'https://regodemo.com/mob/ajax/ajax_login.php?username=$username&password=$password');

      try {
        final response = await http.get(loginUrl);
        final setCookie = response.headers['set-cookie'];
        if (response.statusCode == 200 && response.body.contains('success')) {
          await _saveCredentials();
          if (setCookie != null) {
            await SessionService.saveSessionCookie(setCookie);
          }
          if (!mounted) return;
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
            _errorMessage = 'Login failed: ${response.statusCode}';
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

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LoginHeader(language: selectedLanguage),
            Padding(
              padding: const EdgeInsets.all(8.0),
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
                    LoginFormField(
                      controller: _passwordController,
                      label: AppStrings.getString('password', selectedLanguage),
                      errorText: AppStrings.getString(
                          'pleaseEnterPassword', selectedLanguage),
                      isPassword: true,
                    ),
                    const SizedBox(height: 16),
                    RememberMeSwitch(
                      value: _rememberMe,
                      language: selectedLanguage,
                      onChanged: (value) => setState(() => _rememberMe = value),
                    ),
                    const SizedBox(height: 16),
                    LoginButtons(
                      onLogin: _handleLogin,
                      onForgotPassword: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      language: selectedLanguage,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: InkWell(
                        onTapDown: (_) => setState(() => _isPressed = true),
                        onTapUp: (_) => setState(() => _isPressed = false),
                        onTapCancel: () => setState(() => _isPressed = false),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginWithCode(),
                            ),
                          );
                        },
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: Column(
                          children: [
                            Text(
                              AppStrings.getString(
                                  'loginWithCodeQuestion', selectedLanguage),
                              style: TextStyle(
                                color: const Color(0xFF3B5998),
                                fontSize: 16,
                                decoration: _isPressed
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                            ),
                          ],
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
