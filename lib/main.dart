import 'package:flutter/material.dart';
import 'package:batik/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batik Identifier',
      theme: ThemeData(
        primarySwatch: Colors.indigo, // Contoh tema warna
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(), // Set halaman UploadPage sebagai halaman awal
    );
  }
}