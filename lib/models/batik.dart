// lib/models/batik.dart

import 'package:flutter/foundation.dart'; // Import for @required

class Batik {
  final int id;
  final String filename;
  final String path;
  final String originalName;
  final bool isMinangkabauBatik;
  final String? batikName;
  final String? description;
  final String? origin;
  final DateTime createdAt;
  final DateTime updatedAt;

  Batik({
    required this.id,
    required this.filename,
    required this.path,
    required this.originalName,
    required this.isMinangkabauBatik,
    this.batikName,
    this.description,
    this.origin,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Batik.fromJson(Map<String, dynamic> json) {
    return Batik(
      id: json['id'],
      filename: json['filename'],
      path: json['path'],
      originalName: json['original_name'],
      isMinangkabauBatik: json['is_minangkabau_batik'] == 1, // Konversi int 1/0 ke boolean
      batikName: json['batik_name'],
      description: json['description'],
      origin: json['origin'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}