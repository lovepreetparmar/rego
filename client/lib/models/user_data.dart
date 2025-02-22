class UserData {
  final bool status;
  final int statusValue;
  final String data;
  final String username;
  final String firstname;
  final String lastname;
  final String phone;
  final String emailAddress;
  final String empId;
  final int loginAgain;
  final String msg;
  final String token;

  UserData({
    required this.status,
    required this.statusValue,
    required this.data,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.phone,
    required this.emailAddress,
    required this.empId,
    required this.loginAgain,
    required this.msg,
    required this.token,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      status: json['status'] ?? false,
      statusValue: int.tryParse(json['status_value']?.toString() ?? '0') ?? 0,
      data: json['data']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      emailAddress: json['email_address']?.toString() ?? '',
      empId: json['emp_id']?.toString() ?? '',
      loginAgain: int.tryParse(json['login_again']?.toString() ?? '0') ?? 0,
      msg: json['msg']?.toString() ?? '',
      token: json['token']?.toString() ?? '',
    );
  }
}
