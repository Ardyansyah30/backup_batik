import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanApiService {
  final String _baseUrl = 'http://127.0.0.1:8000/api'; // Ganti dengan URL backend Laravel Anda

  Future<Map<String, dynamic>?> uploadScanResult({
    required File imageFile,
    required bool isBatik,
    String? batikName,
    double? batikConfidence,
    String? batikOrigin,
    String? batikPhilosophy,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/scans'));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      request.fields['is_batik'] = isBatik.toString(); // Kirim boolean sebagai string
      if (batikName != null) request.fields['batik_name'] = batikName;
      if (batikConfidence != null) request.fields['batik_confidence'] = batikConfidence.toString();
      if (batikOrigin != null) request.fields['batik_origin'] = batikOrigin;
      if (batikPhilosophy != null) request.fields['batik_philosophy'] = batikPhilosophy;

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        print('Gagal mengunggah hasil scan: ${response.statusCode}');
        print('Respons: $responseBody');
        return null;
      }
    } catch (e) {
      print('Error saat mengunggah hasil scan: $e');
      return null;
    }
  }
}