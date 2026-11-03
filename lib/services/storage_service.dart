import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UploadResult {
  final String path;
  final String downloadUrl;
  final int fileSizeBytes;

  const UploadResult({
    required this.path,
    required this.downloadUrl,
    required this.fileSizeBytes,
  });
}

/// Firebase Cloud Storage Service Wrapper
/// Uploads files strictly under per-user directories: reports/{uid}/...
class StorageService {
  final FirebaseStorage? _storage;

  StorageService([this._storage]);

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
        // Mock fallback simulation for tests / desktop verification
        for (int i = 1; i <= 5; i++) {
          await Future.delayed(const Duration(milliseconds: 60));
          onProgress?.call(i / 5.0);
        }
        final mockUrl = 'https://firebasestorage.googleapis.com/v0/b/campus-event-48443.firebasestorage.app/o/${Uri.encodeComponent(storagePath)}?alt=media';
        debugPrint('[StorageService] Mock upload completed: $mockUrl');
        return UploadResult(
          path: storagePath,
          downloadUrl: mockUrl,
          fileSizeBytes: bytes.length,
        );
      }
    } catch (e) {
      debugPrint('[StorageService] Upload error: $e');
      rethrow;
    }
  }
}
