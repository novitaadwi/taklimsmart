import 'user_model.dart';

class Auth {
  final String token;
  final int sessionId;
  final User user;

  Auth({
    required this.token,
    required this.sessionId,
    required this.user,
  });

  factory Auth.fromJson(Map<String, dynamic> json) {
    return Auth(
      token: json['token'],
      sessionId: json['session_id'],
      user: User.fromJson(json['user']),
    );
  }
}
