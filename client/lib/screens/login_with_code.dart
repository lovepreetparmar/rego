import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../providers/language_provider.dart';
import '../widgets/logo_language_selector.dart';
import '../widgets/footer_text.dart';
import '../utils/app_enums.dart';
import '../widgets/app_wrapper.dart';
import '../utils/app_strings.dart';
import '../screens/reset_password.dart';
import '../screens/user_details_screen.dart';
import '../screens/confirm_password_screen.dart';
import '../models/user_data.dart';
import 'dart:convert';

class LoginWithCode extends StatefulWidget {
  const LoginWithCode({super.key});

  @override
  State<LoginWithCode> createState() => _LoginWithCodeState();
}

class _LoginWithCodeState extends State<LoginWithCode> {
  final List<TextEditingController> codeControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in codeControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    emailController.dispose();
    super.dispose();
  }

  void _handleLanguageChange(Language language) {
    context.read<LanguageProvider>().setLanguage(language);
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final selectedLanguage = languageProvider.currentLanguage;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 80,
                        child: DropdownButton<Language>(
                          value: selectedLanguage,
                          onChanged: (Language? language) {
                            if (language != null) {
                              _handleLanguageChange(language);
                            }
                          },
                          isDense: true,
                          padding: EdgeInsets.zero,
                          underline: Container(),
                          itemHeight: 48,
                          dropdownColor: const Color(0xFF6f9ed1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: Language.en,
                              child: SizedBox(
                                height: 16,
                                child: Image(
                                    image: AssetImage('assets/flag_en.png')),
                              ),
                            ),
                            DropdownMenuItem(
                              value: Language.th,
                              child: SizedBox(
                                height: 16,
                                child: Image(
                                    image: AssetImage('assets/flag_th.png')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: AppWrapper(
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                AppStrings.getString(
                                    'enterSixDigitCode', selectedLanguage),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(
                                  6,
                                  (index) => SizedBox(
                                    width: 45,
                                    height: 55,
                                    child: TextFormField(
                                      controller: codeControllers[index],
                                      focusNode: focusNodes[index],
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      textAlign: TextAlign.center,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(1),
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (value) {
                                        if (value.isNotEmpty && index < 5) {
                                          focusNodes[index + 1].requestFocus();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () async {
                                  // Combine all code digits
                                  final code =
                                      codeControllers.map((c) => c.text).join();

                                  if (code.length != 6) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppStrings.getString('pleaseEnterValidCode',
                                              selectedLanguage),
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  try {
                                    // Create multipart request
                                    var request = http.MultipartRequest(
                                      'POST',
                                      Uri.parse('https://regodemo.com/api/code.php'),
                                    );

                                    // Add form data
                                    request.fields['code'] = code;

                                    // Send the request
                                    var response = await request.send();
                                    var responseData =
                                        await response.stream.bytesToString();

                                    // Parse the response data to get the message
                                    Map<String, dynamic> jsonResponse = {};
                                    try {
                                      jsonResponse = Map<String, dynamic>.from(
                                          json.decode(responseData));
                                    } catch (e) {
                                      print('Error parsing response: $e');
                                    }

                                    if (jsonResponse["status"] == true) {
                                      // Create UserData object from response
                                      final userData =
                                          UserData.fromJson(jsonResponse);

                                      // Show success message if available
                                      if (userData.msg.isNotEmpty) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              userData.msg,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }

                                      // Check loginAgain value and navigate accordingly
                                      if (!context.mounted) return;
                                      if (userData.loginAgain == 0) {
                                        // Navigate to Reset Password screen
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ResetPassword(
                                              code: code,
                                              userData: userData,
                                            ),
                                          ),
                                        );
                                      } else {
                                        // Navigate to Confirm Password screen
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ConfirmPasswordScreen(
                                              userData: userData,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Error: ${jsonResponse["msg"]}',
                                            style:
                                                const TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Network error: $e',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6f9ed1),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  AppStrings.getString(
                                      'loginWithCode', selectedLanguage),
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
                      ),
                    ),
                   
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
