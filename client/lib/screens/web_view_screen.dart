import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'login.dart';
import '../utils/app_enums.dart';
import '../widgets/app_header.dart';

class WebViewScreen extends StatefulWidget {
  final Language language;
  final String initialUrl;
  final String cookie;

  const WebViewScreen({
    Key? key,
    required this.language,
    required this.initialUrl,
    required this.cookie,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  WebViewController? controller;
  bool _isControllerReady = false;

  @override
  void initState() {
    super.initState();
    if (!_isControllerReady) {
      _initController();
    }
  }

  Future<void> _initController() async {
    if (controller != null) {
      await controller!.clearCache();
      await controller!.clearLocalStorage();
      controller = null;
    }

    final webViewController = WebViewController();

    await webViewController.setJavaScriptMode(JavaScriptMode.unrestricted);

    // Enable DOM storage and cookies
    await webViewController.setOnConsoleMessage(
        (message) => print('WebView Console: ${message.message}'));

    // Create cookie setting script
    final cookieScript = '''
    function setCookieWithAttributes(cookieStr) {
      const [cookie, ...attributes] = cookieStr.split(';');
      document.cookie = cookie + ';' + attributes.join(';') + ';domain=regodemo.com;path=/';
    }
    
    function setAllCookies() {
      const cookies = `${widget.cookie}`.split(',');
      cookies.forEach(cookie => {
        setCookieWithAttributes(cookie.trim());
      });
      return document.cookie;
    }
    setAllCookies();
    ''';

    await webViewController.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) async {
          // Set cookies before each navigation
          await webViewController.runJavaScript(cookieScript);

          return NavigationDecision.navigate;
        },
      ),
    );

    // Set initial cookies
    await webViewController.runJavaScript(cookieScript);

    // Load the page with proper headers
    await webViewController.loadRequest(
      Uri.parse(widget.initialUrl),
      headers: {
        'Cookie': widget.cookie,
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
      },
    );

    if (mounted) {
      setState(() {
        controller = webViewController;
        _isControllerReady = true;
      });
    }
  }

  @override
  void dispose() {
    print("DISPOSE");
    _disposeController();
    super.dispose();
  }

  Future<void> _disposeController() async {
    if (controller != null) {
      await controller!.clearCache();
      await controller!.clearLocalStorage();
      await controller!.setJavaScriptMode(JavaScriptMode.disabled);
      setState(() {
        controller = null;
        _isControllerReady = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _disposeController();
        return true;
      },
      child: Scaffold(
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
                      onPressed: () async {
                        await _disposeController();
                        if (mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }
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
                  child: _isControllerReady && controller != null
                      ? WebViewWidget(controller: controller!)
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
