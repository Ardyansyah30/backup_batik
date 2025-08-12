// lib/pages/register_page.dart

import 'dart:convert';
import 'package:flutter/material.dart'; // ✅ Import yang benar
import 'package:quickalert/quickalert.dart';
import 'package:batik/pages/login_page.dart'; // ✅ Impor LoginPage untuk navigasi
import 'package:batik/pages/upload_page.dart';
import 'package:batik/services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // ... (kode lainnya)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8B4513),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // ... (isi widget Anda)
          TextButton(
            onPressed: () { // ✅ onPressed tidak bisa const
              Navigator.pop(context); // Kembali ke halaman sebelumnya (LoginPage)
            },
            child: const Text(
              'Sudah punya akun? Login di sini',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}