import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/artwork.dart';
import '../../data/models/collection_folder.dart';
import '../../data/models/wishlist_item.dart';
import '../../data/services/database_service.dart';

// Theme Mode Provider (Light, Dark, System)
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const String _themePrefKey = 'user_selected_theme_mode';

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_themePrefKey);
    if (modeStr == 'light') {
      state = ThemeMode.light;
    } else if (modeStr == 'dark') {
      state = ThemeMode.dark;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    if (mode == ThemeMode.light) {
      await prefs.setString(_themePrefKey, 'light');
    } else if (mode == ThemeMode.dark) {
      await prefs.setString(_themePrefKey, 'dark');
    } else {
      await prefs.setString(_themePrefKey, 'system');
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

// Artworks State Notifier
class ArtworksNotifier extends StateNotifier<AsyncValue<List<Artwork>>> {
  ArtworksNotifier() : super(const AsyncValue.loading()) {
    loadArtworks();
  }

  Future<void> loadArtworks() async {
    try {
      final list = await DatabaseService.instance.getAllArtworks();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveArtwork(Artwork artwork) async {
    final existing = state.value?.any((a) => a.id == artwork.id) ?? false;
    if (existing) {
      await DatabaseService.instance.updateArtwork(artwork);
    } else {
      await DatabaseService.instance.insertArtwork(artwork);
    }
    await loadArtworks();
  }

  Future<void> deleteArtwork(String id) async {
    await DatabaseService.instance.deleteArtwork(id);
    await loadArtworks();
  }

  Future<void> toggleFavorite(String id) async {
    final list = state.value;
    if (list == null) return;
    final item = list.firstWhere((a) => a.id == id);
    final updated = item.copyWith(
      isFavorite: !item.isFavorite,
      updatedAt: DateTime.now(),
    );
    await DatabaseService.instance.updateArtwork(updated);
    await loadArtworks();
  }
}

final artworksProvider =
    StateNotifierProvider<ArtworksNotifier, AsyncValue<List<Artwork>>>(
      (ref) => ArtworksNotifier(),
    );

// Collections / Folders Notifier
class FoldersNotifier
    extends StateNotifier<AsyncValue<List<CollectionFolder>>> {
  FoldersNotifier() : super(const AsyncValue.loading()) {
    loadFolders();
  }

  Future<void> loadFolders() async {
    try {
      final list = await DatabaseService.instance.getAllFolders();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addFolder(CollectionFolder folder) async {
    await DatabaseService.instance.insertFolder(folder);
    await loadFolders();
  }

  Future<void> deleteFolder(String id) async {
    await DatabaseService.instance.deleteFolder(id);
    await loadFolders();
  }
}

final foldersProvider =
    StateNotifierProvider<FoldersNotifier, AsyncValue<List<CollectionFolder>>>(
      (ref) => FoldersNotifier(),
    );

// Wishlist Notifier
class WishlistNotifier extends StateNotifier<AsyncValue<List<WishlistItem>>> {
  WishlistNotifier() : super(const AsyncValue.loading()) {
    loadItems();
  }

  Future<void> loadItems() async {
    try {
      final list = await DatabaseService.instance.getAllWishlistItems();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> saveItem(WishlistItem item) async {
    final existing = state.value?.any((w) => w.id == item.id) ?? false;
    if (existing) {
      await DatabaseService.instance.updateWishlistItem(item);
    } else {
      await DatabaseService.instance.insertWishlistItem(item);
    }
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await DatabaseService.instance.deleteWishlistItem(id);
    await loadItems();
  }
}

final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, AsyncValue<List<WishlistItem>>>(
      (ref) => WishlistNotifier(),
    );

// Search & Filter State
enum ArtworkViewMode { grid, list }

enum SortOption { dateAddedDesc, dateAddedAsc, titleAsc, valueDesc, yearDesc }

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedFolderFilterProvider = StateProvider<String?>((ref) => null);
final favoritesOnlyFilterProvider = StateProvider<bool>((ref) => false);
final sortOptionProvider = StateProvider<SortOption>(
  (ref) => SortOption.dateAddedDesc,
);
final viewModeProvider = StateProvider<ArtworkViewMode>(
  (ref) => ArtworkViewMode.grid,
);
