import 'package:flutter/material.dart';
import 'package:batik/pages/upload_page.dart'; // Pastikan pathnya benar

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Batik App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: const UploadPage(), // Pastikan ini menunjuk ke UploadPage
    );
  }
}