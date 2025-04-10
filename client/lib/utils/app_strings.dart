import 'app_enums.dart';

class AppStrings {
  // **Plan:**

  // 1. Create a single `_localizedStrings` map.
  // 2. The keys of this map will be the string identifiers (e.g., 'loginTitle').
  // 3. The values will be another map, where the keys are the `Language` enum values and the values are the corresponding translated strings.
  // 4. Update the `getString` method to access the correct string from the nested map. ```
  // Start of Selection
  static const Map<String, Map<Language, String>> _localizedStrings = {
    'loginTitle': {
      Language.en: 'Login to our secure server',
      Language.th: 'เข้าสู่ระบบเซิร์ฟเวอร์ที่ปลอดภัย',
    },
    'username': {
      Language.en: 'Username',
      Language.th: 'ชื่อผู้ใช้',
    },
    'password': {
      Language.en: 'Password',
      Language.th: 'รหัสผ่าน',
    },
    'rememberMe': {
      Language.en: 'Remember me',
      Language.th: 'จดจำฉัน',
    },
    'login': {
      Language.en: 'Log-in',
      Language.th: 'เข้าสู่ระบบ',
    },
    'forgotPassword': {
      Language.en: 'Forgot password',
      Language.th: 'ลืมรหัสผ่าน',
    },
    'errorMessage': {
      Language.en: 'Wrong Username or Password',
      Language.th: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง',
    },
    'pleaseEnterUsername': {
      Language.en: 'Please enter username',
      Language.th: 'กรุณากรอกชื่อผู้ใช้',
    },
    'pleaseEnterPassword': {
      Language.en: 'Please enter password',
      Language.th: 'กรุณากรอกรหัสผ่าน',
    },
    'stayWithClients': {
      Language.en: 'We always stay with our clients',
      Language.th: 'เราอยู่เคียงข้างลูกค้าเสมอ',
    },
    'alwaysAvailable': {
      Language.en:
          'We always available for you all time long to answer your questions.',
      Language.th: 'เราพร้อมให้บริการคุณตลอดเวลาเพื่อตอบคำถามของคุณ',
    },
    'enterSixDigitCode': {
      Language.en: 'Enter 6 digit code',
      Language.th: 'ป้อนรหัส 6 หลัก',
    },
    'loginWithCode': {
      Language.en: 'Login with code',
      Language.th: 'เข้าสู่ระบบด้วยรหัส',
    },
    'loginWithCodeQuestion': {
      Language.en: 'Login with code',
      Language.th: 'หรือ เข้าสู่ระบบด้วยรหัส?',
    },
    'forgotPasswordTitle': {
      Language.en: 'Forgot password',
      Language.th: 'ลืมรหัสผ่าน',
    },
    'resetPasswordTitle': {
      Language.en: 'Reset Password',
      Language.th: 'รีเซ็ตรหัสผ่าน',
    },
    'newPassword': {
      Language.en: 'New Password',
      Language.th: 'รหัสผ่านใหม่',
    },
    'confirmPassword': {
      Language.en: 'Confirm Password',
      Language.th: 'ยืนยันรหัสผ่าน',
    },
    'pleaseEnterNewPassword': {
      Language.en: 'Please enter new password',
      Language.th: 'กรุณากรอกรหัสผ่านใหม่',
    },
    'pleaseConfirmPassword': {
      Language.en: 'Please confirm your password',
      Language.th: 'กรุณายืนยันรหัสผ่าน',
    },
    'resetPassword': {
      Language.en: 'Reset Password',
      Language.th: 'รีเซ็ตรหัสผ่าน',
    },
    'passwordsDoNotMatch': {
      Language.en: 'Passwords do not match',
      Language.th: 'รหัสผ่านไม่ตรงกัน',
    },
    'registrationSuccessful': {
      Language.en:
          'You are now successfully registered with following details:',
      Language.th: 'คุณได้ลงทะเบียนสำเร็จแล้วด้วยรายละเอียดดังต่อไปนี้:',
    },
    'name': {
      Language.en: 'Name',
      Language.th: 'ชื่อ',
    },
    'employeeId': {
      Language.en: 'Employee ID',
      Language.th: 'รหัสพนักงาน',
    },
    'emailAddress': {
      Language.en: 'Email Address',
      Language.th: 'ที่อยู่อีเมล',
    },
    'phone': {
      Language.en: 'Phone',
      Language.th: 'โทรศัพท์',
    },
    'ok': {
      Language.en: 'OK',
      Language.th: 'ตกลง',
    },
  };

  static String getString(String key, Language language) {
    return _localizedStrings[key]![language]!;
  }
}
