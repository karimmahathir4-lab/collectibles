import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/safe_image_widget.dart';
import '../../data/models/artwork.dart';
import '../../data/providers.dart';
import '../artwork_detail/artwork_detail_screen.dart';
import '../artwork_edit/artwork_edit_screen.dart';

class CollectionHomeScreen extends ConsumerWidget {
  const CollectionHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final artworksAsync = ref.watch(artworksProvider);
    final viewMode = ref.watch(viewModeProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedFolder = ref.watch(selectedFolderFilterProvider);
    final favoritesOnly = ref.watch(favoritesOnlyFilterProvider);
    final sortOption = ref.watch(sortOptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Collection'),
        actions: [
          // View Mode Switcher
          IconButton(
            icon: Icon(
              viewMode == ArtworkViewMode.grid
                  ? CupertinoIcons.list_bullet
                  : CupertinoIcons.square_grid_2x2,
              size: 20,
            ),
            onPressed: () {
              ref
                  .read(viewModeProvider.notifier)
                  .state = viewMode == ArtworkViewMode.grid
                  ? ArtworkViewMode.list
                  : ArtworkViewMode.grid;
            },
          ),
          // Filter & Sort
          IconButton(
            icon: const Icon(CupertinoIcons.slider_horizontal_3, size: 20),
            onPressed: () => _showFilterSheet(context, ref, isDark),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const ArtworkEditScreen()),
          );
        },
        backgroundColor: AppTheme.accentWarm,
        foregroundColor: Colors.white,
        elevation: 3,
        icon: const Icon(CupertinoIcons.plus, size: 18),
        label: const Text(
          'Add Piece',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
        ),
      ),
      body: artworksAsync.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (artworks) {
          // Filtering
          var filtered = artworks.where((a) {
            if (favoritesOnly && !a.isFavorite) return false;
            if (selectedFolder != null &&
                !a.collectionIds.contains(selectedFolder)) {
              return false;
            }
            if (searchQuery.isNotEmpty) {
              final q = searchQuery.toLowerCase();
              final matchTitle = a.title.toLowerCase().contains(q);
              final matchArtist = a.artist?.toLowerCase().contains(q) ?? false;
              final matchMedium = a.medium?.toLowerCase().contains(q) ?? false;
              final matchLoc = a.location?.toLowerCase().contains(q) ?? false;
              if (!matchTitle && !matchArtist && !matchMedium && !matchLoc) {
                return false;
              }
            }
            return true;
          }).toList();

          // Sorting
          switch (sortOption) {
            case SortOption.dateAddedDesc:
              filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              break;
            case SortOption.dateAddedAsc:
              filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
              break;
            case SortOption.titleAsc:
              filtered.sort((a, b) => a.title.compareTo(b.title));
              break;
            case SortOption.valueDesc:
              filtered.sort(
                (a, b) =>
                    (b.estimatedValue ?? 0).compareTo(a.estimatedValue ?? 0),
              );
              break;
            case SortOption.yearDesc:
              filtered.sort(
                (a, b) => (b.yearCreated ?? 0).compareTo(a.yearCreated ?? 0),
              );
              break;
          }

          return Column(
            children: [
              // Search Header with clean rounded field
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: TextField(
                  onChanged: (val) =>
                      ref.read(searchQueryProvider.notifier).state = val,
                  decoration: InputDecoration(
                    hintText: 'Search title, maker, medium...',
                    prefixIcon: const Icon(CupertinoIcons.search, size: 18),
                    suffixIcon: searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () =>
                                ref.read(searchQueryProvider.notifier).state =
                                    '',
                            child: const Icon(
                              CupertinoIcons.clear_circled,
                              size: 18,
                            ),
                          )
                        : null,
                  ),
                ),
              ),

              // Filter Tag Pill Row
              if (selectedFolder != null || favoritesOnly)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      if (favoritesOnly)
                        Chip(
                          avatar: const Icon(
                            CupertinoIcons.heart_fill,
                            size: 13,
                            color: Colors.redAccent,
                          ),
                          label: const Text('Favorites'),
                          onDeleted: () =>
                              ref
                                      .read(
                                        favoritesOnlyFilterProvider.notifier,
                                      )
                                      .state =
                                  false,
                        ),
                      if (selectedFolder != null) ...[
                        const SizedBox(width: 8),
                        Chip(
                          avatar: const Icon(
                            CupertinoIcons.folder_fill,
                            size: 13,
                          ),
                          label: Text(selectedFolder),
                          onDeleted: () =>
                              ref
                                      .read(
                                        selectedFolderFilterProvider.notifier,
                                      )
                                      .state =
                                  null,
                        ),
                      ],
                    ],
                  ),
                ),

              // Vault Gallery / List
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState(context, artworks.isEmpty, isDark)
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: viewMode == ArtworkViewMode.grid
                            ? _buildGridView(context, ref, filtered, isDark)
                            : _buildListView(context, ref, filtered, isDark),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool isCompletelyEmpty,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                ),
              ),
              child: const Icon(
                CupertinoIcons.photo_on_rectangle,
                size: 36,
                color: AppTheme.accentWarm,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isCompletelyEmpty ? 'Vault is Empty' : 'No Results Found',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              isCompletelyEmpty
                  ? 'Tap "+ Add Piece" below to photograph and document your first collectible.'
                  : 'Try clearing your search query or removing active filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView(
    BuildContext context,
    WidgetRef ref,
    List<Artwork> artworks,
    bool isDark,
  ) {
    final width = MediaQuery.of(context).size.width;
    final crossAxisCount = width > 900 ? 4 : (width > 600 ? 3 : 2);

    return GridView.builder(
      key: const ValueKey('grid_view'),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 90),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.74,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
      ),
      itemCount: artworks.length,
      itemBuilder: (context, index) {
        final art = artworks[index];
        return _buildCardItem(context, ref, art, isDark);
      },
    );
  }

  Widget _buildCardItem(
    BuildContext context,
    WidgetRef ref,
    Artwork art,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => ArtworkDetailScreen(artworkId: art.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Preview Container
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SafeImageWidget(path: art.coverPhotoPath),
                  // Favorite Pill
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => ref
                          .read(artworksProvider.notifier)
                          .toggleFavorite(art.id),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          art.isFavorite
                              ? CupertinoIcons.heart_fill
                              : CupertinoIcons.heart,
                          size: 14,
                          color: art.isFavorite
                              ? Colors.redAccent
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info block
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    art.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    art.artist ?? 'Unknown Maker',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                  if (art.estimatedValue != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '\$${art.estimatedValue!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppTheme.accentWarm,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(
    BuildContext context,
    WidgetRef ref,
    List<Artwork> artworks,
    bool isDark,
  ) {
    return ListView.separated(
      key: const ValueKey('list_view'),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 90),
      itemCount: artworks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final art = artworks[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => ArtworkDetailScreen(artworkId: art.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: SafeImageWidget(path: art.coverPhotoPath),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        art.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${art.artist ?? 'Unknown'} ${art.yearCreated != null ? '• ${art.yearCreated}' : ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (art.estimatedValue != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      '\$${art.estimatedValue!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentWarm,
                        fontSize: 14,
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    art.isFavorite
                        ? CupertinoIcons.heart_fill
                        : CupertinoIcons.heart,
                    color: art.isFavorite ? Colors.redAccent : Colors.grey,
                    size: 18,
                  ),
                  onPressed: () => ref
                      .read(artworksProvider.notifier)
                      .toggleFavorite(art.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final currentSort = ref.watch(sortOptionProvider);
        final currentFavOnly = ref.watch(favoritesOnlyFilterProvider);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Sort & Filter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: Colors.grey,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'SORT BY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentWarm,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Newest First'),
                      selected: currentSort == SortOption.dateAddedDesc,
                      onSelected: (_) =>
                          ref.read(sortOptionProvider.notifier).state =
                              SortOption.dateAddedDesc,
                    ),
                    ChoiceChip(
                      label: const Text('Title (A-Z)'),
                      selected: currentSort == SortOption.titleAsc,
                      onSelected: (_) =>
                          ref.read(sortOptionProvider.notifier).state =
                              SortOption.titleAsc,
                    ),
                    ChoiceChip(
                      label: const Text('Highest Value'),
                      selected: currentSort == SortOption.valueDesc,
                      onSelected: (_) =>
                          ref.read(sortOptionProvider.notifier).state =
                              SortOption.valueDesc,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'FILTER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentWarm,
                  ),
                ),
                const SizedBox(height: 8),
                FilterChip(
                  label: const Text('Favorites Only'),
                  selected: currentFavOnly,
                  onSelected: (val) =>
                      ref.read(favoritesOnlyFilterProvider.notifier).state =
                          val,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
