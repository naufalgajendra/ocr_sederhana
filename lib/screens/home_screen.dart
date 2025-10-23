import 'package:flutter/material.dart';
import 'scan_screen.dart';

/// Menampilkan menu untuk memulai pemindaian teks
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar di bagian atas layar
      appBar: AppBar(
        title: const Text('Menu Utama'),
      ),
      
      // Body menggunakan ListView agar bisa menampung banyak item menu
      body: ListView(
        children: [
          // ListTile - Item menu untuk memulai scan teks
          ListTile(
            // Icon kamera di sebelah kiri dengan warna biru
            leading: const Icon(Icons.camera_alt, color: Colors.blue),
            
            // Teks judul menu
            title: const Text('Mulai Pindai Teks Baru'),
            
            // Fungsi yang dijalankan ketika ListTile di-tap
            onTap: () {
              // Navigasi ke halaman ScanScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ScanScreen(),
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}