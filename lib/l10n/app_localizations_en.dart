// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Main';

  @override
  String get search => 'Search';

  @override
  String get collection => 'Collection';

  @override
  String get settings => 'Settings';

  @override
  String get searchNoResults => 'Nothing found for query';

  @override
  String get readMore => 'read more';

  @override
  String get readLess => 'hide';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get watchButton => 'Watch';

  @override
  String get readButton => 'Read';

  @override
  String get episodesList => 'Episodes';

  @override
  String get mangaChapter => 'Chapters';

  @override
  String get status => 'Status';

  @override
  String get language => 'Language';

  @override
  String get contentLanguage => 'Content language';

  @override
  String get mediaType => 'Media type';

  @override
  String get mediaTypeVideo => 'Video';

  @override
  String get mediaTypeManga => 'Manga';

  @override
  String get statusLabelWatchingNow => 'Watch now';

  @override
  String get statusLabelComplete => 'Complete';

  @override
  String get statusLabelLatter => 'Watch later';

  @override
  String get statusLabelOnHold => 'On Hold';

  @override
  String get statusLabelPutOnHold => 'Put on Hold';

  @override
  String get addToCollection => 'Add to Collection';

  @override
  String get removeFromCollection => 'Remove from Collection';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priorityHight => 'Hight';

  @override
  String priorityTooltip(Object priority) {
    return 'Priority: $priority';
  }

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'Auto';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsColor => 'Color';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsSuppliersVersion => 'Suppliers version';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sing Out';

  @override
  String get collectionSync => 'Sync Collection';

  @override
  String get collectionSyncDone => 'Collection sync done';

  @override
  String get install => 'Install';

  @override
  String get collectionContinue => 'Continue watch';

  @override
  String get collectionBegin => 'Begin watch';

  @override
  String get contentType => 'Content type';

  @override
  String get contentTypeMovie => 'Movie';

  @override
  String get contentTypeAnime => 'Anime';

  @override
  String get contentTypeSeries => 'TV Shows';

  @override
  String get contentTypeCartoon => 'Cartoons';

  @override
  String get contentTypeManga => 'Manga';

  @override
  String get useSearchHint => 'Collections is empty\nTry to search something';

  @override
  String get setRecommendationsHint => 'Setup Recommendations';

  @override
  String get videoSourceFailed => 'Video playback error';

  @override
  String get videoNoSources => 'No available video source';

  @override
  String get videoSubtitlesOff => 'Subtitles off';

  @override
  String get videoSubtitlesOffset => 'Subtitles offset';

  @override
  String get videoPlayerSettingShuffleMode => 'Shuffle playlist mode';

  @override
  String get videoPlayerSettingEndsAction => 'On video ends';

  @override
  String get videoPlayerEndsActionPlayNextLabel => 'Play next';

  @override
  String get videoPlayerEndsActionPlayAgainLabel => 'Repeat';

  @override
  String get videoPlayerEndsActionDoNothingLabel => 'Stop playing';

  @override
  String get videoPlayerSettingStartFrom => 'Start from';

  @override
  String get videoPlayerSettingStartFromBeginning => 'Beginning';

  @override
  String get videoPlayerSettingStartFromRemembered => 'Remembered time';

  @override
  String get videoPlayerSettingStartFromFixed => 'Fixed second';

  @override
  String get videoPlayerBtnHintServers => 'Servers';

  @override
  String get videoPlayerBtnHintTracks => 'Videos and audio tracks';

  @override
  String get videoPlayerAudioTracks => 'Audio tracks';

  @override
  String get videoPlayerVideoTracks => 'Video tracks';

  @override
  String get videoSubtitlesLoading => 'Loading subtitles...';

  @override
  String get videoSubtitlesLoadingError => 'Unable to load subtitles';

  @override
  String get settingsUnableDownloadNewVersion =>
      'Failed to download new version';

  @override
  String get settingsCheckForUpdate => 'Check for update';

  @override
  String settingsDownloadUpdate(Object update) {
    return 'Download ver. $update';
  }

  @override
  String get settingsSuppliersAndRecommendations =>
      'Suppliers and  Recommendations';

  @override
  String get mangaUnableToLoadPage => 'Unable to view page';

  @override
  String get mangaPageLoading => 'Page loading';

  @override
  String get mangaTranslation => 'Translation';

  @override
  String get mangaReaderBackground => 'Background';

  @override
  String get mangaReaderBackgroundLight => 'Light';

  @override
  String get mangaReaderBackgroundDark => 'Dark';

  @override
  String get mangaReaderMode => 'Mode';

  @override
  String get mangaReaderModeVertical => 'Vertical';

  @override
  String get mangaReaderModeLeftToRight => 'Left to right';

  @override
  String get mangaReaderModeRightToLeft => 'Right to left';

  @override
  String get mangaReaderModeLongStrip => 'Long strip';

  @override
  String get mangaReaderPageDownloadFailed => 'Page download failed';

  @override
  String get mangaReaderAutoCrop => 'Auto crop';

  @override
  String get mangaNextItem => 'Next';

  @override
  String get mangaPrevItem => 'Prev';

  @override
  String get errorGoBack => 'Go back';

  @override
  String get errorReload => 'Reload';

  @override
  String get ffiLibNotInstalled => 'Content suppliers module not installed';

  @override
  String get ffiLibInstalled => 'Content suppliers installed';

  @override
  String get ffiLibInstallationFailed =>
      'Content suppliers module installation failed';

  @override
  String get appUpdateFailed => 'Application update failed';

  @override
  String get downloads => 'Downloads';

  @override
  String downloadsDeleteConfimation(Object title) {
    return 'Delete all stored data for: $title?';
  }

  @override
  String downloadsFailed(Object title) {
    return 'Download failed: $title';
  }

  @override
  String get confirmeDialogCancel => 'Cancel';

  @override
  String get confirmeDialogAccept => 'Accept';

  @override
  String get loadMore => 'Load More';

  @override
  String get searchMore => 'Search more';

  @override
  String get offlineMode => 'Offline Mode';

  @override
  String get connectTV => 'Connect TV with code';

  @override
  String connectTVValue(Object code) {
    return 'Connect code: $code';
  }

  @override
  String get connectTVAuth => 'Authenticate with code';

  @override
  String get connectTVInvalidCode => 'Invalid code';

  @override
  String get equalizerTitle => 'Equalizer';

  @override
  String get equalizerPresetClearDialogue => 'Clear Dialogue';

  @override
  String get equalizerPresetCinema => 'Cinema';

  @override
  String get equalizerPresetNightMode => 'Night Mode';

  @override
  String get equalizerPresetAction => 'Action';

  @override
  String get equalizerPresetReset => 'Reset';

  @override
  String get equalizerPresetMax => 'Max';

  @override
  String get equalizerBandBass => 'Bass';

  @override
  String get equalizerBandLowMid => 'Low Mid';

  @override
  String get equalizerBandMid => 'Mid';

  @override
  String get equalizerBandHighMid => 'High Mid';

  @override
  String get equalizerBandTreble => 'Treble';
}
