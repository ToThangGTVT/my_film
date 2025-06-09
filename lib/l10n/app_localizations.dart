import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello world!'**
  String get helloWorld;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @changeTheme.
  ///
  /// In en, this message translates to:
  /// **'Change theme'**
  String get changeTheme;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'Ok'**
  String get ok;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @noNetworkConnection.
  ///
  /// In en, this message translates to:
  /// **'No network connection!'**
  String get noNetworkConnection;

  /// No description provided for @networkConnectionRestored.
  ///
  /// In en, this message translates to:
  /// **'Network connection restored!'**
  String get networkConnectionRestored;

  /// No description provided for @setting.
  ///
  /// In en, this message translates to:
  /// **'Setting'**
  String get setting;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @movieUpdate.
  ///
  /// In en, this message translates to:
  /// **'Movie is being updated...'**
  String get movieUpdate;

  /// No description provided for @film.
  ///
  /// In en, this message translates to:
  /// **'Film: '**
  String get film;

  /// No description provided for @actor.
  ///
  /// In en, this message translates to:
  /// **'Actor: '**
  String get actor;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category: '**
  String get category;

  /// No description provided for @episode.
  ///
  /// In en, this message translates to:
  /// **'Episode: '**
  String get episode;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content: '**
  String get content;

  /// No description provided for @singleMovie.
  ///
  /// In en, this message translates to:
  /// **'Single Movie'**
  String get singleMovie;

  /// No description provided for @seriesMovie.
  ///
  /// In en, this message translates to:
  /// **'Series Movie'**
  String get seriesMovie;

  /// No description provided for @cartoon.
  ///
  /// In en, this message translates to:
  /// **'Cartoon'**
  String get cartoon;

  /// No description provided for @pressTheButtonToExit.
  ///
  /// In en, this message translates to:
  /// **'Press the ∨ button to exit'**
  String get pressTheButtonToExit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @featureUnderDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Feature under development !'**
  String get featureUnderDevelopment;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @hideLess.
  ///
  /// In en, this message translates to:
  /// **'Hide less'**
  String get hideLess;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @movieNotFound.
  ///
  /// In en, this message translates to:
  /// **'Movie not found !'**
  String get movieNotFound;

  /// No description provided for @movieListIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Movie list is empty !'**
  String get movieListIsEmpty;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @emptyList.
  ///
  /// In en, this message translates to:
  /// **'empty list !'**
  String get emptyList;

  /// No description provided for @favoriteFilm.
  ///
  /// In en, this message translates to:
  /// **'Favorite film'**
  String get favoriteFilm;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @allowAppsToAccessNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow apps to access notifications?'**
  String get allowAppsToAccessNotifications;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View history'**
  String get viewHistory;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get selectLanguage;

  /// No description provided for @viewHistoryIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'View history is empty !'**
  String get viewHistoryIsEmpty;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @areYouSureYouWantToClearTheCache.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear the cache?'**
  String get areYouSureYouWantToClearTheCache;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
