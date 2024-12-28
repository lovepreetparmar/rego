import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'login.dart';
import '../utils/app_enums.dart';
import '../widgets/app_header.dart';

class WebViewScreen extends StatefulWidget {
  final Language language;

  const WebViewScreen({
    Key? key,
    required this.language,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://youtube.com'));
  }

  @override
  void dispose() {
    controller
      ..clearCache()
      ..clearLocalStorage()
      ..setJavaScriptMode(JavaScriptMode.disabled);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF3B5998),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: AppHeader(
                  language: widget.language,
                  title: 'Welcome to Rego',
                ),
                actions: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: WebViewWidget(controller: controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
