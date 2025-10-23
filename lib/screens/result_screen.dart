import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart'; // Import plugin TTS
import 'home_screen.dart'; // Import HomeScreen untuk navigasi

/// ResultScreen - Halaman untuk menampilkan hasil OCR
/// Menerima parameter ocrText dari halaman sebelumnya
/// PERUBAHAN: Diubah dari StatelessWidget menjadi StatefulWidget untuk TTS
class ResultScreen extends StatefulWidget {
  final String ocrText;

  const ResultScreen({super.key, required this.ocrText});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  // Instance FlutterTts untuk text-to-speech
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    // Inisialisasi FlutterTts saat halaman pertama kali dibuat
    _initTts();
  }

  /// Inisialisasi TTS dan mengatur bahasa ke Bahasa Indonesia
  Future<void> _initTts() async {
    flutterTts = FlutterTts();
    
    // Set bahasa ke Bahasa Indonesia
    await flutterTts.setLanguage("id-ID");
    
    // Opsional: Konfigurasi tambahan
    await flutterTts.setPitch(1.0); // Pitch suara normal
    await flutterTts.setSpeechRate(0.5); // Kecepatan bicara normal
  }

  @override
  void dispose() {
    // Hentikan TTS dan bersihkan resource saat halaman ditutup
    flutterTts.stop();
    super.dispose();
  }

  /// Fungsi untuk membacakan teks menggunakan TTS
  Future<void> _speakText() async {
    if (widget.ocrText.isEmpty) {
      // Jika tidak ada teks, beritahu user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak ada teks untuk dibacakan')),
      );
      return;
    }
    
    // Bacakan teks menggunakan TTS
    await flutterTts.speak(widget.ocrText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar di bagian atas dengan tombol speaker
      appBar: AppBar(
        title: const Text('Hasil OCR'),
        // PERUBAHAN: Tambah action button untuk TTS
        actions: [
          // Tombol untuk membacakan teks
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: 'Bacakan Teks',
            onPressed: _speakText,
          ),
        ],
      ),
      
      // Body menampilkan teks hasil OCR
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SelectableText(
            // Menampilkan teks OCR tanpa menghapus baris baru (\n)
            // Format asli tetap terjaga untuk keterbacaan
            widget.ocrText.isEmpty
                ? 'Tidak ada teks ditemukan.'
                : widget.ocrText, // Menampilkan teks dengan baris baru yang utuh
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      
      // FloatingActionButton untuk kembali ke Home
      floatingActionButton: FloatingActionButton(
        // Icon rumah untuk tombol home
        child: const Icon(Icons.home),
        
        // Fungsi ketika tombol ditekan
        onPressed: () {
          // Navigasi ke HomeScreen dan hapus semua halaman di stack
          // Menggunakan pushAndRemoveUntil untuk membersihkan history navigasi
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false, // Menghapus semua route sebelumnya
          );
        },
      ),
    );
  }
}