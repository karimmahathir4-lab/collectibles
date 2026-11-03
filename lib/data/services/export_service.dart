import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'database_service.dart';

class ExportService {
  static final ExportService instance = ExportService._internal();
  ExportService._internal();

  /// Exports collection metadata to CSV
  Future<void> exportCsv() async {
    final artworks = await DatabaseService.instance.getAllArtworks();
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln(
      'ID,Title,Artist,Year,Medium,Width(cm),Height(cm),Depth(cm),Weight(kg),EditionNumber,EditionSize,PurchaseDate,PurchasePrice,Currency,EstimatedValue,Condition,Location,Notes',
    );

    for (final a in artworks) {
      final pDate = a.purchaseDate != null
          ? DateFormat('yyyy-MM-dd').format(a.purchaseDate!)
          : '';
      buffer.writeln(
        '"${a.id}","${_escape(a.title)}","${_escape(a.artist ?? '')}","${a.yearCreated ?? ''}","${_escape(a.medium ?? '')}","${a.widthCm ?? ''}","${a.heightCm ?? ''}","${a.depthCm ?? ''}","${a.weightKg ?? ''}","${a.editionNumber ?? ''}","${a.editionSize ?? ''}","$pDate","${a.purchasePrice ?? ''}","${a.purchaseCurrency ?? 'USD'}","${a.estimatedValue ?? ''}","${a.condition ?? ''}","${_escape(a.location ?? '')}","${_escape(a.notes ?? '')}"',
      );
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = p.join(
      tempDir.path,
      'handcraft_collectibles_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.csv',
    );
    final file = File(filePath);
    await file.writeAsString(buffer.toString());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath, mimeType: 'text/csv')],
        subject: 'HandCraft Collectibles CSV Export',
      ),
    );
  }

  /// Exports full collection archive (JSON + images) as ZIP
  Future<void> exportZipArchive() async {
    final artworks = await DatabaseService.instance.getAllArtworks();
    final folders = await DatabaseService.instance.getAllFolders();
    final wishlist = await DatabaseService.instance.getAllWishlistItems();

    final exportData = {
      'app': 'HandCraft Collectibles',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'artworks': artworks.map((a) => a.toMap()).toList(),
      'folders': folders.map((f) => f.toMap()).toList(),
      'wishlist': wishlist.map((w) => w.toMap()).toList(),
    };

    final tempDir = await getTemporaryDirectory();
    final exportDir = Directory(
      p.join(
        tempDir.path,
        'backup_export_${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    await exportDir.create();

    // Write manifest JSON
    final jsonFile = File(p.join(exportDir.path, 'manifest.json'));
    await jsonFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(exportData),
    );

    // Copy images
    final imagesFolder = Directory(p.join(exportDir.path, 'images'));
    await imagesFolder.create();

    for (final art in artworks) {
      if (art.coverPhotoPath != null &&
          File(art.coverPhotoPath!).existsSync()) {
        final artImgDir = Directory(p.join(imagesFolder.path, art.id));
        if (!artImgDir.existsSync()) artImgDir.createSync(recursive: true);
        final f = File(art.coverPhotoPath!);
        f.copySync(p.join(artImgDir.path, p.basename(art.coverPhotoPath!)));
      }
      for (final pth in art.photoPaths) {
        if (File(pth).existsSync()) {
          final artImgDir = Directory(p.join(imagesFolder.path, art.id));
          if (!artImgDir.existsSync()) artImgDir.createSync(recursive: true);
          File(pth).copySync(p.join(artImgDir.path, p.basename(pth)));
        }
      }
    }

    // Zip folder
    final zipFile = File(
      p.join(
        tempDir.path,
        'HandCraft_Collectibles_Backup_${DateFormat('yyyyMMdd').format(DateTime.now())}.zip',
      ),
    );
    final encoder = ZipFileEncoder();
    encoder.create(zipFile.path);
    encoder.addDirectory(exportDir);
    encoder.close();

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(zipFile.path, mimeType: 'application/zip')],
        subject: 'HandCraft Collectibles Backup',
      ),
    );
  }

  String _escape(String val) => val.replaceAll('"', '""');
}
