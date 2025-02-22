import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SessionService {
  static const _storage = FlutterSecureStorage();
  static const _sessionCookieKey = 'session_cookie';

  // Save session cookie
  static Future<void> saveSessionCookie(String cookie) async {
    await _storage.write(key: _sessionCookieKey, value: cookie);
  }

  // Get session cookie
  static Future<String?> getSessionCookie() async {
    return await _storage.read(key: _sessionCookieKey);
  }

  // Delete session cookie
  static Future<void> deleteSessionCookie() async {
    await _storage.delete(key: _sessionCookieKey);
  }

  // Check if session is valid
  static Future<bool> isSessionValid() async {
    final cookie = await getSessionCookie();
    if (cookie == null) return false;

    try {
      final response = await http.get(
        Uri.parse('https://regodemo.com/mob/index.php?client=app'),
        headers: {'Cookie': cookie},
      );

      // If we get redirected to login.php or get an error, session is invalid
      if (response.statusCode == 302) {
        final location = response.headers['location'];
        if (location?.contains('login.php') == true) {
          await deleteSessionCookie();
          return false;
        }
      }

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
