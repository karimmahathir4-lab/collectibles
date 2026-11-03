import 'dart:convert';
import 'dart:io'
    if (dart.library.js_interop) 'package:handcollect/core/utils/platform_stub.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/artwork.dart';
import '../models/collection_folder.dart';
import '../models/wishlist_item.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String dbPath = 'handcraft_collectibles.db';
    if (!kIsWeb) {
      try {
        final dbDir = await getApplicationDocumentsDirectory();
        dbPath = p.join(dbDir.path, 'handcraft_collectibles.db');
      } catch (_) {
        dbPath = 'handcraft_collectibles.db';
      }
    }

    return await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE artworks (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            artist TEXT,
            yearCreated INTEGER,
            medium TEXT,
            widthCm REAL,
            heightCm REAL,
            depthCm REAL,
            weightKg REAL,
            editionNumber INTEGER,
            editionSize INTEGER,
            purchaseDate TEXT,
            purchasePrice REAL,
            purchaseCurrency TEXT,
            seller TEXT,
            estimatedValue REAL,
            location TEXT,
            condition TEXT,
            conditionNotes TEXT,
            provenance TEXT,
            notes TEXT,
            isFavorite INTEGER DEFAULT 0,
            coverPhotoPath TEXT,
            photoPathsJson TEXT,
            tagsJson TEXT,
            collectionIdsJson TEXT,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE collection_folders (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            iconName TEXT,
            colorHex TEXT,
            sortOrder INTEGER DEFAULT 0,
            createdAt TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE wishlist_items (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            artist TEXT,
            targetPrice REAL,
            currency TEXT,
            whereSeen TEXT,
            url TEXT,
            notes TEXT,
            imagePath TEXT,
            priority INTEGER DEFAULT 2,
            createdAt TEXT NOT NULL,
            convertedArtworkId TEXT
          )
        ''');

        // Insert initial default collections
        final now = DateTime.now().toIso8601String();
        await db.insert('collection_folders', {
          'id': 'paintings',
          'name': 'Paintings & Canvas',
          'iconName': 'brush',
          'colorHex': '#E06D53',
          'sortOrder': 0,
          'createdAt': now,
        });
        await db.insert('collection_folders', {
          'id': 'sculptures',
          'name': 'Sculptures & Ceramics',
          'iconName': 'cube',
          'colorHex': '#4A90E2',
          'sortOrder': 1,
          'createdAt': now,
        });
        await db.insert('collection_folders', {
          'id': 'prints',
          'name': 'Limited Prints',
          'iconName': 'photo_album',
          'colorHex': '#7ED321',
          'sortOrder': 2,
          'createdAt': now,
        });
      },
    );
  }

  // --- Web In-Memory / SharedPreferences Fallback Storage ---
  static const String _webArtworksKey = 'web_artworks_store';
  static const String _webFoldersKey = 'web_folders_store';
  static const String _webWishlistKey = 'web_wishlist_store';

  // Artworks CRUD
  Future<List<Artwork>> getAllArtworks() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_webArtworksKey);
      if (str == null || str.isEmpty) return [];
      final List decoded = jsonDecode(str);
      return decoded.map((m) => Artwork.fromMap(m)).toList();
    }
    final db = await database;
    final maps = await db.query('artworks', orderBy: 'createdAt DESC');
    return maps.map((m) => Artwork.fromMap(m)).toList();
  }

  Future<Artwork?> getArtworkById(String id) async {
    final list = await getAllArtworks();
    final matches = list.where((a) => a.id == id);
    return matches.isNotEmpty ? matches.first : null;
  }

  Future<void> insertArtwork(Artwork artwork) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = await getAllArtworks();
      list.removeWhere((a) => a.id == artwork.id);
      list.insert(0, artwork);
      await prefs.setString(
        _webArtworksKey,
        jsonEncode(list.map((a) => a.toMap()).toList()),
      );
      return;
    }
    final db = await database;
    await db.insert(
      'artworks',
      artwork.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateArtwork(Artwork artwork) async {
    await insertArtwork(artwork);
  }

  Future<void> deleteArtwork(String id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = await getAllArtworks();
      list.removeWhere((a) => a.id == id);
      await prefs.setString(
        _webArtworksKey,
        jsonEncode(list.map((a) => a.toMap()).toList()),
      );
      return;
    }
    final db = await database;
    await db.delete('artworks', where: 'id = ?', whereArgs: [id]);
  }

  // Collections CRUD
  Future<List<CollectionFolder>> getAllFolders() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_webFoldersKey);
      if (str == null || str.isEmpty) {
        final initial = [
          CollectionFolder(
            id: 'paintings',
            name: 'Paintings & Canvas',
            createdAt: DateTime.now(),
          ),
          CollectionFolder(
            id: 'sculptures',
            name: 'Sculptures & Ceramics',
            createdAt: DateTime.now(),
          ),
          CollectionFolder(
            id: 'prints',
            name: 'Limited Prints',
            createdAt: DateTime.now(),
          ),
        ];
        await prefs.setString(
          _webFoldersKey,
          jsonEncode(initial.map((f) => f.toMap()).toList()),
        );
        return initial;
      }
      final List decoded = jsonDecode(str);
      return decoded.map((m) => CollectionFolder.fromMap(m)).toList();
    }
    final db = await database;
    final maps = await db.query(
      'collection_folders',
      orderBy: 'sortOrder ASC, name ASC',
    );
    return maps.map((m) => CollectionFolder.fromMap(m)).toList();
  }

  Future<void> insertFolder(CollectionFolder folder) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = await getAllFolders();
      list.removeWhere((f) => f.id == folder.id);
      list.add(folder);
      await prefs.setString(
        _webFoldersKey,
        jsonEncode(list.map((f) => f.toMap()).toList()),
      );
      return;
    }
    final db = await database;
    await db.insert(
      'collection_folders',
      folder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateFolder(CollectionFolder folder) async {
    await insertFolder(folder);
  }

  Future<void> deleteFolder(String id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = await getAllFolders();
      list.removeWhere((f) => f.id == id);
      await prefs.setString(
        _webFoldersKey,
        jsonEncode(list.map((f) => f.toMap()).toList()),
      );
      return;
    }
    final db = await database;
    await db.delete('collection_folders', where: 'id = ?', whereArgs: [id]);
  }

  // Wishlist CRUD
  Future<List<WishlistItem>> getAllWishlistItems() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_webWishlistKey);
      if (str == null || str.isEmpty) return [];
      final List decoded = jsonDecode(str);
      return decoded.map((m) => WishlistItem.fromMap(m)).toList();
    }
    final db = await database;
    final maps = await db.query(
      'wishlist_items',
      orderBy: 'priority ASC, createdAt DESC',
    );
    return maps.map((m) => WishlistItem.fromMap(m)).toList();
  }

  Future<void> insertWishlistItem(WishlistItem item) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = await getAllWishlistItems();
      list.removeWhere((w) => w.id == item.id);
      list.insert(0, item);
      await prefs.setString(
        _webWishlistKey,
        jsonEncode(list.map((w) => w.toMap()).toList()),
      );
      return;
    }
    final db = await database;
    await db.insert(
      'wishlist_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateWishlistItem(WishlistItem item) async {
    await insertWishlistItem(item);
  }

  Future<void> deleteWishlistItem(String id) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final list = await getAllWishlistItems();
      list.removeWhere((w) => w.id == id);
      await prefs.setString(
        _webWishlistKey,
        jsonEncode(list.map((w) => w.toMap()).toList()),
      );
      return;
    }
    final db = await database;
    await db.delete('wishlist_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllData() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_webArtworksKey);
      await prefs.remove(_webFoldersKey);
      await prefs.remove(_webWishlistKey);
      return;
    }
    final db = await database;
    await db.delete('artworks');
    await db.delete('collection_folders');
    await db.delete('wishlist_items');
  }
}
