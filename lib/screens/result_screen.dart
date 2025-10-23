import 'package:flutter/material.dart';
import 'home_screen.dart'; // Import HomeScreen untuk navigasi

/// ResultScreen - Halaman untuk menampilkan hasil OCR
/// Menerima parameter ocrText dari halaman sebelumnya
class ResultScreen extends StatelessWidget {
  final String ocrText;

  const ResultScreen({super.key, required this.ocrText});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar di bagian atas
      appBar: AppBar(
        title: const Text('Hasil OCR'),
      ),
      
      // Body menampilkan teks hasil OCR
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: SelectableText(
            // Menampilkan teks OCR tanpa menghapus baris baru (\n)
            // PERUBAHAN: Dihapus .replaceAll('\n', ' ') agar format asli tetap terjaga
            ocrText.isEmpty
                ? 'Tidak ada teks ditemukan.'
                : ocrText, // Menampilkan teks dengan baris baru yang utuh
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      
      // PERUBAHAN: Tambahan FloatingActionButton untuk kembali ke Home
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