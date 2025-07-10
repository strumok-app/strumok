import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get home;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @collection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collection;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing found for query'**
  String get searchNoResults;

  /// No description provided for @readMore.
  ///
  /// In en, this message translates to:
  /// **'read more'**
  String get readMore;

  /// No description provided for @readLess.
  ///
  /// In en, this message translates to:
  /// **'hide'**
  String get readLess;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @recommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No description provided for @watchButton.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watchButton;

  /// No description provided for @readButton.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get readButton;

  /// No description provided for @episodesList.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get episodesList;

  /// No description provided for @mangaChapter.
  ///
  /// In en, this message translates to:
  /// **'Chapters'**
  String get mangaChapter;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @contentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Content language'**
  String get contentLanguage;

  /// No description provided for @mediaType.
  ///
  /// In en, this message translates to:
  /// **'Media type'**
  String get mediaType;

  /// No description provided for @mediaTypeVideo.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get mediaTypeVideo;

  /// No description provided for @mediaTypeManga.
  ///
  /// In en, this message translates to:
  /// **'Manga'**
  String get mediaTypeManga;

  /// No description provided for @statusLabelWatchingNow.
  ///
  /// In en, this message translates to:
  /// **'Watch now'**
  String get statusLabelWatchingNow;

  /// No description provided for @statusLabelComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get statusLabelComplete;

  /// No description provided for @statusLabelLatter.
  ///
  /// In en, this message translates to:
  /// **'Watch later'**
  String get statusLabelLatter;

  /// No description provided for @statusLabelOnHold.
  ///
  /// In en, this message translates to:
  /// **'On Hold'**
  String get statusLabelOnHold;

  /// No description provided for @statusLabelPutOnHold.
  ///
  /// In en, this message translates to:
  /// **'Put on Hold'**
  String get statusLabelPutOnHold;

  /// No description provided for @addToCollection.
  ///
  /// In en, this message translates to:
  /// **'Add to Collection'**
  String get addToCollection;

  /// No description provided for @removeFromCollection.
  ///
  /// In en, this message translates to:
  /// **'Remove from Collection'**
  String get removeFromCollection;

  /// No description provided for @priorityLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get priorityLow;

  /// No description provided for @priorityNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get priorityNormal;

  /// No description provided for @priorityHight.
  ///
  /// In en, this message translates to:
  /// **'Hight'**
  String get priorityHight;

  /// No description provided for @priorityTooltip.
  ///
  /// In en, this message translates to:
  /// **'Priority: {priority}'**
  String priorityTooltip(Object priority);

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get settingsColor;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsSuppliersVersion.
  ///
  /// In en, this message translates to:
  /// **'Suppliers version'**
  String get settingsSuppliersVersion;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sing Out'**
  String get signOut;

  /// No description provided for @collectionSync.
  ///
  /// In en, this message translates to:
  /// **'Sync Collection'**
  String get collectionSync;

  /// No description provided for @collectionSyncDone.
  ///
  /// In en, this message translates to:
  /// **'Collection sync done'**
  String get collectionSyncDone;

  /// No description provided for @install.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get install;

  /// No description provided for @collectionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue watch'**
  String get collectionContinue;

  /// No description provided for @collectionBegin.
  ///
  /// In en, this message translates to:
  /// **'Begin watch'**
  String get collectionBegin;

  /// No description provided for @contentType.
  ///
  /// In en, this message translates to:
  /// **'Content type'**
  String get contentType;

  /// No description provided for @contentTypeMovie.
  ///
  /// In en, this message translates to:
  /// **'Movie'**
  String get contentTypeMovie;

  /// No description provided for @contentTypeAnime.
  ///
  /// In en, this message translates to:
  /// **'Anime'**
  String get contentTypeAnime;

  /// No description provided for @contentTypeSeries.
  ///
  /// In en, this message translates to:
  /// **'TV Shows'**
  String get contentTypeSeries;

  /// No description provided for @contentTypeCartoon.
  ///
  /// In en, this message translates to:
  /// **'Cartoons'**
  String get contentTypeCartoon;

  /// No description provided for @contentTypeManga.
  ///
  /// In en, this message translates to:
  /// **'Manga'**
  String get contentTypeManga;

  /// No description provided for @useSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Collections is empty\nTry to search something'**
  String get useSearchHint;

  /// No description provided for @setRecommendationsHint.
  ///
  /// In en, this message translates to:
  /// **'Setup Recommendations'**
  String get setRecommendationsHint;

  /// No description provided for @videoSourceFailed.
  ///
  /// In en, this message translates to:
  /// **'Video playback error'**
  String get videoSourceFailed;

  /// No description provided for @videoNoSources.
  ///
  /// In en, this message translates to:
  /// **'No available video source'**
  String get videoNoSources;

  /// No description provided for @videoSubtitlesOff.
  ///
  /// In en, this message translates to:
  /// **'Subtitles off'**
  String get videoSubtitlesOff;

  /// No description provided for @videoSubtitlesOffset.
  ///
  /// In en, this message translates to:
  /// **'Subtitles offset'**
  String get videoSubtitlesOffset;

  /// No description provided for @videoPlayerSettingShuffleMode.
  ///
  /// In en, this message translates to:
  /// **'Shuffle playlist mode'**
  String get videoPlayerSettingShuffleMode;

  /// No description provided for @videoPlayerSettingEndsAction.
  ///
  /// In en, this message translates to:
  /// **'On video ends'**
  String get videoPlayerSettingEndsAction;

  /// No description provided for @videoPlayerEndsActionPlayNextLabel.
  ///
  /// In en, this message translates to:
  /// **'Play next'**
  String get videoPlayerEndsActionPlayNextLabel;

  /// No description provided for @videoPlayerEndsActionPlayAgainLabel.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get videoPlayerEndsActionPlayAgainLabel;

  /// No description provided for @videoPlayerEndsActionDoNothingLabel.
  ///
  /// In en, this message translates to:
  /// **'Stop playing'**
  String get videoPlayerEndsActionDoNothingLabel;

  /// No description provided for @videoPlayerSettingStarFrom.
  ///
  /// In en, this message translates to:
  /// **'Start from'**
  String get videoPlayerSettingStarFrom;

  /// No description provided for @videoPlayerSettingStarFromBeginning.
  ///
  /// In en, this message translates to:
  /// **'Beginning'**
  String get videoPlayerSettingStarFromBeginning;

  /// No description provided for @videoPlayerSettingStarFromRemembered.
  ///
  /// In en, this message translates to:
  /// **'Remembered time'**
  String get videoPlayerSettingStarFromRemembered;

  /// No description provided for @videoPlayerSettingStarFromFixed.
  ///
  /// In en, this message translates to:
  /// **'Fixed second'**
  String get videoPlayerSettingStarFromFixed;

  /// No description provided for @videoPlayerBtnHintServers.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get videoPlayerBtnHintServers;

  /// No description provided for @videoPlayerBtnHintTracks.
  ///
  /// In en, this message translates to:
  /// **'Videos and audio tracks'**
  String get videoPlayerBtnHintTracks;

  /// No description provided for @videoPlayerAudioTracks.
  ///
  /// In en, this message translates to:
  /// **'Audio tracks'**
  String get videoPlayerAudioTracks;

  /// No description provided for @videoPlayerVideoTracks.
  ///
  /// In en, this message translates to:
  /// **'Video tracks'**
  String get videoPlayerVideoTracks;

  /// No description provided for @settingsUnableDownloadNewVersion.
  ///
  /// In en, this message translates to:
  /// **'Failed to download new version'**
  String get settingsUnableDownloadNewVersion;

  /// No description provided for @settingsCheckForUpdate.
  ///
  /// In en, this message translates to:
  /// **'Check for update'**
  String get settingsCheckForUpdate;

  /// No description provided for @settingsDownloadUpdate.
  ///
  /// In en, this message translates to:
  /// **'Download ver. {update}'**
  String settingsDownloadUpdate(Object update);

  /// No description provided for @settingsSuppliersAndRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Suppliers and  Recommendations'**
  String get settingsSuppliersAndRecommendations;

  /// No description provided for @mangaUnableToLoadPage.
  ///
  /// In en, this message translates to:
  /// **'Unable to view page'**
  String get mangaUnableToLoadPage;

  /// No description provided for @mangaPageLoading.
  ///
  /// In en, this message translates to:
  /// **'Page loading'**
  String get mangaPageLoading;

  /// No description provided for @mangaReaderScale.
  ///
  /// In en, this message translates to:
  /// **'Scale mode'**
  String get mangaReaderScale;

  /// No description provided for @mangaReaderScaleFit.
  ///
  /// In en, this message translates to:
  /// **'Fit'**
  String get mangaReaderScaleFit;

  /// No description provided for @mangaReaderScaleFitWidth.
  ///
  /// In en, this message translates to:
  /// **'Fit width'**
  String get mangaReaderScaleFitWidth;

  /// No description provided for @mangaReaderScaleFitHeight.
  ///
  /// In en, this message translates to:
  /// **'Fit height'**
  String get mangaReaderScaleFitHeight;

  /// No description provided for @mangaTranslation.
  ///
  /// In en, this message translates to:
  /// **'Translation'**
  String get mangaTranslation;

  /// No description provided for @mangaReaderBackground.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get mangaReaderBackground;

  /// No description provided for @mangaReaderBackgroundLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get mangaReaderBackgroundLight;

  /// No description provided for @mangaReaderBackgroundDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get mangaReaderBackgroundDark;

  /// No description provided for @mangaReaderMode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mangaReaderMode;

  /// No description provided for @mangaReaderModeVertical.
  ///
  /// In en, this message translates to:
  /// **'Vertical'**
  String get mangaReaderModeVertical;

  /// No description provided for @mangaReaderModeLeftToRight.
  ///
  /// In en, this message translates to:
  /// **'Left to right'**
  String get mangaReaderModeLeftToRight;

  /// No description provided for @mangaReaderModeRightToLeft.
  ///
  /// In en, this message translates to:
  /// **'Right to left'**
  String get mangaReaderModeRightToLeft;

  /// No description provided for @mangaReaderModeVerticalScroll.
  ///
  /// In en, this message translates to:
  /// **'Vertical scroll'**
  String get mangaReaderModeVerticalScroll;

  /// No description provided for @mangaReaderModeHorizontalScroll.
  ///
  /// In en, this message translates to:
  /// **'Scroll from left to right'**
  String get mangaReaderModeHorizontalScroll;

  /// No description provided for @mangaReaderModeHorizontalRtlScroll.
  ///
  /// In en, this message translates to:
  /// **'Scroll from right to left'**
  String get mangaReaderModeHorizontalRtlScroll;

  /// No description provided for @errorGoBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get errorGoBack;

  /// No description provided for @errorReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get errorReload;

  /// No description provided for @ffiLibNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Content suppliers module not installed'**
  String get ffiLibNotInstalled;

  /// No description provided for @ffiLibInstalled.
  ///
  /// In en, this message translates to:
  /// **'Content suppliers installed'**
  String get ffiLibInstalled;

  /// No description provided for @ffiLibInstallationFailed.
  ///
  /// In en, this message translates to:
  /// **'Content suppliers module installation failed'**
  String get ffiLibInstallationFailed;

  /// No description provided for @appUpdateFailed.
  ///
  /// In en, this message translates to:
  /// **'Application update failed'**
  String get appUpdateFailed;

  /// No description provided for @downloads.
  ///
  /// In en, this message translates to:
  /// **'Downloads'**
  String get downloads;

  /// No description provided for @downloadsDeleteConfimation.
  ///
  /// In en, this message translates to:
  /// **'Delete all stored data for: {title}?'**
  String downloadsDeleteConfimation(Object title);

  /// No description provided for @downloadsFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {title}'**
  String downloadsFailed(Object title);

  /// No description provided for @confirmeDialogCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get confirmeDialogCancel;

  /// No description provided for @confirmeDialogAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get confirmeDialogAccept;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get loadMore;

  /// No description provided for @searchMore.
  ///
  /// In en, this message translates to:
  /// **'Search more'**
  String get searchMore;

  /// No description provided for @offlineMode.
  ///
  /// In en, this message translates to:
  /// **'Offline Mode'**
  String get offlineMode;

  /// No description provided for @connectTV.
  ///
  /// In en, this message translates to:
  /// **'Connect TV with code'**
  String get connectTV;

  /// No description provided for @connectTVValue.
  ///
  /// In en, this message translates to:
  /// **'Connect code: {code}'**
  String connectTVValue(Object code);

  /// No description provided for @connectTVAuth.
  ///
  /// In en, this message translates to:
  /// **'Authenticate with code'**
  String get connectTVAuth;

  /// No description provided for @connectTVInvalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get connectTVInvalidCode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
