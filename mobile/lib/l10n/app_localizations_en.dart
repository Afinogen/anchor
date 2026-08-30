// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeSystemSubtitle => 'Follow device settings';

  @override
  String get themeLight => 'Light';

  @override
  String get themeLightSubtitle => 'Always use light theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeDarkSubtitle => 'Always use dark theme';

  @override
  String get language => 'Language';

  @override
  String get languageSystemSubtitle => 'Choose the interface language';

  @override
  String get editor => 'Editor';

  @override
  String get sortChecklistItems => 'Sort checklist items';

  @override
  String get sortChecklistItemsSubtitle =>
      'Automatically move checked checklist items to the bottom';

  @override
  String get account => 'Account';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get editProfileSubtitle => 'Update your name and profile image';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordSubtitle => 'Update your account password';

  @override
  String get viewLogs => 'View Logs';

  @override
  String get viewLogsSubtitle => 'Diagnostic logs for support and debugging';

  @override
  String get logOut => 'Log Out';

  @override
  String get logOutSubtitle => 'Sign out of your account';

  @override
  String appVersion(String version) {
    return 'App v$version';
  }

  @override
  String serverVersion(String version) {
    return 'Server v$version';
  }

  @override
  String get serverVersionLoading => 'Server v...';

  @override
  String get serverVersionUnknown => 'Server v—';

  @override
  String connectedTo(String url) {
    return 'Connected to $url';
  }

  @override
  String serverUnreachable(String url) {
    return 'Can\'t reach $url';
  }

  @override
  String get logoutDialogTitle => 'Log Out';

  @override
  String get logoutDialogMessage =>
      'Are you sure you want to log out? Your unsynced notes will stay safe on this device.';

  @override
  String get stay => 'Stay';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get retry => 'Retry';

  @override
  String get errorConnectionTimeout =>
      'Connection timeout. Please check your internet connection and try again.';

  @override
  String get errorSendTimeout => 'Request timeout. Please try again.';

  @override
  String get errorReceiveTimeout => 'Response timeout. Please try again.';

  @override
  String get errorConnection =>
      'No internet connection. Please check your network settings.';

  @override
  String get errorCertificate =>
      'Certificate error. If using a self-signed certificate, enable \"Allow self-signed certificates\" in server settings.';

  @override
  String get errorBadRequest => 'Invalid request. Please check your input.';

  @override
  String get errorUnauthorized =>
      'Authentication required. Please log in again.';

  @override
  String get errorForbidden => 'Permission denied.';

  @override
  String get errorNotFound => 'Resource not found.';

  @override
  String get errorServer => 'Server error. Please try again later.';

  @override
  String get errorServerUnavailable =>
      'Server unavailable. Please try again later.';

  @override
  String get errorRequestFailed => 'Request failed. Please try again.';

  @override
  String get errorCancelled => 'Request cancelled.';

  @override
  String get errorUnexpected =>
      'An unexpected error occurred. Please try again.';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageRussian => 'Русский';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String loginWithProvider(String provider) {
    return 'Login with $provider';
  }

  @override
  String get orContinueWith => 'Or continue with';

  @override
  String get email => 'Email';

  @override
  String get pleaseEnterEmail => 'Please enter email';

  @override
  String get password => 'Password';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get signIn => 'Sign In';

  @override
  String get createAnAccount => 'Create an account';

  @override
  String get createAccount => 'Create Account';

  @override
  String get startCapturingIdeas => 'Start capturing your ideas';

  @override
  String get name => 'Name';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get nameTooLong => 'Name must be less than 100 characters';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordMinLength => 'Password must be at least 8 characters';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get registrationSuccessful => 'Registration successful!';

  @override
  String get registrationPendingApproval =>
      'Registration successful! Your account is pending approval.';

  @override
  String get connectToServer => 'Connect to Server';

  @override
  String get enterServerUrl => 'Enter your Anchor server URL to get started';

  @override
  String get serverUrl => 'Server URL';

  @override
  String get serverUrlHint => 'https://your-server.com';

  @override
  String get serverUrlHelper => 'Example: https://anchor.example.com';

  @override
  String get allowSelfSigned => 'Allow self-signed certificates';

  @override
  String get selfSignedWarning => 'Warning: Connection security is reduced';

  @override
  String get selfSignedSnackbar =>
      'Self-signed certificates are now accepted. This reduces connection security.';

  @override
  String get test => 'Test';

  @override
  String get connect => 'Connect';

  @override
  String get selfHostedInfo =>
      'Anchor is self-hosted. You need to run your own server to use this app.';

  @override
  String get pleaseEnterServerUrl => 'Please enter the server URL';

  @override
  String get urlMustStartWith => 'URL must start with http:// or https://';

  @override
  String get pleaseEnterValidUrl => 'Please enter a valid URL';

  @override
  String get connectionTimedOut =>
      'Connection timed out. Check the URL and try again.';

  @override
  String get couldNotConnect => 'Could not connect to server. Check the URL.';

  @override
  String get certificateErrorTryToggle =>
      'Certificate error. Try enabling \"Allow self-signed certificates\" below.';

  @override
  String get failedToConnect => 'Failed to connect to server';

  @override
  String serverRunningVersion(String version) {
    return 'Server is running! Version: $version';
  }

  @override
  String get invalidServerResponse =>
      'Invalid server response. Is this an Anchor server?';

  @override
  String get create => 'Create';

  @override
  String get rename => 'Rename';

  @override
  String get captureIdeasHere => 'Capture your ideas here';

  @override
  String get noMatchingNotes => 'No matching notes found';

  @override
  String get allNotes => 'All Notes';

  @override
  String get archive => 'Archive';

  @override
  String get trash => 'Trash';

  @override
  String get settings => 'Settings';

  @override
  String get appTagline => 'Your thoughts, secured';

  @override
  String get tagsSectionLabel => 'TAGS';

  @override
  String get newTagTooltip => 'New tag';

  @override
  String get createTagsHint => 'Create tags to organize your notes';

  @override
  String get renameTag => 'Rename tag';

  @override
  String get deleteTag => 'Delete tag';

  @override
  String get renameTagTitle => 'Rename Tag';

  @override
  String get tagNameHint => 'Tag name';

  @override
  String get deleteTagTitle => 'Delete Tag';

  @override
  String deleteTagConfirm(String name) {
    return 'Delete \"$name\"? This will remove it from all notes.';
  }

  @override
  String get newTagTitle => 'New Tag';

  @override
  String get createTagSubtitle => 'Create a tag to organize your notes';

  @override
  String tagNotesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '$count note',
    );
    return '$_temp0';
  }

  @override
  String get menu => 'Menu';

  @override
  String get newNote => 'New Note';

  @override
  String get searchHint => 'Search your thoughts...';

  @override
  String get filteringBy => 'Filtering by';

  @override
  String get viewOptions => 'View options';

  @override
  String get selectNotes => 'Select notes';

  @override
  String notesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '$count note',
    );
    return '$_temp0';
  }

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get viewOptionsTitle => 'View Options';

  @override
  String get customizeDisplay => 'Customize display';

  @override
  String get done => 'Done';

  @override
  String get layout => 'Layout';

  @override
  String get grid => 'Grid';

  @override
  String get list => 'List';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortDateModified => 'Date Modified';

  @override
  String get sortTitle => 'Title';

  @override
  String get order => 'Order';

  @override
  String get oldestFirst => 'Oldest first';

  @override
  String get aToZ => 'A to Z';

  @override
  String get newestFirst => 'Newest first';

  @override
  String get zToA => 'Z to A';

  @override
  String get archiveNotesTitle => 'Archive Notes';

  @override
  String archiveNotesConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Archive $count notes?',
      one: 'Archive $count note?',
    );
    return '$_temp0';
  }

  @override
  String notesArchived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes archived',
      one: '$count note archived',
    );
    return '$_temp0';
  }

  @override
  String get failedToArchiveNotes => 'Failed to archive notes';

  @override
  String get deleteNotesTitle => 'Delete Notes';

  @override
  String deleteNotesConfirm(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Delete $count notes? This action cannot be undone.',
      one: 'Delete $count note? This action cannot be undone.',
    );
    return '$_temp0';
  }

  @override
  String notesDeleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes deleted',
      one: '$count note deleted',
    );
    return '$_temp0';
  }

  @override
  String get failedToDeleteNotes => 'Failed to delete notes';

  @override
  String get deselectAll => 'Deselect all';

  @override
  String get selectAll => 'Select all';

  @override
  String get moreOptions => 'More Options';

  @override
  String get moreOptionsSubtitle => 'Customize and manage your note';

  @override
  String get background => 'Background';

  @override
  String get attachment => 'Attachment';

  @override
  String get unarchive => 'Unarchive';

  @override
  String get unarchiveNoteTitle => 'Unarchive Note';

  @override
  String get noteMovedBack => 'This note will be moved back to your notes.';

  @override
  String get noteUnarchived => 'Note unarchived';

  @override
  String get failedToUnarchive => 'Failed to unarchive note';

  @override
  String get archiveEmpty => 'Archive is empty';

  @override
  String get archivedPrefix => 'Archived';

  @override
  String get restoreNoteTitle => 'Restore Note';

  @override
  String get restore => 'Restore';

  @override
  String get noteRestored => 'Note restored';

  @override
  String get failedToRestore => 'Failed to restore note';

  @override
  String get deleteForever => 'Delete Forever';

  @override
  String get deleteForeverMessage =>
      'This note will be permanently deleted and cannot be recovered.';

  @override
  String get notePermanentlyDeleted => 'Note permanently deleted';

  @override
  String get failedToDeleteNote => 'Failed to delete note';

  @override
  String get trashEmpty => 'Trash is empty';

  @override
  String get movedToTrashPrefix => 'Moved to trash';

  @override
  String get archiveNoteTitle => 'Archive Note';

  @override
  String get noteWillBeArchived => 'This note will be moved to archive.';

  @override
  String get noteArchived => 'Note archived';

  @override
  String get failedToArchive => 'Failed to archive note';

  @override
  String get attachmentAdded => 'Attachment added';

  @override
  String get failedToAddAttachment => 'Failed to add attachment';

  @override
  String get deleteNoteTitle => 'Delete Note';

  @override
  String get deleteNoteMessage =>
      'This note will be gone forever. Are you sure you want to let it go?';

  @override
  String get keep => 'Keep';

  @override
  String get noteMovedToTrash => 'Note moved to trash';

  @override
  String get noteWillBeRestored => 'This note will be restored to your notes.';

  @override
  String get deleteForeverMessageLong =>
      'This action cannot be undone. This note will be permanently deleted and cannot be recovered.';

  @override
  String sharedBy(String name) {
    return 'Shared by $name';
  }

  @override
  String get pinNote => 'Pin Note';

  @override
  String get unpinNote => 'Unpin Note';

  @override
  String get shareNote => 'Share Note';

  @override
  String get readOnlyTrashed =>
      'This note is in trash and cannot be edited. Restore it to make changes.';

  @override
  String get readOnlyViewer =>
      'You have viewer access. Only the owner can edit this note.';

  @override
  String get titleHint => 'Title';

  @override
  String get untitledNote => 'Untitled';

  @override
  String get moreOptionsTooltip => 'More options';

  @override
  String get startTyping => 'Start typing...';

  @override
  String get tags => 'Tags';

  @override
  String get addTag => 'Add tag';

  @override
  String get selectTags => 'Select Tags';

  @override
  String get organizeNote => 'Organize your note';

  @override
  String get createNewTagHint => 'Create new tag...';

  @override
  String get availableTags => 'Available Tags';

  @override
  String get noTagsYet => 'No tags yet';

  @override
  String get createFirstTagAbove => 'Create your first tag above';

  @override
  String get failedToLoadShares => 'Failed to load shares';

  @override
  String sharedWithUser(String name) {
    return 'Shared with $name';
  }

  @override
  String get failedToShare => 'Failed to share';

  @override
  String get failedToUpdate => 'Failed to update';

  @override
  String removedUser(String name) {
    return 'Removed $name';
  }

  @override
  String get failedToRemove => 'Failed to remove';

  @override
  String get collaborateWithOthers => 'Collaborate with others';

  @override
  String get searchByEmail => 'Search by name or email...';

  @override
  String get results => 'Results';

  @override
  String get notSharedYet => 'Not shared yet';

  @override
  String get searchToInvite =>
      'Search by name or email to invite collaborators';

  @override
  String get collaborators => 'Collaborators';

  @override
  String shareWithName(String name) {
    return 'Share with $name';
  }

  @override
  String get changePermission => 'Change permission';

  @override
  String get viewer => 'Viewer';

  @override
  String get viewerDesc => 'Can view but not edit';

  @override
  String get editorDesc => 'Can view and edit';

  @override
  String get passwordChangedSuccess => 'Password changed successfully';

  @override
  String get changePasswordSubtitleLong =>
      'Update your password to keep your account secure';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get pleaseEnterCurrentPassword => 'Please enter your current password';

  @override
  String get newPassword => 'New Password';

  @override
  String get pleaseEnterNewPassword => 'Please enter a new password';

  @override
  String get confirmNewPassword => 'Confirm New Password';

  @override
  String get pleaseConfirmPassword => 'Please confirm your new password';

  @override
  String get userNotFound => 'User not found';

  @override
  String failedToPickImage(String error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get remove => 'Remove';

  @override
  String get updateProfileInfo => 'Update your profile information';

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get color => 'Color';

  @override
  String get customizeNote => 'Customize your note';

  @override
  String get fmtUndo => 'Undo';

  @override
  String get fmtRedo => 'Redo';

  @override
  String get fmtBold => 'Bold';

  @override
  String get fmtItalic => 'Italic';

  @override
  String get fmtUnderline => 'Underline';

  @override
  String get fmtStrikethrough => 'Strikethrough';

  @override
  String get fmtHeading1 => 'Heading 1';

  @override
  String get fmtHeading2 => 'Heading 2';

  @override
  String get fmtHeading3 => 'Heading 3';

  @override
  String get fmtChecklist => 'Checklist';

  @override
  String get fmtNumberedList => 'Numbered List';

  @override
  String get fmtBulletList => 'Bullet List';

  @override
  String get fmtQuote => 'Quote';

  @override
  String get fmtCodeBlock => 'Code Block';

  @override
  String get fmtLink => 'Link';

  @override
  String get fmtEditLink => 'Edit link';

  @override
  String get linkTextLabel => 'Text';

  @override
  String get linkTextHint => 'Link text';

  @override
  String get urlLabel => 'URL';

  @override
  String get urlHint => 'https://...';

  @override
  String get insertLinkTitle => 'Insert Link';

  @override
  String get editLinkTitle => 'Edit Link';

  @override
  String get insert => 'Insert';

  @override
  String get linkOpen => 'Open';

  @override
  String get linkCopy => 'Copy link';

  @override
  String get linkEdit => 'Edit';

  @override
  String get splashTagline => 'Secure your thoughts';

  @override
  String get deleteAttachmentTitle => 'Delete attachment?';

  @override
  String deleteAttachmentMessage(String filename) {
    return 'This will permanently delete \"$filename\".';
  }

  @override
  String get availableWhenOnline => 'Available when online';

  @override
  String get pending => 'Pending';

  @override
  String get failedToLoadImage => 'Failed to load image';

  @override
  String get failedToRenderImage => 'Failed to render image';

  @override
  String playbackError(String error) {
    return 'Playback error: $error';
  }

  @override
  String couldNotPlayAudio(String error) {
    return 'Could not play audio: $error';
  }

  @override
  String get failedToLoadAudio => 'Failed to load audio';

  @override
  String get deleteAudioTitle => 'Delete audio?';

  @override
  String get tapToReplay => 'Tap to replay';

  @override
  String get tapToPlay => 'Tap to play';

  @override
  String get deleteAudioTooltip => 'Delete audio';

  @override
  String get microphonePermissionRequired => 'Microphone permission required';

  @override
  String get unsupportedAudioFormat =>
      'Unsupported audio format. Allowed: mp3, wav, m4a, ogg, aac';

  @override
  String get addAttachment => 'Add Attachment';

  @override
  String get recordingInProgress => 'Recording in progress';

  @override
  String get reviewYourRecording => 'Review your recording';

  @override
  String get imagesOrAudio => 'Images or audio';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseImage => 'Choose Image';

  @override
  String get recordAudio => 'Record Audio';

  @override
  String get chooseAudioFile => 'Choose Audio File';

  @override
  String get stopRecording => 'Stop Recording';

  @override
  String get recordingPreview => 'Recording preview';

  @override
  String get discard => 'Discard';

  @override
  String get reRecord => 'Re-record';

  @override
  String get logsCopied => 'Logs copied to clipboard';

  @override
  String get saveLogs => 'Save logs';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String savedFile(String filename) {
    return 'Saved $filename';
  }

  @override
  String get clearLogsTitle => 'Clear Logs';

  @override
  String get clearLogsMessage =>
      'This will delete all stored logs from this device. Continue?';

  @override
  String get clear => 'Clear';

  @override
  String get noLogEntries => 'No log entries yet';

  @override
  String get cancelSelection => 'Cancel selection';

  @override
  String copyCount(int count) {
    return 'Copy ($count)';
  }

  @override
  String get clearLogsTooltip => 'Clear logs';

  @override
  String get exportToFile => 'Export to file';

  @override
  String get copyAll => 'Copy all';

  @override
  String get logs => 'Logs';

  @override
  String get hideSearch => 'Hide search';

  @override
  String get search => 'Search';

  @override
  String get searchMessagesAndTags => 'Search messages and tags';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get filterAll => 'All';

  @override
  String get invalidLink => 'Invalid link';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get copy => 'Copy';

  @override
  String notesPinned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes pinned',
      one: '$count note pinned',
    );
    return '$_temp0';
  }

  @override
  String notesUnpinned(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes unpinned',
      one: '$count note unpinned',
    );
    return '$_temp0';
  }

  @override
  String notesTagged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tagged $count notes',
      one: 'Tagged $count note',
    );
    return '$_temp0';
  }

  @override
  String sharedWithCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Shared with $count people',
      one: 'Shared with $count person',
    );
    return '$_temp0';
  }

  @override
  String logEntriesCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries copied',
      one: '$count entry copied',
    );
    return '$_temp0';
  }

  @override
  String get failedToUpdatePins => 'Failed to update pins';

  @override
  String get failedToAddTags => 'Failed to add tags';

  @override
  String get addTags => 'Add tags';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get support => 'Support';

  @override
  String get buyMeCoffee => 'Buy me a coffee';

  @override
  String get buyMeCoffeeSubtitle => 'Support the development of Anchor';

  @override
  String get recentlySharedWith => 'Recently shared with';

  @override
  String get couldNotOpenLink => 'Couldn\'t open link';

  @override
  String get logViewerSessionInfo =>
      'This list shows logs from the current session only. Export and Copy all include the full saved history.';

  @override
  String get logLevelDebug => 'Debug';

  @override
  String get logLevelInfo => 'Info';

  @override
  String get logLevelWarn => 'Warn';

  @override
  String get logLevelError => 'Error';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String dayAtTime(String day, String time) {
    return '$day at $time';
  }

  @override
  String get revisionCauseEdit => 'Earlier version';

  @override
  String get revisionCauseConflict => 'Not saved';

  @override
  String get revisionCauseRestore => 'Before a restore';

  @override
  String get revisionHintConflict => 'Not saved. The note had already changed.';

  @override
  String get revisionHintRestore => 'What the note said before a restore.';

  @override
  String get revisionAuthorSomeone => 'Someone';

  @override
  String get revisionAuthorYou => 'You';

  @override
  String get history => 'History';

  @override
  String get currentVersion => 'Current version';

  @override
  String get historyUnreadFailed =>
      'Couldn\'t check for versions from your other devices.';

  @override
  String get historyRetention => 'Edits older than 90 days are removed.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get historyCheckFailed => 'Couldn\'t check for earlier versions';

  @override
  String get historyEmpty => 'No earlier versions yet';

  @override
  String get historyOfflineHint =>
      'Versions kept on your other devices need a connection.';

  @override
  String get historyEmptyHint =>
      'Edits to this note are kept here, so you can always go back.';

  @override
  String get restoreVersionTitle => 'Restore this version?';

  @override
  String get restoreVersionMessage =>
      'The note goes back to this version. What it says now is kept in the history.';

  @override
  String get versionRestored => 'This version is back on the note';

  @override
  String get versionRestoreFailed => 'Failed to restore this version';

  @override
  String get versionSameAsNext => 'Same text as the version after this one.';

  @override
  String get versionSameAsCurrent => 'Same text as the note as it is now.';

  @override
  String get versionNoText => 'This version has no text.';

  @override
  String get versionTitle => 'Version';

  @override
  String get versionGone => 'This version is no longer here.';

  @override
  String get serverNeedsUpdatingTitle => 'Server needs updating';

  @override
  String get appNeedsUpdatingTitle => 'App needs updating';

  @override
  String get serverNeedsUpdatingMessage =>
      'Your Anchor server is too old to sync with this app. Update the server to continue.';

  @override
  String get appNeedsUpdatingMessage =>
      'This app is too old to sync with your Anchor server. Update the app to continue.';

  @override
  String get syncWarningNotesStay =>
      'Your notes stay available on this device in the meantime.';

  @override
  String get gotIt => 'Got it';

  @override
  String get connectAnyway => 'Connect anyway';

  @override
  String serverVersionMismatch(String version, String reason) {
    return 'Anchor v$version. $reason';
  }

  @override
  String get syncPausedIncompatible => 'Sync paused, versions incompatible';

  @override
  String get displayDensity => 'Display density';

  @override
  String get densityStandard => 'Default';

  @override
  String get densityCompact => 'Compact';

  @override
  String get densityStandardSubtitle => 'More breathing room';

  @override
  String get densityCompactSubtitle => 'Fit more on screen';
}
