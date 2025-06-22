class Dokumentasi {
  int? idDokumentasi;
  int? idPenjadwalan;
  String? namaPenjadwalan;
  int? uploadedBy;
  String? fileName;
  String? filePath;
  String? fileUrl;
  String? captionDokumentasi;
  DateTime? uploadDate;

  Dokumentasi({
    this.idDokumentasi,
    this.idPenjadwalan,
    this.namaPenjadwalan,
    this.uploadedBy,
    this.fileName,
    this.filePath,
    this.fileUrl,
    this.captionDokumentasi,
    this.uploadDate,
  });

  factory Dokumentasi.fromJson(Map<String, dynamic> json) {
    return Dokumentasi(
      idDokumentasi: json['id_Dokumentasi'],
      idPenjadwalan: json['id_Penjadwalan'],
      namaPenjadwalan: json['nama_Penjadwalan'],
      uploadedBy: json['uploaded_By'],
      fileName: json['file_Name'],
      filePath: json['file_Path'],
      fileUrl: json['file_Url'],
      captionDokumentasi: json['caption_Dokumentasi'],
      uploadDate: json['upload_Date'] != null
          ? DateTime.tryParse(json['upload_Date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id_Dokumentasi": idDokumentasi,
      "id_Penjadwalan": idPenjadwalan,
      "nama_Penjadwalan": namaPenjadwalan,
      "uploaded_By": uploadedBy,
      "file_Name": fileName,
      "file_Path": filePath,
      "file_Url": fileUrl,
      "caption_Dokumentasi": captionDokumentasi,
    };
  }

  Map<String, dynamic> toJsonForCreate() {
    return {
      'id_Penjadwalan': idPenjadwalan,
      'uploaded_by': uploadedBy,
      'file_name': fileName,
      'file_path': filePath,
      'file_url': fileUrl,
      'caption_dokumentasi': captionDokumentasi,
    };
  }
}
