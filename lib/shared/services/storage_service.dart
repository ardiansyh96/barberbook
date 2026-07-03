import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/firebase_collections.dart';
import '../../core/utils/logger.dart';

/// Service for uploading and managing files in Firebase Storage.
///
/// Handles profile photos, barber images, service images, and banners.
/// Generates unique filenames using UUID to prevent collisions.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();

  /// Upload a file to Firebase Storage and return the download URL.
  ///
  /// [file] - The local file to upload
  /// [folder] - The storage folder path (use [FirebaseCollections] constants)
  /// [onProgress] - Optional callback for upload progress (0.0 to 1.0)
  Future<String> uploadFile({
    required File file,
    required String folder,
    void Function(double progress)? onProgress,
  }) async {
    try {
      // Generate a unique filename to prevent collisions
      final extension = file.path.split('.').last;
      final fileName = '${_uuid.v4()}.$extension';
      final ref = _storage.ref().child(folder).child(fileName);

      // Upload with progress tracking
      final uploadTask = ref.putFile(file);

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((snapshot) {
          final progress =
              snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      await uploadTask.whenComplete(() => null);

      // Get and return the download URL
      final downloadUrl = await ref.getDownloadURL();
      logger.info('File uploaded: $folder/$fileName');
      return downloadUrl;
    } on FirebaseException catch (e) {
      logger.error('Upload error: ${e.code} - ${e.message}');
      throw Exception('Failed to upload file: ${e.message}');
    }
  }

  /// Delete a file from Firebase Storage by its URL.
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      logger.info('File deleted: $fileUrl');
    } on FirebaseException catch (e) {
      logger.error('Delete file error: ${e.code}');
      throw Exception('Failed to delete file: ${e.message}');
    }
  }

  /// Upload a user profile photo
  Future<String> uploadProfilePhoto(File file, String userId) async {
    return uploadFile(
      file: file,
      folder: '${FirebaseCollections.storageUserPhotos}/$userId',
    );
  }

  /// Upload a barber photo
  Future<String> uploadBarberPhoto(File file, String barberId) async {
    return uploadFile(
      file: file,
      folder: '${FirebaseCollections.storageBarberPhotos}/$barberId',
    );
  }

  /// Upload a service image
  Future<String> uploadServiceImage(File file, String serviceId) async {
    return uploadFile(
      file: file,
      folder: '${FirebaseCollections.storageServiceImages}/$serviceId',
    );
  }

  /// Upload a banner image
  Future<String> uploadBannerImage(File file) async {
    return uploadFile(
      file: file,
      folder: FirebaseCollections.storageBannerImages,
    );
  }
}
