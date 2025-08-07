import 'dart:async';
import 'package:flutter/material.dart';
import 'upload_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Atur timer untuk pindah ke UploadPage setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const UploadPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Latar belakang gambar yang memenuhi seluruh layar
          Image.asset(
            'assets/background1.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.white, // Ganti dengan warna solid jika gambar tidak ditemukan
                child: const Center(
                  child: Text('Latar belakang tidak ditemukan'),
                ),
              );
            },
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Anda bisa menempatkan logo atau elemen lain di sini
                // sebagai contoh, saya menggunakan gambar dari background1.png
                // yang sudah ada di tengah. Jika ingin menambahkan logo terpisah,
                // tambahkan Image.asset() di sini.
              ],
            ),
          ),
        ],
      ),
    );
  }
}
