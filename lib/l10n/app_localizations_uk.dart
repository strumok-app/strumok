// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get home => 'Головна';

  @override
  String get search => 'Пошук';

  @override
  String get collection => 'Колекція';

  @override
  String get settings => 'Налаштунки';

  @override
  String get searchNoResults => 'Нічого не знайдено за запитом';

  @override
  String get readMore => 'читати більше';

  @override
  String get readLess => 'сховати';

  @override
  String get suppliers => 'Постачальники';

  @override
  String get recommendations => 'Рекомендації';

  @override
  String get watchButton => 'Дивитись';

  @override
  String get readButton => 'Читати';

  @override
  String get episodesList => 'Список епізодів';

  @override
  String get mangaChapter => 'Розділи';

  @override
  String get status => 'Статус';

  @override
  String get language => 'Мова';

  @override
  String get contentLanguage => 'Мова контенту';

  @override
  String get mediaType => 'Контент';

  @override
  String get mediaTypeVideo => 'Відео';

  @override
  String get mediaTypeManga => 'Манга';

  @override
  String get statusLabelWatchingNow => 'Дивлюсь зараз';

  @override
  String get statusLabelComplete => 'Завершено';

  @override
  String get statusLabelLatter => 'Подивлюсь потім';

  @override
  String get statusLabelOnHold => 'Відкладено';

  @override
  String get statusLabelPutOnHold => 'Відкласти';

  @override
  String get addToCollection => 'Додати в колекцію';

  @override
  String get removeFromCollection => 'Видалити з колекції';

  @override
  String get priorityLow => 'Низький';

  @override
  String get priorityNormal => 'Звичайний';

  @override
  String get priorityHight => 'Високий';

  @override
  String priorityTooltip(Object priority) {
    return 'Пріоритет: $priority';
  }

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeLight => 'Світла';

  @override
  String get settingsThemeSystem => 'Авто';

  @override
  String get settingsThemeDark => 'Темна';

  @override
  String get settingsColor => 'Колір';

  @override
  String get settingsVersion => 'Версія';

  @override
  String get settingsSuppliersVersion => 'Версія постачальників';

  @override
  String get signIn => 'Авторизуватись';

  @override
  String get signOut => 'Вийти';

  @override
  String get collectionSync => 'Оновити колекцію';

  @override
  String get collectionSyncDone => 'Колекція оновлена з серверу';

  @override
  String get install => 'Встановити';

  @override
  String get collectionContinue => 'Продовжити перегляд';

  @override
  String get collectionBegin => 'Почати перегляд';

  @override
  String get contentType => 'Тип контенту';

  @override
  String get contentTypeMovie => 'Фільми';

  @override
  String get contentTypeAnime => 'Аніме';

  @override
  String get contentTypeSeries => 'Серіали';

  @override
  String get contentTypeCartoon => 'Мультфільми';

  @override
  String get contentTypeManga => 'Манга';

  @override
  String get useSearchHint => 'Ваша колекція порожня\nСкористайтесь пошуком';

  @override
  String get setRecommendationsHint => 'Налаштувати списки рекомендацій';

  @override
  String get videoSourceFailed => 'Помилка відтворення відео';

  @override
  String get videoNoSources => 'Немає доступних джерел відео';

  @override
  String get videoSubtitlesOff => 'Без субтитрів';

  @override
  String get videoSubtitlesOffset => 'Змішення субтитрів';

  @override
  String get videoPlayerSettingShuffleMode => 'Випадковий порядок';

  @override
  String get videoPlayerSettingEndsAction => 'Дія по закінченню відео';

  @override
  String get videoPlayerEndsActionPlayNextLabel => 'Перейти до наступного';

  @override
  String get videoPlayerEndsActionPlayAgainLabel => 'Відтворити знову';

  @override
  String get videoPlayerEndsActionDoNothingLabel => 'Зупинити';

  @override
  String get videoPlayerSettingStarFrom => 'Починати відео з';

  @override
  String get videoPlayerSettingStarFromBeginning => 'Початку';

  @override
  String get videoPlayerSettingStarFromRemembered => 'Запам\'ятованого часу';

  @override
  String get videoPlayerSettingStarFromFixed => 'Фіксованої секунди';

  @override
  String get videoPlayerBtnHintServers => 'Сервери';

  @override
  String get videoPlayerBtnHintTracks => 'Відео та аудіо потоки';

  @override
  String get videoPlayerAudioTracks => 'Аудіо потоки';

  @override
  String get videoPlayerVideoTracks => 'Відео потоки';

  @override
  String get settingsUnableDownloadNewVersion =>
      'Не вдається завантажити нову версію';

  @override
  String get settingsCheckForUpdate => 'Перевірити оновлення';

  @override
  String settingsDownloadUpdate(Object update) {
    return 'Завантажити вер. $update';
  }

  @override
  String get settingsSuppliersAndRecommendations =>
      'Постачальники та Рекомендації';

  @override
  String get mangaUnableToLoadPage => 'Неможливо відобразити сторінку';

  @override
  String get mangaPageLoading => 'Завантаження сторінки';

  @override
  String get mangaReaderScale => 'Масштабування зображення';

  @override
  String get mangaReaderScaleFit => 'Умістити';

  @override
  String get mangaReaderScaleFitWidth => 'Розтягнути по ширині';

  @override
  String get mangaReaderScaleFitHeight => 'Розтягнути по висоті';

  @override
  String get mangaTranslation => 'Переклад';

  @override
  String get mangaReaderBackground => 'Фон';

  @override
  String get mangaReaderBackgroundLight => 'Світлий';

  @override
  String get mangaReaderBackgroundDark => 'Темний';

  @override
  String get mangaReaderMode => 'Режим';

  @override
  String get mangaReaderModeVertical => 'Вертикальний';

  @override
  String get mangaReaderModeLeftToRight => 'З ліва на право';

  @override
  String get mangaReaderModeRightToLeft => 'З права на ліво';

  @override
  String get mangaReaderModeVerticalScroll => 'Вертикальна прокрутка';

  @override
  String get mangaReaderModeHorizontalScroll => 'Прокрутка з ліва на право';

  @override
  String get mangaReaderModeHorizontalRtlScroll => 'Прокрутка з права на ліво';

  @override
  String get errorGoBack => 'Повернутись назад';

  @override
  String get errorReload => 'Повторити';

  @override
  String get ffiLibNotInstalled => 'Модуль постачальників не встановлений';

  @override
  String get ffiLibInstalled => 'Модуль постачальників встановлений';

  @override
  String get ffiLibInstallationFailed =>
      'Неможливо встановити модуль постачальників';

  @override
  String get appUpdateFailed => 'Неможливо встановити нову версію';

  @override
  String get downloads => 'Завантаження';

  @override
  String downloadsDeleteConfimation(Object title) {
    return 'Видалии усі заванатжені дані для: $title';
  }

  @override
  String downloadsFailed(Object title) {
    return 'Неможливо завантажити: $title';
  }

  @override
  String get confirmeDialogCancel => 'Відмінити';

  @override
  String get confirmeDialogAccept => 'Підтвердити';

  @override
  String get loadMore => 'Завантажити ще';

  @override
  String get searchMore => 'Шукати ще';

  @override
  String get offlineMode => 'Офлайн режим';

  @override
  String get connectTV => 'Отримати код підлюченя ТБ';

  @override
  String connectTVValue(Object code) {
    return 'Код підлюченя: $code';
  }

  @override
  String get connectTVAuth => 'Ввести код авторизації';

  @override
  String get connectTVInvalidCode => 'Невірний код авторизації';
}
