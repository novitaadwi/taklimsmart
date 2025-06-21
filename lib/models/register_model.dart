class RegisterModel {
  String username;
  String email;
  String password;
  String noHp;
  String alamat;
  double? latitude;
  double? longitude;

  RegisterModel({
    required this.username,
    required this.email,
    required this.password,
    required this.noHp,
    required this.alamat,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'password': password,
    'no_hp': noHp,
    'alamat': alamat,
    'latitude': latitude,
    'longitude': longitude,
  };
}