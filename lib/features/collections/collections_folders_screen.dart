import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/collection_folder.dart';
import '../../data/providers.dart';

class CollectionsFoldersScreen extends ConsumerWidget {
  const CollectionsFoldersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final foldersAsync = ref.watch(foldersProvider);
    final artworksAsync = ref.watch(artworksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.folder_badge_plus, size: 22),
            onPressed: () => _showAddFolderDialog(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: foldersAsync.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (folders) {
          final artworks = artworksAsync.value ?? [];

          if (folders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.folder,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No Folders Yet',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Organize your collection by style or material',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: folders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final folder = folders[index];
              final count = artworks
                  .where((a) => a.collectionIds.contains(folder.id))
                  .length;

              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.accentWarm.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      CupertinoIcons.folder_fill,
                      color: AppTheme.accentWarm,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    folder.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    '$count pieces',
                    style: TextStyle(
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(
                    CupertinoIcons.chevron_right,
                    size: 16,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    ref.read(selectedFolderFilterProvider.notifier).state =
                        folder.id;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Filtered by "${folder.name}".')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddFolderDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('New Folder'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'e.g. Sculptures, Art Glass',
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Create'),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                final newFolder = CollectionFolder(
                  id: const Uuid().v4(),
                  name: controller.text.trim(),
                  createdAt: DateTime.now(),
                );
                ref.read(foldersProvider.notifier).addFolder(newFolder);
              }
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}
