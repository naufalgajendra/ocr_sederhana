import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'result_screen.dart';

late List<CameraDescription> cameras;

/// ScanScreen - Halaman untuk mengambil foto dan melakukan OCR
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  /// Inisialisasi kamera saat pertama kali masuk halaman
  Future<void> _initCamera() async {
    try {
      cameras = await availableCameras();
      
      if (cameras.isEmpty) {
        setState(() {
          _errorMessage = 'Tidak ada kamera yang tersedia';
        });
        return;
      }

      _controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      
      // Pastikan flash mode off
      await _controller!.setFlashMode(FlashMode.off);

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inisialisasi kamera: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Melakukan OCR dari file gambar menggunakan ML Kit
  Future<String> _ocrFromFile(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);
    textRecognizer.close();
    return recognizedText.text;
  }

  /// Mengambil foto dan memproses OCR
  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamera belum siap')),
      );
      return;
    }

    try {
      // Pastikan flash tetap off sebelum ambil foto
      await _controller!.setFlashMode(FlashMode.off);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memproses OCR, mohon tunggu...'),
          duration: Duration(seconds: 2),
        ),
      );

      final XFile image = await _controller!.takePicture();
      final ocrText = await _ocrFromFile(File(image.path));

      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(ocrText: ocrText),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      // PERUBAHAN: Pesan error lebih user-friendly tanpa detail teknis
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pemindaian Gagal! Periksa Izin Kamera atau coba lagi.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kamera OCR'),
      ),
      body: _buildBody(),
    );
  }

  /// Membangun tampilan body sesuai state (error, loading, atau ready)
  Widget _buildBody() {
    // Tampilan jika ada error
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isInitialized = false;
                });
                _initCamera();
              },
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    // PERUBAHAN: Tampilan loading dengan styling baru
    // Background gelap dengan indikator kuning dan teks putih
    if (!_isInitialized || _controller == null) {
      return Scaffold(
        // Background abu gelap
        backgroundColor: Colors.grey[900],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // CircularProgressIndicator dengan warna kuning
              const CircularProgressIndicator(
                color: Colors.yellow,
              ),
              const SizedBox(height: 16),
              // Teks loading dengan warna putih dan ukuran 18
              const Text(
                'Memuat Kamera... Harap tunggu.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Tampilan kamera siap digunakan
    return Column(
      children: [
        // Preview kamera memenuhi layar
        Expanded(
          child: CameraPreview(_controller!),
        ),
        // Tombol untuk ambil foto dan scan
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _takePicture,
            icon: const Icon(Icons.camera),
            label: const Text('Ambil Foto & Scan'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}