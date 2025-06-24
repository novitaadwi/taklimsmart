import 'dart:io';

import 'package:flutter/material.dart';
import 'package:taklimsmart/services/dokumentasi_service.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taklimsmart/models/dokumentasi.dart';

class DokumentasiWargaScreen extends StatefulWidget {
  const DokumentasiWargaScreen({super.key});

  @override
  State<DokumentasiWargaScreen> createState() => _DokumentasiWargaScreenState();
}

class _DokumentasiWargaScreenState extends State<DokumentasiWargaScreen> {
  final DokumentasiService _dokumentasiService = DokumentasiService();
  List<dynamic> dokumentasiList = [];
  Map<int, String?> videoThumbnails = {};

  Future<void> _loadDokumentasi() async {
    final data = await _dokumentasiService.fetchDokumentasi();
    setState(() {
      dokumentasiList = data;
    });
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