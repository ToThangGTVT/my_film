import 'package:app/feature/favorite/favorite_movie_page.dart';
import 'package:app/feature/home/home_page.dart';
import 'package:app/feature/setting/setting_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyHomeApp extends StatefulWidget {
  const MyHomeApp({super.key});

  @override
  State<MyHomeApp> createState() => _MyHomeAppState();
}

class _MyHomeAppState extends State<MyHomeApp> {
  int pageIndex = 0;
  List<Widget> pages = [
    const HomePage(),
    // const SearchPage(),
    const FavoriteMoviePage(),
    const SettingsPage()
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = AppLocalizations.of(context);
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: pages[pageIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: theme.colorScheme.primary,
          type: BottomNavigationBarType.fixed,
          currentIndex: pageIndex,
          unselectedIconTheme: IconThemeData(color: theme.colorScheme.tertiary),
          showUnselectedLabels: true,
          showSelectedLabels: true,
          unselectedItemColor: theme.colorScheme.tertiary,
          selectedItemColor: theme.colorScheme.onPrimary,
          onTap: (value) {
            setState(() {
              pageIndex = value;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, color: theme.colorScheme.tertiary),
              label: app?.home,
              activeIcon: Icon(Icons.home_outlined, color: theme.colorScheme.onPrimary),
            ),
            // BottomNavigationBarItem(
            //   icon: SvgPicture.asset(
            //     'assets/icons/search.svg',
            //     color: theme.colorScheme.tertiary,
            //   ),
            //   label: app?.search,
            //   activeIcon: SvgPicture.asset(
            //     'assets/icons/search.svg',
            //     color: theme.colorScheme.onPrimary,
            //   ),
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border, color: theme.colorScheme.tertiary),
              label: app?.favorite,
              activeIcon: Icon(Icons.favorite_border, color: theme.colorScheme.onPrimary),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, color: theme.colorScheme.tertiary),
              label: app?.setting,
              activeIcon: Icon(Icons.settings_outlined, color: theme.colorScheme.tertiary),
            ),
          ],
        ),
      ),
    );
  }
}
