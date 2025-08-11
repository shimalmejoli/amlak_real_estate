// lib/model/project_image.dart

import 'dart:convert';
import 'dart:typed_data';

class ProjectImage {
  final int id;
  final int projectId;
  final String? mimeType;
  final Uint8List? bytes;
  final DateTime? uploadedAt;

  ProjectImage({
    required this.id,
    required this.projectId,
    this.mimeType,
    this.bytes,
    this.uploadedAt,
  });

  factory ProjectImage.fromJson(Map<String, dynamic> json) {
    final b64 = json['image_base64'] as String?;
    Uint8List? bs;
    if (b64 != null && b64.isNotEmpty) {
      bs = base64Decode(b64);
    }
    return ProjectImage(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      mimeType: json['mime_type'] as String?,
      bytes: bs,
      uploadedAt: json['uploaded_at'] != null
          ? DateTime.parse(json['uploaded_at'] as String)
          : null,
    );
  }
}
