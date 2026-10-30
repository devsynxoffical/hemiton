import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

/// Service responsible for persisting media files (images, videos) into the
/// persistent application documents directory so they survive cache cleanups,
/// device restarts, and offline application launches.
class LocalMediaService {
  static final LocalMediaService instance = LocalMediaService._internal();
  LocalMediaService._internal();

  static const _uuid = Uuid();
  Directory? _documentsDir;

  /// Retrieves or caches the persistent application documents directory.
  Future<Directory> _getPersistentDirectory() async {
    if (_documentsDir != null && _documentsDir!.existsSync()) {
      return _documentsDir!;
    }
    try {
      final appDoc = await getApplicationDocumentsDirectory();
      _documentsDir = appDoc;
      return appDoc;
    } catch (e) {
      debugPrint('[LocalMediaService] getApplicationDocumentsDirectory fallback: $e');
      final fallback = Directory('${Directory.systemTemp.path}/hemiton_app_docs');
      if (!fallback.existsSync()) {
        fallback.createSync(recursive: true);
      }
      _documentsDir = fallback;
      return fallback;
    }
  }

  /// Copies a media file (from camera or gallery temporary cache) into
  /// a persistent application directory.
  ///
  /// Returns the persistent local absolute file path.
  Future<String> saveMediaFile(
    String sourcePath, {
    String subFolder = 'media',
  }) async {
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw FileSystemException('Source media file not found', sourcePath);
    }

    final baseDir = await _getPersistentDirectory();
    final targetFolder = Directory('${baseDir.path}/hemiton_persistent_media/$subFolder');
    if (!await targetFolder.exists()) {
      await targetFolder.create(recursive: true);
    }

    // Extract file extension or default based on folder
    String ext = '';
    final lastDot = sourcePath.lastIndexOf('.');
    if (lastDot != -1 && lastDot < sourcePath.length - 1) {
      ext = sourcePath.substring(lastDot);
    } else {
      ext = subFolder == 'videos' ? '.mp4' : '.jpg';
    }

    final uniqueName = '${subFolder}_${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 8)}$ext';
    final targetPath = '${targetFolder.path}/$uniqueName';

    // Copy file to persistent location
    final copiedFile = await sourceFile.copy(targetPath);
    if (!await copiedFile.exists()) {
      throw FileSystemException('Failed to copy media file to persistent storage', targetPath);
    }

    debugPrint('[LocalMediaService] Saved persistent media to: $targetPath (${await copiedFile.length()} bytes)');
    return targetPath;
  }

  /// Batch saves multiple media files and returns their persistent paths.
  Future<List<String>> saveMediaFiles(
    List<String> sourcePaths, {
    String subFolder = 'media',
  }) async {
    final List<String> savedPaths = [];
    for (final path in sourcePaths) {
      if (path.isNotEmpty) {
        final saved = await saveMediaFile(path, subFolder: subFolder);
        savedPaths.add(saved);
      }
    }
    return savedPaths;
  }

  /// Checks if a given path is a local file on the device.
  bool isLocalPath(String? path) {
    if (path == null || path.isEmpty) return false;
    final lower = path.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://') || lower.startsWith('assets/')) {
      return false;
    }
    return true;
  }

  /// Safely checks if a local file exists.
  bool fileExists(String? path) {
    if (!isLocalPath(path)) return false;
    try {
      return File(path!).existsSync();
    } catch (_) {
      return false;
    }
  }

  /// Deletes a persistent media file if it exists.
  Future<void> deleteMediaFile(String? path) async {
    if (isLocalPath(path)) {
      try {
        final f = File(path!);
        if (await f.exists()) {
          await f.delete();
          debugPrint('[LocalMediaService] Deleted file: $path');
        }
      } catch (e) {
        debugPrint('[LocalMediaService] Error deleting file $path: $e');
      }
    }
  }
}
