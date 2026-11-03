import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/safe_image_widget.dart';
import '../../data/models/artwork.dart';
import '../../data/providers.dart';
import '../artwork_edit/artwork_edit_screen.dart';

class ArtworkDetailScreen extends ConsumerWidget {
  final String artworkId;
  const ArtworkDetailScreen({super.key, required this.artworkId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final artworksAsync = ref.watch(artworksProvider);

    return artworksAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CupertinoActivityIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (artworks) {
        final matches = artworks.where((a) => a.id == artworkId);
        if (matches.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Collectible piece not found')),
          );
        }
        final art = matches.first;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: GestureDetector(
                    onTap: () {
                      if (art.coverPhotoPath != null) {
                        _showFullScreenImage(context, art.coverPhotoPath!);
                      }
                    },
                    child: SafeImageWidget(
                      path: art.coverPhotoPath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      art.isFavorite
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: art.isFavorite ? Colors.redAccent : Colors.white,
                    ),
                    onPressed: () => ref
                        .read(artworksProvider.notifier)
                        .toggleFavorite(art.id),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.share),
                    onPressed: () => _shareArtwork(art),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.pencil),
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) =>
                              ArtworkEditScreen(initialArtwork: art),
                        ),
                      );
                    },
                  ),
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'delete') {
                        _confirmDelete(context, ref, art.id);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.delete,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Delete Piece',
                              style: TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Maker
                      Text(
                        art.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        art.artist ?? 'Maker Unknown',
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Highlight Badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (art.yearCreated != null)
                            _buildBadge(
                              CupertinoIcons.calendar,
                              '${art.yearCreated}',
                              isDark,
                            ),
                          if (art.medium != null)
                            _buildBadge(
                              CupertinoIcons.paintbrush,
                              art.medium!,
                              isDark,
                            ),
                          if (art.condition != null)
                            _buildBadge(
                              CupertinoIcons.checkmark_seal,
                              art.condition!,
                              isDark,
                            ),
                          if (art.location != null)
                            _buildBadge(
                              CupertinoIcons.location,
                              art.location!,
                              isDark,
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Financial / Valuation Card
                      _buildValuationCard(art, isDark),
                      const SizedBox(height: 24),

                      // Gallery Grid if multiple photos
                      if (art.photoPaths.length > 1) ...[
                        const Text(
                          'Photographs',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 96,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: art.photoPaths.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, idx) {
                              final p = art.photoPaths[idx];
                              return GestureDetector(
                                onTap: () => _showFullScreenImage(context, p),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SafeImageWidget(
                                    path: p,
                                    width: 96,
                                    height: 96,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Dimensions Section
                      if (art.widthCm != null ||
                          art.heightCm != null ||
                          art.depthCm != null ||
                          art.weightKg != null) ...[
                        _buildSectionHeader('Physical Dimensions'),
                        _buildDetailRow(
                          'Dimensions (W × H × D)',
                          '${art.widthCm ?? '-'} × ${art.heightCm ?? '-'} × ${art.depthCm ?? '-'} cm',
                          isDark,
                        ),
                        if (art.weightKg != null)
                          _buildDetailRow(
                            'Weight',
                            '${art.weightKg} kg',
                            isDark,
                          ),
                        const SizedBox(height: 20),
                      ],

                      // Provenance & Notes
                      if (art.provenance != null &&
                          art.provenance!.isNotEmpty) ...[
                        _buildSectionHeader('Provenance & History'),
                        Text(
                          art.provenance!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                      ],

                      if (art.notes != null && art.notes!.isNotEmpty) ...[
                        _buildSectionHeader('Curator Notes'),
                        Text(
                          art.notes!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                      ],
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildValuationCard(Artwork art, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ESTIMATED VALUE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accentWarm,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                art.estimatedValue != null
                    ? '\$${art.estimatedValue!.toStringAsFixed(0)}'
                    : 'Not set',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 36,
            color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PURCHASE PRICE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                art.purchasePrice != null
                    ? '\$${art.purchasePrice!.toStringAsFixed(0)}'
                    : 'Not recorded',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.accentWarm),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppTheme.accentWarm,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String path) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              child: SafeImageWidget(path: path, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareArtwork(Artwork art) async {
    final text =
        'Piece: ${art.title}\nArtist: ${art.artist ?? "Unknown"}\nMedium: ${art.medium ?? "N/A"}\nHandCraft Collectibles Vault';
    if (!kIsWeb && art.coverPhotoPath != null) {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(art.coverPhotoPath!)],
          subject: art.title,
          text: text,
        ),
      );
    } else {
      await SharePlus.instance.share(
        ShareParams(text: text, subject: art.title),
      );
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Collectible Piece'),
        content: const Text(
          'Are you sure you want to permanently remove this piece and its photos from your vault?',
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(artworksProvider.notifier).deleteArtwork(id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
