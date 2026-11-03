import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers.dart';
import '../../data/services/biometric_service.dart';
import '../../data/services/database_service.dart';
import '../../data/services/export_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _appLock = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final lock = await BiometricService.instance.isAppLockEnabled();
    setState(() => _appLock = lock);
  }

  Future<void> _toggleAppLock(bool val) async {
    if (val) {
      final success = await BiometricService.instance.authenticate(
        reason: 'Confirm Face ID or Passcode to secure HandCraft Collectibles',
      );
      if (success) {
        await BiometricService.instance.setAppLockEnabled(true);
        setState(() => _appLock = true);
      }
    } else {
      await BiometricService.instance.setAppLockEnabled(false);
      setState(() => _appLock = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Appearance Segment
          _buildSectionHeader('Appearance'),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
            ),
            child: Row(
              children: [
                _buildThemeOption(
                  icon: CupertinoIcons.sun_max_fill,
                  label: 'Light',
                  selected: currentThemeMode == ThemeMode.light,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.light),
                ),
                _buildThemeOption(
                  icon: CupertinoIcons.moon_stars_fill,
                  label: 'Dark',
                  selected: currentThemeMode == ThemeMode.dark,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.dark),
                ),
                _buildThemeOption(
                  icon: CupertinoIcons.device_phone_portrait,
                  label: 'System',
                  selected: currentThemeMode == ThemeMode.system,
                  onTap: () => ref
                      .read(themeModeProvider.notifier)
                      .setTheme(ThemeMode.system),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Security & Vault
          _buildSectionHeader('Security & Privacy'),
          _buildContainerCard(
            isDark: isDark,
            children: [
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                title: const Text(
                  'App Biometric Lock',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: const Text(
                  'Require Face ID / Touch ID when opening vault',
                  style: TextStyle(fontSize: 13),
                ),
                value: _appLock,
                activeThumbColor: AppTheme.accentWarm,
                onChanged: _toggleAppLock,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Data Management
          _buildSectionHeader('Collection Backups'),
          _buildContainerCard(
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(CupertinoIcons.archivebox, size: 22),
                title: const Text(
                  'Export Collection Archive (ZIP)',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                subtitle: const Text(
                  'Includes catalog JSON and photos',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
                onTap: () => ExportService.instance.exportZipArchive(),
              ),
              Divider(
                height: 1,
                indent: 56,
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.table, size: 22),
                title: const Text(
                  'Export Collection to CSV',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                subtitle: const Text(
                  'Spreadsheet format of all items and valuations',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: const Icon(CupertinoIcons.chevron_right, size: 16),
                onTap: () => ExportService.instance.exportCsv(),
              ),
              Divider(
                height: 1,
                indent: 56,
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
              ListTile(
                leading: const Icon(
                  CupertinoIcons.trash,
                  color: Colors.redAccent,
                  size: 22,
                ),
                title: const Text(
                  'Clear All Vault Data',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                trailing: const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: Colors.redAccent,
                ),
                onTap: () => _confirmClearData(context),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
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

  Widget _buildThemeOption({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? const Color(0xFF233042) : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.2 : 0.05,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? AppTheme.accentWarm
                    : (isDark ? Colors.grey.shade500 : Colors.grey.shade600),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected
                      ? (isDark ? Colors.white : AppTheme.lightTextPrimary)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContainerCard({
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
        ),
      ),
      child: Column(children: children),
    );
  }

  void _confirmClearData(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Clear All Vault Data?'),
        content: const Text(
          'Are you sure you want to permanently erase all artworks, folders, and wishlist entries? This cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Clear All'),
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseService.instance.clearAllData();
              ref.read(artworksProvider.notifier).loadArtworks();
              ref.read(foldersProvider.notifier).loadFolders();
              ref.read(wishlistProvider.notifier).loadItems();
              final currentContext = context;
              if (currentContext.mounted) {
                ScaffoldMessenger.of(currentContext).showSnackBar(
                  const SnackBar(content: Text('Vault data erased.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
