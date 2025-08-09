// lib/history_page.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/batik.dart'; // Impor model Batik

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  // Ganti IP ini dengan IP lokal komputer Anda jika menggunakan perangkat fisik.
  // Contoh: 'http://192.168.1.7:8000'
  final String _backendBaseUrl = 'http://10.0.2.2:8000';
  final String _backendApiUrl = 'http://10.0.2.2:8000/api';

  late Future<List<Batik>> _batikHistory;

  @override
  void initState() {
    super.initState();
    _batikHistory = _fetchBatikHistory();
  }

  Future<List<Batik>> _fetchBatikHistory() async {
    try {
      final response = await http.get(Uri.parse('$_backendApiUrl/batiks'));

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse.map((batik) => Batik.fromJson(batik)).toList();
      } else {
        throw Exception('Gagal memuat riwayat batik. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error koneksi saat memuat riwayat: $e');
      throw Exception('Gagal terhubung ke server untuk memuat riwayat.');
    }
  }

  Future<void> _deleteBatik(int batikId) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final response = await http.delete(
        Uri.parse('$_backendApiUrl/batiks/$batikId'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _batikHistory = _fetchBatikHistory();
        });
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Batik berhasil dihapus!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus batik. Status: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
        throw Exception('Gagal menghapus batik. Status: ${response.statusCode}');
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Unggahan Batik',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: const Color(0xFFEAE3D6),
        child: FutureBuilder<List<Batik>>(
          future: _batikHistory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 50),
                      const SizedBox(height: 10),
                      Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _batikHistory = _fetchBatikHistory();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B4513),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 50),
                    SizedBox(height: 10),
                    Text(
                      'Belum ada riwayat unggahan batik.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  Batik batik = snapshot.data![index];
                  // Gunakan _backendBaseUrl untuk URL gambar yang benar
                  final String imageUrl = '$_backendBaseUrl/storage/batik_images/${batik.filename}';

                  // --- Baris penambahan untuk debug ---
                  print('Mencoba memuat gambar dari URL: $imageUrl');
                  // ------------------------------------

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 5.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image, color: Colors.red, size: 50),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  batik.batikName ?? 'Batik Tidak Dikenali',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Color(0xFF8B4513),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Hapus Riwayat'),
                                        content: const Text('Apakah Anda yakin ingin menghapus riwayat batik ini?'),
                                        actions: [
                                          TextButton(
                                            child: const Text('Batal'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Hapus'),
                                            onPressed: () {
                                              _deleteBatik(batik.id);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Asal: ${batik.origin ?? 'Tidak Diketahui'}',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Status: ${batik.isMinangkabauBatik ? 'Batik Minangkabau' : 'Bukan Batik Minangkabau'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: batik.isMinangkabauBatik ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Filosofi:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            batik.description ?? 'Filosofi tidak tersedia.',
                            style: const TextStyle(fontSize: 14, color: Colors.black54),
                            textAlign: TextAlign.justify,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Diunggah: ${batik.createdAt.toLocal().toString().split('.')[0]}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}