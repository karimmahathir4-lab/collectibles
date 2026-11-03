import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'data/providers.dart';
import 'data/services/biometric_service.dart';
import 'features/collection/collection_home_screen.dart';
import 'features/collections/collections_folders_screen.dart';
import 'features/lock/lock_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/wishlist/wishlist_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: HandCollectApp()));
}

class HandCollectApp extends ConsumerStatefulWidget {
  const HandCollectApp({super.key});

  @override
  ConsumerState<HandCollectApp> createState() => _HandCollectAppState();
}

class _HandCollectAppState extends ConsumerState<HandCollectApp> {
  bool _isLoading = true;
  bool _showOnboarding = false;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _checkInitialState();
  }

  Future<void> _checkInitialState() async {
    final prefs = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool('onboarding_completed') ?? false;
    final lockEnabled = await BiometricService.instance.isAppLockEnabled();

    setState(() {
      _showOnboarding = !onboarded;
      _isLocked = lockEnabled;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'HandCraft Collectibles',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: currentThemeMode,
      home: _isLoading
          ? const Scaffold(body: Center(child: CupertinoActivityIndicator()))
          : _showOnboarding
          ? OnboardingScreen(
              onFinished: () => setState(() => _showOnboarding = false),
            )
          : _isLocked
          ? LockScreen(onUnlocked: () => setState(() => _isLocked = false))
          : const MainTabScaffold(),
    );
  }
}

class MainTabScaffold extends StatefulWidget {
  const MainTabScaffold({super.key});

  @override
  State<MainTabScaffold> createState() => _MainTabScaffoldState();
}

class _MainTabScaffoldState extends State<MainTabScaffold> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    CollectionHomeScreen(),
    CollectionsFoldersScreen(),
    WishlistScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: AppTheme.accentWarm.withValues(alpha: 0.15),
        backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
        elevation: 0,
        destinations: const [
          NavigationDestination(
            icon: Icon(CupertinoIcons.photo_on_rectangle, size: 22),
            selectedIcon: Icon(
              CupertinoIcons.photo_fill_on_rectangle_fill,
              color: AppTheme.accentWarm,
              size: 22,
            ),
            label: 'Collection',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.folder, size: 22),
            selectedIcon: Icon(
              CupertinoIcons.folder_fill,
              color: AppTheme.accentWarm,
              size: 22,
            ),
            label: 'Folders',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.bookmark, size: 22),
            selectedIcon: Icon(
              CupertinoIcons.bookmark_fill,
              color: AppTheme.accentWarm,
              size: 22,
            ),
            label: 'Wishlist',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.chart_pie, size: 22),
            selectedIcon: Icon(
              CupertinoIcons.chart_pie_fill,
              color: AppTheme.accentWarm,
              size: 22,
            ),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.settings, size: 22),
            selectedIcon: Icon(
              CupertinoIcons.settings_solid,
              color: AppTheme.accentWarm,
              size: 22,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
