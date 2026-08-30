// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeSystemSubtitle => 'Следовать настройкам устройства';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeLightSubtitle => 'Всегда использовать светлую тему';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get themeDarkSubtitle => 'Всегда использовать тёмную тему';

  @override
  String get language => 'Язык';

  @override
  String get languageSystemSubtitle => 'Выберите язык интерфейса';

  @override
  String get editor => 'Редактор';

  @override
  String get sortChecklistItems => 'Сортировать пункты списка';

  @override
  String get sortChecklistItemsSubtitle =>
      'Автоматически перемещать отмеченные пункты вниз';

  @override
  String get groupCheckedByDate => 'Группировать выполненные по дате';

  @override
  String get groupCheckedByDateSubtitle =>
      'Отмеченный пункт уезжает под заголовок с датой, когда его отметили';

  @override
  String get groupCheckedByDateDisabledSubtitle =>
      'Включите сортировку, чтобы группировать выполненные по дате';

  @override
  String get account => 'Аккаунт';

  @override
  String get editProfile => 'Изменить профиль';

  @override
  String get editProfileSubtitle => 'Обновите имя и изображение профиля';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get changePasswordSubtitle => 'Обновите пароль аккаунта';

  @override
  String get viewLogs => 'Просмотр логов';

  @override
  String get viewLogsSubtitle => 'Диагностические логи для поддержки и отладки';

  @override
  String get logOut => 'Выйти';

  @override
  String get logOutSubtitle => 'Выйти из аккаунта';

  @override
  String appVersion(String version) {
    return 'Приложение v$version';
  }

  @override
  String serverVersion(String version) {
    return 'Сервер v$version';
  }

  @override
  String get serverVersionLoading => 'Сервер v...';

  @override
  String get serverVersionUnknown => 'Сервер v—';

  @override
  String connectedTo(String url) {
    return 'Подключено к $url';
  }

  @override
  String serverUnreachable(String url) {
    return 'Нет связи с $url';
  }

  @override
  String get logoutDialogTitle => 'Выйти';

  @override
  String get logoutDialogMessage =>
      'Вы уверены, что хотите выйти? Несинхронизированные заметки останутся в безопасности на этом устройстве.';

  @override
  String get stay => 'Остаться';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get retry => 'Повторить';

  @override
  String get errorConnectionTimeout =>
      'Превышено время ожидания подключения. Проверьте интернет-соединение и попробуйте снова.';

  @override
  String get errorSendTimeout =>
      'Превышено время ожидания запроса. Попробуйте снова.';

  @override
  String get errorReceiveTimeout =>
      'Превышено время ожидания ответа. Попробуйте снова.';

  @override
  String get errorConnection =>
      'Нет подключения к интернету. Проверьте настройки сети.';

  @override
  String get errorCertificate =>
      'Ошибка сертификата. Если используется самоподписанный сертификат, включите «Разрешить самоподписанные сертификаты» в настройках сервера.';

  @override
  String get errorBadRequest => 'Неверный запрос. Проверьте введённые данные.';

  @override
  String get errorUnauthorized => 'Требуется аутентификация. Войдите снова.';

  @override
  String get errorForbidden => 'Доступ запрещён.';

  @override
  String get errorNotFound => 'Ресурс не найден.';

  @override
  String get errorServer => 'Ошибка сервера. Попробуйте позже.';

  @override
  String get errorServerUnavailable => 'Сервер недоступен. Попробуйте позже.';

  @override
  String get errorRequestFailed =>
      'Не удалось выполнить запрос. Попробуйте снова.';

  @override
  String get errorCancelled => 'Запрос отменён.';

  @override
  String get errorUnexpected =>
      'Произошла непредвиденная ошибка. Попробуйте снова.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get welcomeBack => 'С возвращением';

  @override
  String get signInToContinue => 'Войдите, чтобы продолжить';

  @override
  String loginWithProvider(String provider) {
    return 'Войти через $provider';
  }

  @override
  String get orContinueWith => 'Или продолжите с';

  @override
  String get email => 'Эл. почта';

  @override
  String get pleaseEnterEmail => 'Введите эл. почту';

  @override
  String get password => 'Пароль';

  @override
  String get pleaseEnterPassword => 'Введите пароль';

  @override
  String get signIn => 'Войти';

  @override
  String get createAnAccount => 'Создать аккаунт';

  @override
  String get createAccount => 'Создать аккаунт';

  @override
  String get startCapturingIdeas => 'Начните записывать свои идеи';

  @override
  String get name => 'Имя';

  @override
  String get pleaseEnterName => 'Введите ваше имя';

  @override
  String get nameTooLong => 'Имя должно быть короче 100 символов';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get passwordMinLength => 'Пароль должен содержать не менее 8 символов';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get registrationSuccessful => 'Регистрация успешна!';

  @override
  String get registrationPendingApproval =>
      'Регистрация успешна! Ваш аккаунт ожидает одобрения.';

  @override
  String get connectToServer => 'Подключение к серверу';

  @override
  String get enterServerUrl =>
      'Введите URL вашего сервера Anchor, чтобы начать';

  @override
  String get serverUrl => 'URL сервера';

  @override
  String get serverUrlHint => 'https://your-server.com';

  @override
  String get serverUrlHelper => 'Пример: https://anchor.example.com';

  @override
  String get allowSelfSigned => 'Разрешить самоподписанные сертификаты';

  @override
  String get selfSignedWarning => 'Внимание: безопасность соединения снижена';

  @override
  String get selfSignedSnackbar =>
      'Самоподписанные сертификаты теперь принимаются. Это снижает безопасность соединения.';

  @override
  String get test => 'Проверить';

  @override
  String get connect => 'Подключиться';

  @override
  String get selfHostedInfo =>
      'Anchor — самостоятельно размещаемое приложение. Для работы нужен ваш собственный сервер.';

  @override
  String get pleaseEnterServerUrl => 'Введите URL сервера';

  @override
  String get urlMustStartWith => 'URL должен начинаться с http:// или https://';

  @override
  String get pleaseEnterValidUrl => 'Введите корректный URL';

  @override
  String get connectionTimedOut =>
      'Истекло время ожидания. Проверьте URL и попробуйте снова.';

  @override
  String get couldNotConnect =>
      'Не удалось подключиться к серверу. Проверьте URL.';

  @override
  String get certificateErrorTryToggle =>
      'Ошибка сертификата. Попробуйте включить «Разрешить самоподписанные сертификаты» ниже.';

  @override
  String get failedToConnect => 'Не удалось подключиться к серверу';

  @override
  String serverRunningVersion(String version) {
    return 'Сервер работает! Версия: $version';
  }

  @override
  String get invalidServerResponse =>
      'Неверный ответ сервера. Это сервер Anchor?';

  @override
  String get create => 'Создать';

  @override
  String get rename => 'Переименовать';

  @override
  String get captureIdeasHere => 'Записывайте свои идеи здесь';

  @override
  String get noMatchingNotes => 'Заметки не найдены';

  @override
  String get allNotes => 'Все заметки';

  @override
  String get archive => 'Архив';

  @override
  String get trash => 'Корзина';

  @override
  String get settings => 'Настройки';

  @override
  String get appTagline => 'Ваши мысли под защитой';

  @override
  String get tagsSectionLabel => 'ТЕГИ';

  @override
  String get newTagTooltip => 'Новый тег';

  @override
  String get createTagsHint => 'Создавайте теги, чтобы упорядочить заметки';

  @override
  String get renameTag => 'Переименовать тег';

  @override
  String get deleteTag => 'Удалить тег';

  @override
  String get renameTagTitle => 'Переименовать тег';

  @override
  String get tagNameHint => 'Имя тега';

  @override
  String get deleteTagTitle => 'Удалить тег';

  @override
  String deleteTagConfirm(String name) {
    return 'Удалить «$name»? Он будет удалён из всех заметок.';
  }

  @override
  String get newTagTitle => 'Новый тег';

  @override
  String get createTagSubtitle => 'Создайте тег, чтобы упорядочить заметки';

  @override
  String tagNotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заметки',
      many: '$count заметок',
      few: '$count заметки',
      one: '$count заметка',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'Меню';

  @override
  String get newNote => 'Новая заметка';

  @override
  String get searchHint => 'Поиск по заметкам...';

  @override
  String get filteringBy => 'Фильтр по';

  @override
  String get viewOptions => 'Параметры вида';

  @override
  String get selectNotes => 'Выберите заметки';

  @override
  String notesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заметки',
      many: '$count заметок',
      few: '$count заметки',
      one: '$count заметка',
    );
    return '$_temp0';
  }

  @override
  String errorWithMessage(String message) {
    return 'Ошибка: $message';
  }

  @override
  String get viewOptionsTitle => 'Параметры вида';

  @override
  String get customizeDisplay => 'Настройте отображение';

  @override
  String get done => 'Готово';

  @override
  String get layout => 'Раскладка';

  @override
  String get grid => 'Сетка';

  @override
  String get list => 'Список';

  @override
  String get sortBy => 'Сортировка';

  @override
  String get sortDateModified => 'По изменению';

  @override
  String get sortTitle => 'По названию';

  @override
  String get order => 'Порядок';

  @override
  String get oldestFirst => 'Сначала старые';

  @override
  String get aToZ => 'От А до Я';

  @override
  String get newestFirst => 'Сначала новые';

  @override
  String get zToA => 'От Я до А';

  @override
  String get archiveNotesTitle => 'Архивировать заметки';

  @override
  String archiveNotesConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Архивировать $count заметки?',
      many: 'Архивировать $count заметок?',
      few: 'Архивировать $count заметки?',
      one: 'Архивировать $count заметку?',
    );
    return '$_temp0';
  }

  @override
  String notesArchived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заметки архивировано',
      many: '$count заметок архивировано',
      few: '$count заметки архивированы',
      one: '$count заметка архивирована',
    );
    return '$_temp0';
  }

  @override
  String get failedToArchiveNotes => 'Не удалось архивировать заметки';

  @override
  String get deleteNotesTitle => 'Удалить заметки';

  @override
  String deleteNotesConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить $count заметки? Это действие необратимо.',
      many: 'Удалить $count заметок? Это действие необратимо.',
      few: 'Удалить $count заметки? Это действие необратимо.',
      one: 'Удалить $count заметку? Это действие необратимо.',
    );
    return '$_temp0';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заметки удалено',
      many: '$count заметок удалено',
      few: '$count заметки удалены',
      one: '$count заметка удалена',
    );
    return '$_temp0';
  }

  @override
  String get failedToDeleteNotes => 'Не удалось удалить заметки';

  @override
  String get deselectAll => 'Снять выделение';

  @override
  String get selectAll => 'Выбрать все';

  @override
  String get moreOptions => 'Дополнительно';

  @override
  String get moreOptionsSubtitle => 'Настройте заметку и управляйте ею';

  @override
  String get background => 'Фон';

  @override
  String get attachment => 'Вложение';

  @override
  String get unarchive => 'Из архива';

  @override
  String get unarchiveNoteTitle => 'Извлечь заметку из архива';

  @override
  String get noteMovedBack => 'Заметка вернётся в список заметок.';

  @override
  String get noteUnarchived => 'Заметка извлечена из архива';

  @override
  String get failedToUnarchive => 'Не удалось извлечь заметку из архива';

  @override
  String get archiveEmpty => 'Архив пуст';

  @override
  String get archivedPrefix => 'Архивировано';

  @override
  String get restoreNoteTitle => 'Восстановить заметку';

  @override
  String get restore => 'Восстановить';

  @override
  String get noteRestored => 'Заметка восстановлена';

  @override
  String get failedToRestore => 'Не удалось восстановить заметку';

  @override
  String get deleteForever => 'Удалить навсегда';

  @override
  String get deleteForeverMessage =>
      'Заметка будет удалена навсегда без возможности восстановления.';

  @override
  String get notePermanentlyDeleted => 'Заметка удалена навсегда';

  @override
  String get failedToDeleteNote => 'Не удалось удалить заметку';

  @override
  String get trashEmpty => 'Корзина пуста';

  @override
  String get movedToTrashPrefix => 'Перемещено в корзину';

  @override
  String get archiveNoteTitle => 'Архивировать заметку';

  @override
  String get noteWillBeArchived => 'Заметка будет перемещена в архив.';

  @override
  String get noteArchived => 'Заметка архивирована';

  @override
  String get failedToArchive => 'Не удалось архивировать заметку';

  @override
  String get attachmentAdded => 'Вложение добавлено';

  @override
  String get failedToAddAttachment => 'Не удалось добавить вложение';

  @override
  String get deleteNoteTitle => 'Удалить заметку';

  @override
  String get deleteNoteMessage =>
      'Заметка исчезнет навсегда. Вы уверены, что хотите её удалить?';

  @override
  String get keep => 'Оставить';

  @override
  String get noteMovedToTrash => 'Заметка перемещена в корзину';

  @override
  String get noteWillBeRestored =>
      'Заметка будет восстановлена в список заметок.';

  @override
  String get deleteForeverMessageLong =>
      'Это действие необратимо. Заметка будет удалена навсегда без возможности восстановления.';

  @override
  String sharedBy(String name) {
    return 'Поделился(ась) $name';
  }

  @override
  String get pinNote => 'Закрепить заметку';

  @override
  String get unpinNote => 'Открепить заметку';

  @override
  String get shareNote => 'Поделиться заметкой';

  @override
  String get readOnlyTrashed =>
      'Заметка в корзине, её нельзя редактировать. Восстановите, чтобы вносить изменения.';

  @override
  String get readOnlyViewer =>
      'У вас доступ только для чтения. Редактировать может только владелец.';

  @override
  String get titleHint => 'Заголовок';

  @override
  String get untitledNote => 'Без названия';

  @override
  String get moreOptionsTooltip => 'Ещё';

  @override
  String get startTyping => 'Начните печатать...';

  @override
  String get tags => 'Теги';

  @override
  String get addTag => 'Добавить тег';

  @override
  String get selectTags => 'Выберите теги';

  @override
  String get organizeNote => 'Упорядочьте заметку';

  @override
  String get createNewTagHint => 'Создать новый тег...';

  @override
  String get availableTags => 'Доступные теги';

  @override
  String get noTagsYet => 'Тегов пока нет';

  @override
  String get createFirstTagAbove => 'Создайте первый тег выше';

  @override
  String get failedToLoadShares => 'Не удалось загрузить доступы';

  @override
  String sharedWithUser(String name) {
    return 'Доступ открыт для $name';
  }

  @override
  String get failedToShare => 'Не удалось поделиться';

  @override
  String get failedToUpdate => 'Не удалось обновить';

  @override
  String removedUser(String name) {
    return 'Удалён: $name';
  }

  @override
  String get failedToRemove => 'Не удалось удалить';

  @override
  String get collaborateWithOthers => 'Совместная работа с другими';

  @override
  String get searchByEmail => 'Поиск по имени или эл. почте...';

  @override
  String get results => 'Результаты';

  @override
  String get notSharedYet => 'Доступ ещё не открыт';

  @override
  String get searchToInvite =>
      'Найдите по имени или эл. почте, чтобы пригласить';

  @override
  String get collaborators => 'Участники';

  @override
  String shareWithName(String name) {
    return 'Поделиться с $name';
  }

  @override
  String get changePermission => 'Изменить права';

  @override
  String get viewer => 'Читатель';

  @override
  String get viewerDesc => 'Может просматривать, но не редактировать';

  @override
  String get editorDesc => 'Может просматривать и редактировать';

  @override
  String get passwordChangedSuccess => 'Пароль успешно изменён';

  @override
  String get changePasswordSubtitleLong =>
      'Обновите пароль, чтобы защитить аккаунт';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get pleaseEnterCurrentPassword => 'Введите текущий пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get pleaseEnterNewPassword => 'Введите новый пароль';

  @override
  String get confirmNewPassword => 'Подтвердите новый пароль';

  @override
  String get pleaseConfirmPassword => 'Подтвердите новый пароль';

  @override
  String get userNotFound => 'Пользователь не найден';

  @override
  String failedToPickImage(String error) {
    return 'Не удалось выбрать изображение: $error';
  }

  @override
  String get profileUpdated => 'Профиль успешно обновлён';

  @override
  String get changePhoto => 'Изменить фото';

  @override
  String get remove => 'Удалить';

  @override
  String get updateProfileInfo => 'Обновите информацию профиля';

  @override
  String get enterYourName => 'Введите ваше имя';

  @override
  String get saveProfile => 'Сохранить профиль';

  @override
  String get color => 'Цвет';

  @override
  String get customizeNote => 'Настройте свою заметку';

  @override
  String get fmtUndo => 'Отменить';

  @override
  String get fmtRedo => 'Повторить';

  @override
  String get fmtBold => 'Жирный';

  @override
  String get fmtItalic => 'Курсив';

  @override
  String get fmtUnderline => 'Подчёркнутый';

  @override
  String get fmtStrikethrough => 'Зачёркнутый';

  @override
  String get fmtHeading1 => 'Заголовок 1';

  @override
  String get fmtHeading2 => 'Заголовок 2';

  @override
  String get fmtHeading3 => 'Заголовок 3';

  @override
  String get fmtChecklist => 'Чек-лист';

  @override
  String get fmtNumberedList => 'Нумерованный список';

  @override
  String get fmtBulletList => 'Маркированный список';

  @override
  String get fmtQuote => 'Цитата';

  @override
  String get fmtCodeBlock => 'Блок кода';

  @override
  String get fmtLink => 'Ссылка';

  @override
  String get fmtEditLink => 'Изменить ссылку';

  @override
  String get linkTextLabel => 'Текст';

  @override
  String get linkTextHint => 'Текст ссылки';

  @override
  String get urlLabel => 'URL';

  @override
  String get urlHint => 'https://...';

  @override
  String get insertLinkTitle => 'Вставить ссылку';

  @override
  String get editLinkTitle => 'Изменить ссылку';

  @override
  String get insert => 'Вставить';

  @override
  String get linkOpen => 'Открыть';

  @override
  String get linkCopy => 'Копировать ссылку';

  @override
  String get linkEdit => 'Изменить';

  @override
  String get splashTagline => 'Защитите свои мысли';

  @override
  String get deleteAttachmentTitle => 'Удалить вложение?';

  @override
  String deleteAttachmentMessage(String filename) {
    return 'Это безвозвратно удалит «$filename».';
  }

  @override
  String get availableWhenOnline => 'Доступно при подключении к сети';

  @override
  String get pending => 'Ожидает';

  @override
  String get failedToLoadImage => 'Не удалось загрузить изображение';

  @override
  String get failedToRenderImage => 'Не удалось отрисовать изображение';

  @override
  String playbackError(String error) {
    return 'Ошибка воспроизведения: $error';
  }

  @override
  String couldNotPlayAudio(String error) {
    return 'Не удалось воспроизвести аудио: $error';
  }

  @override
  String get failedToLoadAudio => 'Не удалось загрузить аудио';

  @override
  String get deleteAudioTitle => 'Удалить аудио?';

  @override
  String get tapToReplay => 'Нажмите, чтобы воспроизвести снова';

  @override
  String get tapToPlay => 'Нажмите, чтобы воспроизвести';

  @override
  String get deleteAudioTooltip => 'Удалить аудио';

  @override
  String get microphonePermissionRequired => 'Требуется доступ к микрофону';

  @override
  String get unsupportedAudioFormat =>
      'Неподдерживаемый аудиоформат. Разрешено: mp3, wav, m4a, ogg, aac';

  @override
  String get addAttachment => 'Добавить вложение';

  @override
  String get recordingInProgress => 'Идёт запись';

  @override
  String get reviewYourRecording => 'Прослушайте запись';

  @override
  String get imagesOrAudio => 'Изображения или аудио';

  @override
  String get takePhoto => 'Сделать фото';

  @override
  String get chooseImage => 'Выбрать изображение';

  @override
  String get recordAudio => 'Записать аудио';

  @override
  String get chooseAudioFile => 'Выбрать аудиофайл';

  @override
  String get stopRecording => 'Остановить запись';

  @override
  String get recordingPreview => 'Предпросмотр записи';

  @override
  String get discard => 'Отменить';

  @override
  String get reRecord => 'Перезаписать';

  @override
  String get logsCopied => 'Логи скопированы в буфер обмена';

  @override
  String get saveLogs => 'Сохранить логи';

  @override
  String exportFailed(String error) {
    return 'Не удалось экспортировать: $error';
  }

  @override
  String savedFile(String filename) {
    return 'Сохранено: $filename';
  }

  @override
  String get clearLogsTitle => 'Очистить логи';

  @override
  String get clearLogsMessage =>
      'Все сохранённые логи будут удалены с этого устройства. Продолжить?';

  @override
  String get clear => 'Очистить';

  @override
  String get noLogEntries => 'Записей логов пока нет';

  @override
  String get cancelSelection => 'Отменить выбор';

  @override
  String copyCount(int count) {
    return 'Копировать ($count)';
  }

  @override
  String get clearLogsTooltip => 'Очистить логи';

  @override
  String get exportToFile => 'Экспортировать в файл';

  @override
  String get copyAll => 'Копировать всё';

  @override
  String get logs => 'Логи';

  @override
  String get hideSearch => 'Скрыть поиск';

  @override
  String get search => 'Поиск';

  @override
  String get searchMessagesAndTags => 'Поиск по сообщениям и тегам';

  @override
  String get clearSearch => 'Очистить поиск';

  @override
  String get filterAll => 'Все';

  @override
  String get invalidLink => 'Неверная ссылка';

  @override
  String get linkCopied => 'Ссылка скопирована';

  @override
  String get copy => 'Копировать';

  @override
  String notesPinned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заметки закреплено',
      many: '$count заметок закреплено',
      few: '$count заметки закреплены',
      one: '$count заметка закреплена',
    );
    return '$_temp0';
  }

  @override
  String notesUnpinned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заметки откреплено',
      many: '$count заметок откреплено',
      few: '$count заметки откреплены',
      one: '$count заметка откреплена',
    );
    return '$_temp0';
  }

  @override
  String notesTagged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Теги добавлены к $count заметкам',
      many: 'Теги добавлены к $count заметкам',
      few: 'Теги добавлены к $count заметкам',
      one: 'Теги добавлены к $count заметке',
    );
    return '$_temp0';
  }

  @override
  String sharedWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Доступ у $count человек',
      many: 'Доступ у $count человек',
      few: 'Доступ у $count человек',
      one: 'Доступ у $count человека',
    );
    return '$_temp0';
  }

  @override
  String logEntriesCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Скопировано $count записи',
      many: 'Скопировано $count записей',
      few: 'Скопировано $count записи',
      one: 'Скопирована $count запись',
    );
    return '$_temp0';
  }

  @override
  String get failedToUpdatePins => 'Не удалось обновить закрепление';

  @override
  String get failedToAddTags => 'Не удалось добавить теги';

  @override
  String get addTags => 'Добавить теги';

  @override
  String get pin => 'Закрепить';

  @override
  String get unpin => 'Открепить';

  @override
  String get support => 'Поддержка';

  @override
  String get buyMeCoffee => 'Купить мне кофе';

  @override
  String get buyMeCoffeeSubtitle => 'Поддержите разработку Anchor';

  @override
  String get recentlySharedWith => 'Недавние контакты';

  @override
  String get couldNotOpenLink => 'Не удалось открыть ссылку';

  @override
  String get logViewerSessionInfo =>
      'Здесь показаны логи только текущей сессии. Экспорт и «Копировать всё» включают всю сохранённую историю.';

  @override
  String get logLevelDebug => 'Отладка';

  @override
  String get logLevelInfo => 'Инфо';

  @override
  String get logLevelWarn => 'Предупр.';

  @override
  String get logLevelError => 'Ошибка';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String dayAtTime(String day, String time) {
    return '$day, $time';
  }

  @override
  String get revisionCauseEdit => 'Прежняя версия';

  @override
  String get revisionCauseConflict => 'Не сохранено';

  @override
  String get revisionCauseRestore => 'До восстановления';

  @override
  String get revisionHintConflict =>
      'Не сохранено: заметка к тому моменту уже изменилась.';

  @override
  String get revisionHintRestore => 'Что было в заметке до восстановления.';

  @override
  String get revisionAuthorSomeone => 'Кто-то';

  @override
  String get revisionAuthorYou => 'Вы';

  @override
  String get history => 'История';

  @override
  String get currentVersion => 'Текущая версия';

  @override
  String get historyUnreadFailed =>
      'Не удалось получить версии с других ваших устройств.';

  @override
  String get historyRetention => 'Правки старше 90 дней удаляются.';

  @override
  String get tryAgain => 'Повторить';

  @override
  String get historyCheckFailed => 'Не удалось получить прежние версии';

  @override
  String get historyEmpty => 'Прежних версий пока нет';

  @override
  String get historyOfflineHint =>
      'Для версий с других устройств нужно подключение.';

  @override
  String get historyEmptyHint =>
      'Правки заметки хранятся здесь — всегда можно вернуться назад.';

  @override
  String get restoreVersionTitle => 'Восстановить эту версию?';

  @override
  String get restoreVersionMessage =>
      'Заметка вернётся к этой версии. Текущий текст сохранится в истории.';

  @override
  String get versionRestored => 'Версия восстановлена';

  @override
  String get versionRestoreFailed => 'Не удалось восстановить версию';

  @override
  String get versionSameAsNext => 'Текст совпадает со следующей версией.';

  @override
  String get versionSameAsCurrent => 'Текст совпадает с текущей заметкой.';

  @override
  String get versionNoText => 'В этой версии нет текста.';

  @override
  String get versionTitle => 'Версия';

  @override
  String get versionGone => 'Этой версии больше нет.';

  @override
  String get serverNeedsUpdatingTitle => 'Нужно обновить сервер';

  @override
  String get appNeedsUpdatingTitle => 'Нужно обновить приложение';

  @override
  String get serverNeedsUpdatingMessage =>
      'Версия сервера Anchor слишком старая для синхронизации с этим приложением. Обновите сервер.';

  @override
  String get appNeedsUpdatingMessage =>
      'Версия приложения слишком старая для синхронизации с вашим сервером Anchor. Обновите приложение.';

  @override
  String get syncWarningNotesStay =>
      'Заметки на этом устройстве всё это время остаются доступны.';

  @override
  String get gotIt => 'Понятно';

  @override
  String get connectAnyway => 'Всё равно подключиться';

  @override
  String serverVersionMismatch(String version, String reason) {
    return 'Anchor v$version. $reason';
  }

  @override
  String get syncPausedIncompatible =>
      'Синхронизация приостановлена: версии несовместимы';

  @override
  String get displayDensity => 'Плотность интерфейса';

  @override
  String get densityStandard => 'Обычная';

  @override
  String get densityCompact => 'Компактная';

  @override
  String get densityStandardSubtitle => 'Больше воздуха';

  @override
  String get densityCompactSubtitle => 'Больше помещается на экране';
}
