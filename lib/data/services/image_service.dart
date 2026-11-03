import 'dart:io'
    if (dart.library.js_interop) 'package:handcollect/core/utils/platform_stub.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  static final ImageService instance = ImageService._internal();
  ImageService._internal();

  Future<String> saveImage(String sourceFilePath, {String? artworkId}) async {
    if (kIsWeb) {
      return sourceFilePath;
    }

    String baseDir = '';
    try {
      final appDir = await getApplicationDocumentsDirectory();
      baseDir = appDir.path;
    } catch (_) {
      baseDir = '';
    }

    final targetFolder = artworkId != null
        ? Directory(p.join(baseDir, 'images', artworkId))
        : Directory(p.join(baseDir, 'images', 'general'));

    if (!await targetFolder.exists()) {
      await targetFolder.create(recursive: true);
    }

    final ext = p.extension(sourceFilePath).isEmpty
        ? '.jpg'
        : p.extension(sourceFilePath);
    final filename = '${const Uuid().v4()}$ext';
    final targetPath = p.join(targetFolder.path, filename);

    final sourceFile = File(sourceFilePath);
    await sourceFile.copy(targetPath);

    return targetPath;
  }

  Future<void> deleteArtworkImages(String artworkId) async {
    if (kIsWeb) return;
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final targetFolder = Directory(p.join(appDir.path, 'images', artworkId));
      if (await targetFolder.exists()) {
        await targetFolder.delete(recursive: true);
      }
    } catch (_) {}
  }
}
