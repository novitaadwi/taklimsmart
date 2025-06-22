import 'dart:io';

import 'package:flutter/material.dart';
import 'package:taklimsmart/services/dokumentasi_service.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taklimsmart/models/dokumentasi.dart';
import 'package:permission_handler/permission_handler.dart';

class DokumentasiAdminScreen extends StatefulWidget {
  const DokumentasiAdminScreen({super.key});

  @override
  State<DokumentasiAdminScreen> createState() => _DokumentasiAdminScreenState();
}

class _DokumentasiAdminScreenState extends State<DokumentasiAdminScreen> {
  final DokumentasiService _dokumentasiService = DokumentasiService();
  List<dynamic> dokumentasiList = [];
  Map<int, String?> videoThumbnails = {};

  Future<void> _loadDokumentasi() async {
    final data = await _dokumentasiService.fetchDokumentasi();
    setState(() {
      dokumentasiList = data;
    });
  }

  Future<void> _deleteDokumentasi(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Apakah Anda yakin ingin menghapus dokumentasi ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final result = await _dokumentasiService.deleteDokumentasi(id);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Dokumentasi berhasil dihapus"),
          backgroundColor: Colors.green,
        ),
      );
      _loadDokumentasi();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menghapus dokumentasi!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _generateThumbnail(String url, int id) async {
    if (videoThumbnails.containsKey(id)) return;

    final tempDir = await getTemporaryDirectory();
    final thumb = await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.PNG,
      maxWidth: 128,
      quality: 75,
    );

    if (mounted) {
      setState(() {
        videoThumbnails[id] = thumb;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDokumentasi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Dokumentasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child:
              dokumentasiList.isEmpty
                  ? const Center(child: Text("Dokumentasi kosong"))
                  : ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: dokumentasiList.length,
                itemBuilder: (context, index) {
                  final item = dokumentasiList[index];
                  final isVideo =
                  item['file_Name'].toString().toLowerCase().endsWith(".mp4");
                  final mediaUrl =
                      "${item['file_Url']}${item['file_Path']}${item['file_Name']}";
                  debugPrint("Media URL: $mediaUrl");
                  final id = item['id_Dokumentasi'];
                  if (isVideo) {
                    _generateThumbnail(mediaUrl, id);
                  }
                  return Card(
                    margin: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        final dokumentasi = Dokumentasi(
                          idDokumentasi: item['id_Dokumentasi'],
                          idPenjadwalan: item['id_Penjadwalan'],
                          uploadedBy: item['uploaded_By'],
                          fileName: item['file_Name'],
                          filePath: item['file_Path'],
                          fileUrl: item['file_Url'],
                          captionDokumentasi: item['caption_Dokumentasi'],
                          uploadDate: DateTime.tryParse(item['upload_Date'] ?? ""),
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PreviewMediaScreen(dokumentasi: dokumentasi),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Media (gambar atau icon video)
                          if (!isVideo)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                mediaUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const SizedBox(
                                    height: 180,
                                    child: Center(child: Icon(Icons.broken_image, size: 60)),
                                  );
                                },
                              ),
                            )
                          else
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  videoThumbnails[id] != null
                                      ? Image.file(
                                    File(videoThumbnails[id]!),
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                      : const SizedBox(
                                    height: 180,
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                                  const Icon(Icons.play_circle_outline, size: 64, color: Colors.white),
                                ],
                              ),
                            ),

                          // Konten teks
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['caption_Dokumentasi'] ?? '-',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Jadwal : ${item['nama_Penjadwalan'] ?? '-'}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade600,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _formatDate(item['upload_Date']),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.orange),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => EditDokumentasi(
                                              dokumentasi: Dokumentasi.fromJson(item),
                                            ),
                                          ),
                                        );
                                        _loadDokumentasi();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteDokumentasi(item['id_Dokumentasi']),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TambahDokumentasiScreen()),
                    );
                    _loadDokumentasi();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD1863A),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.add, size: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tambah Dokumentasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              color: const Color(0xFF4A5F2F),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.home, color: Colors.white),
                      SizedBox(height: 4),
                      Text('Beranda', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, color: Colors.white),
                      SizedBox(height: 4),
                      Text('Akun', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return '-';
    try {
      final dateTime = DateTime.parse(isoString);
      return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return '-';
    }
  }
}

