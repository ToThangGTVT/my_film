import 'package:app/feature/favorite/favorite_movie_page.dart';
import 'package:app/feature/home/home_page.dart';
import 'package:app/feature/setting/setting_page.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';

class MyHomeApp extends StatefulWidget {
  const MyHomeApp({super.key});

  @override
  State<MyHomeApp> createState() => _MyHomeAppState();
}

class _MyHomeAppState extends State<MyHomeApp> {
  int pageIndex = 0;
  final List<Widget> pages = const [
    HomePage(),
    FavoriteMoviePage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = AppLocalizations.of(context);

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          child: KeyedSubtree(
            key: ValueKey<int>(pageIndex),
            child: pages[pageIndex],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: theme.colorScheme.primary,
          type: BottomNavigationBarType.fixed,
          currentIndex: pageIndex,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          selectedItemColor: theme.colorScheme.onPrimary,
          unselectedItemColor: theme.colorScheme.tertiary,
          selectedIconTheme: const IconThemeData(size: 26),
          unselectedIconTheme: const IconThemeData(size: 24),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 0.1,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11.5,
          ),
          onTap: (value) {
            setState(() {
              pageIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, color: theme.colorScheme.tertiary),
              activeIcon: Icon(Icons.home_rounded, color: theme.colorScheme.onPrimary),
              label: app?.home,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border, color: theme.colorScheme.tertiary),
              activeIcon: Icon(Icons.favorite_rounded, color: theme.colorScheme.onPrimary),
              label: app?.favorite,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, color: theme.colorScheme.tertiary),
              activeIcon: Icon(Icons.settings, color: theme.colorScheme.onPrimary),
              label: app?.setting,
            ),
          ],
        ),
      ),
    );
  }
}
