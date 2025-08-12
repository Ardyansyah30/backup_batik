// lib/pages/login_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';
import 'package:batik/pages/upload_page.dart';
import 'package:batik/pages/register_page.dart'; // ✅ Pastikan hanya ada 1 import ke RegisterPage
import 'package:batik/services/api_service.dart'; // ✅ Pastikan hanya ada 1 import ke ApiService

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // ... (kode lainnya)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ... (pastikan semua widget berada di dalam widget Scaffold)
      body: Stack(
        children: [
          // ... (isi widget Anda)
          TextButton(
            onPressed: () { // ✅ Perhatikan: onPressed tidak bisa const
              Navigator.push(
                context,
                // ✅ Perhatikan: MaterialPageRoute tidak bisa const
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
            },
            child: const Text(
              'Belum punya akun? Daftar di sini',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          // ... (pastikan semua kurung tertutup dengan benar)
        ],
      ),
    );
  }
}