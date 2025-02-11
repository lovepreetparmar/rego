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
import 'dart:convert';

class RequestPassword extends StatefulWidget {
  const RequestPassword({super.key});

  @override
  State<RequestPassword> createState() => _RequestPasswordState();
}

class _RequestPasswordState extends State<RequestPassword> {
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
        child: AppWrapper(
          child: Column(
            children: [
              const SizedBox(height: 16),
              LogoLanguageSelector(
                selectedLanguage: selectedLanguage,
                onLanguageChanged: _handleLanguageChange,
                showLock: false,
              ),
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
                                // Show success message if available
                                if (jsonResponse['msg'] != null) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        jsonResponse['msg'].toString(),
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }

                                // Navigate to Login screen on success
                                if (!context.mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ResetPassword(
                                      code: code,
                                    ),
                                  ),
                                );
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
                            backgroundColor: const Color(0xFF4A64A9),
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
              FooterText(language: selectedLanguage),
            ],
          ),
        ),
      ),
    );
  }
}
