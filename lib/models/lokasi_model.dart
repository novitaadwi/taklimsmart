class LokasiModel {
  final int idLokasi;
  final String namaLokasi;
  final String alamat;
  final double latitude;
  final double longitude;

  LokasiModel({
    required this.idLokasi, 
    required this.namaLokasi, 
    required this.alamat,
    required this.latitude,
    required this.longitude,
  });

  factory LokasiModel.fromJson(Map<String, dynamic> json) {
    return LokasiModel(
      idLokasi: json['id_Lokasi'],
      namaLokasi: json['nama_Lokasi'],
      alamat: json['alamat'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}