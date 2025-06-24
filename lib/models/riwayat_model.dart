import 'package:taklimsmart/models/penjadwalan_model.dart';

class RiwayatModel {
  final int idRiwayat;
  final int idPenjadwalan;
  final int? statusLama;
  final StatusPenjadwalan statusBaru;
  final int changedBy;
  final String alasan;
  final DateTime changedAt;

  RiwayatModel({
    required this.idRiwayat,
    required this.idPenjadwalan,
    required this.statusLama,
    required this.statusBaru,
    required this.changedBy,
    required this.alasan,
    required this.changedAt,
  });

  factory RiwayatModel.fromJson(Map<String, dynamic> json) {
    return RiwayatModel(
      idRiwayat: json['id_Riwayat'],
      idPenjadwalan: json['id_Penjadwalan'],
      statusLama: json['status_Lama'], // boleh null
      statusBaru: StatusPenjadwalan.values[json['status_Baru']],
      changedBy: json['changed_By'],
      alasan: json['alasan'] ?? '',
      changedAt: DateTime.parse(json['changed_At']),
    );
  }
}

