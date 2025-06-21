class User {
  final int idUser;
  final String username;
  final String email;
  final String noHp;
  final String alamat;

  User({
    required this.idUser,
    required this.username,
    required this.email,
    required this.noHp,
    required this.alamat,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['id_User'],
      username: json['username'],
      email: json['email'],
      noHp: json['no_hp'],
      alamat: json['alamat'],
    );
  }
}