// preview media dokumentasi
class PreviewMediaScreen extends StatefulWidget {
  final Dokumentasi dokumentasi;

  const PreviewMediaScreen({super.key, required this.dokumentasi});

  @override
  State<PreviewMediaScreen> createState() => _PreviewMediaScreenState();
}

class _PreviewMediaScreenState extends State<PreviewMediaScreen> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    if (widget.dokumentasi.fileName?.toLowerCase().endsWith('.mp4') == true) {
      final url =
          "${widget.dokumentasi.fileUrl}${widget.dokumentasi.filePath}${widget.dokumentasi.fileName}";
      _videoController = VideoPlayerController.networkUrl(Uri.parse(url))
        ..initialize().then((_) {
          setState(() {});
          _videoController?.play();
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.dokumentasi.fileName?.toLowerCase() ?? '';
    final fileUrl =
        "${widget.dokumentasi.fileUrl}${widget.dokumentasi.filePath}${widget.dokumentasi.fileName}";

    return Scaffold(
      appBar: AppBar(title: const Text("Dokumentasi")),
      body: Center(
        child: fileName.endsWith('.mp4')
            ? (_videoController != null &&
            _videoController!.value.isInitialized)
            ? AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        )
            : const CircularProgressIndicator()
            : Image.network(
          fileUrl,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// tambah dokumentasi
class TambahDokumentasiScreen extends StatefulWidget {
  const TambahDokumentasiScreen({super.key});

  @override
  State<TambahDokumentasiScreen> createState() => _TambahDokumentasiScreenState();
}

class _TambahDokumentasiScreenState extends State<TambahDokumentasiScreen> {
  final DokumentasiService _dokumentasiService = DokumentasiService();
  List<dynamic> penjadwalanList = [];
  VideoPlayerController? _videoController;

  final TextEditingController _captionController = TextEditingController();
  int? selectedPenjadwalanId;
  XFile? file;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadPenjadwalan();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadPenjadwalan() async {
    final data = await _dokumentasiService.fetchPenjadwalan();
    setState(() {
      penjadwalanList = data;
    });
  }

  Future<bool> _requestPermission(ImageSource source) async {
    Permission permission;
    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      if (Platform.isAndroid) {
        permission = Permission.storage;
      } else {
        permission = Permission.photos;
      }
    }

    var status = await permission.status;
    if (!status.isGranted) {
      status = await permission.request();
    }

    return status.isGranted;
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();

    await showModalBottomSheet<XFile?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto Dari Kamera'),
              onTap: () async {
                Navigator.pop(ctx);
                final hasPermission = await _requestPermission(ImageSource.camera);
                if (hasPermission) {
                  final image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    _videoController?.dispose();
                    setState(() => file = image);
                  }
                } else {
                  _showDeniedSnackBar("kamera");
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Ambil Video Dari Kamera'),
              onTap: () async {
                Navigator.pop(ctx);
                final hasPermission = await _requestPermission(ImageSource.camera);
                if (hasPermission) {
                  final video = await picker.pickVideo(source: ImageSource.camera);
                  if (video != null) {
                    _videoController?.dispose(); // dispose before setting new
                    setState(() => file = video);
                    _videoController = VideoPlayerController.file(File(video.path))
                      ..initialize().then((_) {
                        setState(() {});
                        _videoController!.setLooping(true);
                        _videoController!.play();
                      });
                  }
                } else {
                  _showDeniedSnackBar("kamera");
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Pilih Gambar dari Galeri'),
              onTap: () async {
                Navigator.pop(ctx);
                final hasPermission = await _requestPermission(ImageSource.gallery);
                if (hasPermission) {
                  final image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    _videoController?.dispose();
                    setState(() => file = image);
                  }
                } else {
                  _showDeniedSnackBar("galeri");
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Pilih Video dari Galeri'),
              onTap: () async {
                Navigator.pop(ctx);
                final hasPermission = await _requestPermission(ImageSource.gallery);
                if (hasPermission) {
                  final video = await picker.pickVideo(source: ImageSource.gallery);
                  if (video != null) {
                    _videoController?.dispose();
                    setState(() => file = video);
                    _videoController = VideoPlayerController.file(File(video.path))
                      ..initialize().then((_) {
                        setState(() {});
                        _videoController!.setLooping(true);
                        _videoController!.play();
                      });
                  }
                } else {
                  _showDeniedSnackBar("galeri");
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeniedSnackBar(String source) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Izin $source ditolak")),
    );
  }

  Future<void> _submit() async {
    if (file == null || selectedPenjadwalanId == null || _captionController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Peringatan'),
          content: const Text('Harap lengkapi semua data sebelum menyimpan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => loading = true);

    final upload = await _dokumentasiService.uploadFile(File(file!.path));
    if (upload == null) {
      setState(() => loading = false);
      return;
    }

    final dokumentasi = Dokumentasi(
      idPenjadwalan: selectedPenjadwalanId,
      uploadedBy: 1,
      captionDokumentasi: _captionController.text,
      fileName: upload['file_name'],
      filePath: upload['file_path'],
      fileUrl: upload['file_url'],
    );

    final result = await _dokumentasiService.tambahDokumentasi(dokumentasi);
    setState(() => loading = false);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Dokumentasi berhasil ditambahkan"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal menambahkan dokumentasi"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Dokumentasi'),
        backgroundColor: const Color(0xFF4A5F2F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedPenjadwalanId,
              hint: const Text('Pilih Penjadwalan'),
              items: penjadwalanList.map((e) {
                return DropdownMenuItem<int>(
                  value: e['id_Penjadwalan'],
                  child: Text(e['nama'] ?? '${e['nama_Penjadwalan']}'),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedPenjadwalanId = val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(labelText: 'Caption'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text(file == null ? 'Ambil Gambar / Video' : 'Ubah Gambar / Video'),
            ),
            if (file != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: file!.path.toLowerCase().endsWith('.mp4')
                    ? _videoController != null && _videoController!.value.isInitialized
                    ? SizedBox(
                  height: 200,
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                )
                    : const Text("Memuat video...")
                    : Image.file(
                  File(file!.path),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            loading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Simpan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// edit dokumentasi
class EditDokumentasi extends StatefulWidget {
  final Dokumentasi dokumentasi;

  const EditDokumentasi({super.key, required this.dokumentasi});

  @override
  State<EditDokumentasi> createState() => _EditDokumentasiScreenState();
}

class _EditDokumentasiScreenState extends State<EditDokumentasi> {
  final DokumentasiService _dokumentasiService = DokumentasiService();
  List<dynamic> penjadwalanList = [];
  VideoPlayerController? _videoController;

  final TextEditingController _captionController = TextEditingController();
  int? selectedPenjadwalanId;
  XFile? file;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadPenjadwalan();
    _captionController.text = widget.dokumentasi.captionDokumentasi ?? '';
    selectedPenjadwalanId = widget.dokumentasi.idPenjadwalan;

    if ((widget.dokumentasi.fileName ?? '').toLowerCase().endsWith('.mp4')) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.dokumentasi.fileUrl! + widget.dokumentasi.filePath! + widget.dokumentasi.fileName!))
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _loadPenjadwalan() async {
    final data = await _dokumentasiService.fetchPenjadwalan();
    setState(() {
      penjadwalanList = data;
    });
  }

  Future<bool> _requestPermission(ImageSource source) async {
    Permission permission;
    if (source == ImageSource.camera) {
      permission = Permission.camera;
    } else {
      if (Platform.isAndroid) {
        permission = Permission.storage;
      } else {
        permission = Permission.photos;
      }
    }

    var status = await permission.status;
    if (!status.isGranted) {
      status = await permission.request();
    }

    return status.isGranted;
  }

  Future<void> _pickFile() async {
    final picker = ImagePicker();

    await showModalBottomSheet<XFile?>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Pilih Gambar dari Galeri'),
              onTap: () async {
                Navigator.pop(ctx);
                final hasPermission = await _requestPermission(ImageSource.gallery);
                if (hasPermission) {
                  final image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    _videoController?.dispose();
                    setState(() => file = image);
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Pilih Video dari Galeri'),
              onTap: () async {
                Navigator.pop(ctx);
                final hasPermission = await _requestPermission(ImageSource.gallery);
                if (hasPermission) {
                  final video = await picker.pickVideo(source: ImageSource.gallery);
                  if (video != null) {
                    _videoController?.dispose();
                    setState(() => file = video);
                    _videoController = VideoPlayerController.file(File(video.path))
                      ..initialize().then((_) {
                        setState(() {});
                        _videoController!.setLooping(true);
                        _videoController!.play();
                      });
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (selectedPenjadwalanId == null || _captionController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Peringatan'),
          content: const Text('Harap lengkapi semua data sebelum menyimpan.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => loading = true);

    String? fileName = widget.dokumentasi.fileName;
    String? filePath = widget.dokumentasi.filePath;
    String? fileUrl = widget.dokumentasi.fileUrl;

    if (file != null) {
      final upload = await _dokumentasiService.uploadFile(File(file!.path));
      if (upload == null) {
        setState(() => loading = false);
        return;
      }

      fileName = upload['file_name'];
      filePath = upload['file_path'];
      fileUrl = upload['file_url'];
    }

    final updatedDokumentasi = Dokumentasi(
      idDokumentasi: widget.dokumentasi.idDokumentasi,
      idPenjadwalan: selectedPenjadwalanId,
      uploadedBy: widget.dokumentasi.uploadedBy,
      captionDokumentasi: _captionController.text,
      fileName: fileName,
      filePath: filePath,
      fileUrl: fileUrl,
    );

    final result = await _dokumentasiService.updateDokumentasi(updatedDokumentasi);
    setState(() => loading = false);

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Edit dokumentasi berhasil"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Gagal edit dokumentasi"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Dokumentasi'),
        backgroundColor: const Color(0xFF4A5F2F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedPenjadwalanId,
              hint: const Text('Pilih Penjadwalan'),
              items: penjadwalanList.map((e) {
                return DropdownMenuItem<int>(
                  value: e['id_Penjadwalan'],
                  child: Text(e['nama'] ?? 'Penjadwalan ${e['id_Penjadwalan']}'),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedPenjadwalanId = val),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(labelText: 'Caption'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text(file == null ? widget.dokumentasi.fileName == null ? 'Tambah Gambar / Video' : 'Ubah Gambar / Video': 'Ubah Gambar / Video'),
            ),
            const SizedBox(height: 20),
            if (file != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: file!.path.toLowerCase().endsWith('.mp4')
                    ? _videoController != null && _videoController!.value.isInitialized
                    ? SizedBox(
                  height: 200,
                  child: AspectRatio(
                    aspectRatio: _videoController!.value.aspectRatio,
                    child: VideoPlayer(_videoController!),
                  ),
                )
                    : const Text("Memuat video...")
                    : Image.file(
                  File(file!.path),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            ] else if ((widget.dokumentasi.fileName ?? '').toLowerCase().endsWith('.mp4')) ...[
              _videoController != null && _videoController!.value.isInitialized
                  ? SizedBox(
                height: 200,
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              )
                  : const Text("Memuat video...")
            ] else if ((widget.dokumentasi.fileUrl != null) &&
                (widget.dokumentasi.filePath != null) &&
                (widget.dokumentasi.fileName != null)) ...[
              Image.network(
                widget.dokumentasi.fileUrl! +
                    widget.dokumentasi.filePath! +
                    widget.dokumentasi.fileName!,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image),
              ),
            ],
            const SizedBox(height: 20),
            loading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
