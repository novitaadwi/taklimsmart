
// untuk READ Card
enum StatusPenjadwalan {
  diproses,  // index 0
  disetujui,     // index 1
  ditolak,   // index 2
}

class PenjadwalanReadModel {
  final int idPenjadwalan;
  final String namaPenjadwalan;
  final String tanggal;
  final String waktu;

  PenjadwalanReadModel({
    required this.idPenjadwalan,
    required this.namaPenjadwalan,
    required this.tanggal,
    required this.waktu,
  });

    factory PenjadwalanReadModel.fromJson(Map<String, dynamic> json) {
    return PenjadwalanReadModel(
      idPenjadwalan: json['id_Penjadwalan'],
      namaPenjadwalan: json['nama_Penjadwalan'],
      tanggal: json['tanggal_Penjadwalan'],
      waktu: json['waktu_Penjadwalan'],
    );
  }

  DateTime get tanggalAsDateTime => DateTime.parse(tanggal);
}

class PenjadwalanModel {
  final int idPenjadwalan;
  final String namaPenjadwalan;
  final String tanggal;
  final String waktu;
  final String? deskripsi;
  final int idLokasi;
  final StatusPenjadwalan status;

  PenjadwalanModel({
    required this.idPenjadwalan,
    required this.namaPenjadwalan,
    required this.tanggal,
    required this.waktu,
    required this.deskripsi,
    required this.idLokasi,
    required this.status,
  });

  factory PenjadwalanModel.fromJson(Map<String, dynamic> json) {
    return PenjadwalanModel(
      idPenjadwalan: json['id_Penjadwalan'],
      namaPenjadwalan: json['nama_Penjadwalan'],
      tanggal: json['tanggal_Penjadwalan'],
      waktu: json['waktu_Penjadwalan'],
      deskripsi: json['deskripsi_Penjadwalan'],
      idLokasi: json['id_Lokasi'],
      status: StatusPenjadwalan.values[json['status_Penjadwalan']],
    );
  }

  Map<String, dynamic> toJson() => {
    'id_Penjadwalan': idPenjadwalan,
    'nama_Penjadwalan': namaPenjadwalan,
    'tanggal_Penjadwalan': tanggal,
    'waktu_Penjadwalan': waktu,
    'id_Lokasi': idLokasi,
    'deskripsi_Penjadwalan': deskripsi,
  };

  DateTime get tanggalAsDateTime => DateTime.parse(tanggal);
}