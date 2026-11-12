import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

/// Kết quả của thao tác tải file lên dịch vụ lưu trữ đám mây.
class UploadResult {
  /// Đường dẫn lưu trữ nội bộ của file trên Cloud Storage (vd: `reports/uid/file.pdf`).
  final String path;

  /// Đường dẫn tải trực tiếp công khai hoặc URL bảo mật có chữ ký.
  final String downloadUrl;

  /// Kích thước file được tải lên tính theo byte.
  final int fileSizeBytes;

  /// Khởi tạo [UploadResult] với đầy đủ thuộc tính kết quả.
  const UploadResult({
    required this.path,
    required this.downloadUrl,
    required this.fileSizeBytes,
  });
}

/// Dịch vụ quản lý tệp tin và lưu trữ đám mây qua Firebase Cloud Storage.
///
/// Quản lý phân quyền lưu trữ theo thư mục riêng biệt của từng sinh viên: `reports/{uid}/...`
/// và hỗ trợ cơ chế cầu nối dự phòng (bridge fallback) khi chạy trên Web/Emulator.
class StorageService {
  final FirebaseStorage? _storage;

  /// Khởi tạo [StorageService] với tùy chọn [FirebaseStorage] phục vụ kiểm thử.
  StorageService([this._storage]);

  /// Tải mảng byte dữ liệu [bytes] lên Firebase Storage theo thư mục của [userId].
  ///
  /// Nhận vào tên tệp [fileName], thư mục gốc [folder] (mặc định là `reports`),
  /// và hàm gọi lại theo dõi tiến trình tải lên [onProgress].
  Future<UploadResult> uploadFileBytes({
    required String userId,
    required String fileName,
    required Uint8List bytes,
    String folder = 'reports',
    Function(double progress)? onProgress,
  }) async {
    final sanitizedFileName = fileName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final storagePath = '$folder/$userId/$sanitizedFileName';

    try {
      if (_storage != null) {
        final ref = _storage.ref().child(storagePath);
        final metadata = SettableMetadata(
          contentType: 'application/pdf',
          customMetadata: {'uploadedBy': userId, 'timestamp': DateTime.now().toIso8601String()},
        );

        final uploadTask = ref.putData(bytes, metadata);

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          if (snapshot.totalBytes > 0) {
            final progress = snapshot.bytesTransferred / snapshot.totalBytes;
            onProgress?.call(progress);
          }
        });

        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();

        debugPrint('[StorageService] File uploaded successfully to $storagePath');
        return UploadResult(
          path: storagePath,
          downloadUrl: downloadUrl,
          fileSizeBytes: bytes.length,
        );
      } else {
        // Fallback / Web mode via Web Portal API bridge
        onProgress?.call(0.5);
        final base64Data = base64Encode(bytes);
        for (final base in ['http://localhost:3000', 'http://10.0.2.2:3000']) {
          try {
            final res = await http.post(
              Uri.parse('$base/api/upload'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'path': storagePath,
                'fileName': sanitizedFileName,
                'contentType': 'application/pdf',
                'base64': base64Data,
              }),
            ).timeout(const Duration(seconds: 4));
            if (res.statusCode == 200) {
              final json = jsonDecode(res.body);
              final url = json['downloadUrl'] as String? ?? '$base/api/storage/$storagePath';
              onProgress?.call(1.0);
              debugPrint('[StorageService] File uploaded via Web Portal bridge: $url');
              return UploadResult(
                path: storagePath,
                downloadUrl: url,
                fileSizeBytes: bytes.length,
              );
            }
          } catch (_) {}
        }

        // Offline / in-memory data URI fallback
        onProgress?.call(1.0);
        final dataUri = 'data:application/pdf;base64,$base64Data';
        return UploadResult(
          path: storagePath,
          downloadUrl: dataUri,
          fileSizeBytes: bytes.length,
        );
      }
    } catch (e) {
      debugPrint('[StorageService] Error uploading file: $e');
      rethrow;
    }
  }
}
