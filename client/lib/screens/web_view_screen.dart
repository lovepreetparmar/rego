import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'login.dart';
import '../utils/app_enums.dart';
import '../widgets/app_header.dart';
import '../services/session_service.dart';
import 'package:share_plus/share_plus.dart';

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
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    if (!_isControllerReady) {
      _initController();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _disposeController();
    super.dispose();
  }

  Future<void> _initController() async {
    if (_isDisposed) return;

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
          // Check if redirected to login page
          if (request.url.contains('login.php')) {
            await SessionService.deleteSessionCookie();
            if (!mounted) return NavigationDecision.prevent;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
            return NavigationDecision.prevent;
          }

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

    if (!_isDisposed && mounted) {
      setState(() {
        controller = webViewController;
        _isControllerReady = true;
      });
    }
  }

  Future<void> _disposeController() async {
    if (controller != null) {
      try {
        await controller!.clearCache();
        await controller!.clearLocalStorage();
        await controller!.setJavaScriptMode(JavaScriptMode.disabled);

        if (!_isDisposed && mounted) {
          setState(() {
            controller = null;
            _isControllerReady = false;
          });
        }
      } catch (e) {
        print('Error during controller disposal: $e');
      }
    }
  }

  Future<void> _handleLogout() async {
    await _disposeController();
    await SessionService.deleteSessionCookie();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _handleExit() {
    _disposeController();
    exit(0);
  }

  void _handleAppPassCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('App Pass Code functionality coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _handleShareLink() {
    Share.share(
      'Check out Rego HR app: https://apps.apple.com/us/app/rego-hr/id6742355882',
      subject: 'Rego HR App',
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _disposeController();
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 40,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    color: Colors.white,
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'exit',
                        child: Row(
                          children: [
                            Icon(Icons.exit_to_app, color: Colors.black87),
                            SizedBox(width: 8),
                            Text('Exit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.black87),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'app_pass_code',
                        child: Row(
                          children: [
                            Icon(Icons.lock, color: Colors.black87),
                            SizedBox(width: 8),
                            Text('App Pass Code'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'share_link',
                        child: Row(
                          children: [
                            Icon(Icons.share, color: Colors.black87),
                            SizedBox(width: 8),
                            Text('Share Link'),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (String value) {
                      switch (value) {
                        case 'exit':
                          _handleExit();
                          break;
                        case 'logout':
                          _handleLogout();
                          break;
                        case 'app_pass_code':
                          _handleAppPassCode();
                          break;
                        case 'share_link':
                          _handleShareLink();
                          break;
                      }
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: _isControllerReady && controller != null
                    ? WebViewWidget(controller: controller!)
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
