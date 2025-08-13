import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ContributionPage extends StatefulWidget {
  const ContributionPage({super.key});

  @override
  State<ContributionPage> createState() => _ContributionPageState();
}

class _ContributionPageState extends State<ContributionPage> {
  File? _selectedImage;
  final TextEditingController _batikNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final String _backendApiUrl = 'http://10.0.2.2:8000/api';

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _submitContribution() async {
    if (!_formKey.currentState!.validate() || _selectedImage == null) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.warning,
        title: 'Formulir Tidak Lengkap',
        text: 'Mohon lengkapi semua bidang dan pilih gambar.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Akses Ditolak',
          text: 'Anda harus login untuk mengunggah kontribusi.',
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    final uri = Uri.parse('$_backendApiUrl/contributions');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['batik_name'] = _batikNameController.text;
    request.fields['description'] = _descriptionController.text;
    request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      if (mounted) {
        if (response.statusCode == 201) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.success,
            title: 'Berhasil',
            text: 'Kontribusi Anda berhasil diunggah dan akan ditinjau.',
          ).then((_) {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          });
        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Gagal',
            text: 'Gagal mengunggah kontribusi. Status: ${response.statusCode}. Respon: $responseBody',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Koneksi Gagal',
          text: 'Gagal terhubung ke server: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kontribusi Batik', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8B4513),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Area untuk memilih gambar
              GestureDetector(
                onTap: () => _pickImage(ImageSource.gallery),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover))
                      : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Ketuk untuk pilih gambar batik', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Formulir untuk nama batik
              TextFormField(
                controller: _batikNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Batik (contoh: "Motif Batik Kudo-Kudo")',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama batik tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Formulir untuk deskripsi/filosofi
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi atau Filosofi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Deskripsi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitContribution,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B4513),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Kirim Kontribusi', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}