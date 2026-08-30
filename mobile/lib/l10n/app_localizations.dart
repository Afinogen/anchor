import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ru'),
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow device settings'**
  String get themeSystemSubtitle;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeLightSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always use light theme'**
  String get themeLightSubtitle;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeDarkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Always use dark theme'**
  String get themeDarkSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystemSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the interface language'**
  String get languageSystemSubtitle;

  /// No description provided for @editor.
  ///
  /// In en, this message translates to:
  /// **'Editor'**
  String get editor;

  /// No description provided for @sortChecklistItems.
  ///
  /// In en, this message translates to:
  /// **'Sort checklist items'**
  String get sortChecklistItems;

  /// No description provided for @sortChecklistItemsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Automatically move checked checklist items to the bottom'**
  String get sortChecklistItemsSubtitle;

  /// No description provided for @groupCheckedByDate.
  ///
  /// In en, this message translates to:
  /// **'Group checked items by date'**
  String get groupCheckedByDate;

  /// No description provided for @groupCheckedByDateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Move a checked item under a heading with the day it was checked'**
  String get groupCheckedByDateSubtitle;

  /// No description provided for @groupCheckedByDateDisabledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Turn on sorting to group checked items by date'**
  String get groupCheckedByDateDisabledSubtitle;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your name and profile image'**
  String get editProfileSubtitle;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get changePasswordSubtitle;

  /// No description provided for @viewLogs.
  ///
  /// In en, this message translates to:
  /// **'View Logs'**
  String get viewLogs;

  /// No description provided for @viewLogsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic logs for support and debugging'**
  String get viewLogsSubtitle;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @logOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your account'**
  String get logOutSubtitle;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App v{version}'**
  String appVersion(String version);

  /// No description provided for @serverVersion.
  ///
  /// In en, this message translates to:
  /// **'Server v{version}'**
  String serverVersion(String version);

  /// No description provided for @serverVersionLoading.
  ///
  /// In en, this message translates to:
  /// **'Server v...'**
  String get serverVersionLoading;

  /// No description provided for @serverVersionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Server v—'**
  String get serverVersionUnknown;

  /// No description provided for @connectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to {url}'**
  String connectedTo(String url);

  /// No description provided for @serverUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach {url}'**
  String serverUnreachable(String url);

  /// No description provided for @logoutDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutDialogTitle;

  /// No description provided for @logoutDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out? Your unsynced notes will stay safe on this device.'**
  String get logoutDialogMessage;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @errorConnectionTimeout.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout. Please check your internet connection and try again.'**
  String get errorConnectionTimeout;

  /// No description provided for @errorSendTimeout.
  ///
  /// In en, this message translates to:
  /// **'Request timeout. Please try again.'**
  String get errorSendTimeout;

  /// No description provided for @errorReceiveTimeout.
  ///
  /// In en, this message translates to:
  /// **'Response timeout. Please try again.'**
  String get errorReceiveTimeout;

  /// No description provided for @errorConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network settings.'**
  String get errorConnection;

  /// No description provided for @errorCertificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate error. If using a self-signed certificate, enable \"Allow self-signed certificates\" in server settings.'**
  String get errorCertificate;

  /// No description provided for @errorBadRequest.
  ///
  /// In en, this message translates to:
  /// **'Invalid request. Please check your input.'**
  String get errorBadRequest;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Authentication required. Please log in again.'**
  String get errorUnauthorized;

  /// No description provided for @errorForbidden.
  ///
  /// In en, this message translates to:
  /// **'Permission denied.'**
  String get errorForbidden;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found.'**
  String get errorNotFound;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get errorServer;

  /// No description provided for @errorServerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Server unavailable. Please try again later.'**
  String get errorServerUnavailable;

  /// No description provided for @errorRequestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed. Please try again.'**
  String get errorRequestFailed;

  /// No description provided for @errorCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled.'**
  String get errorCancelled;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorUnexpected;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @loginWithProvider.
  ///
  /// In en, this message translates to:
  /// **'Login with {provider}'**
  String loginWithProvider(String provider);

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get orContinueWith;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @pleaseEnterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get pleaseEnterEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @startCapturingIdeas.
  ///
  /// In en, this message translates to:
  /// **'Start capturing your ideas'**
  String get startCapturingIdeas;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// No description provided for @nameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Name must be less than 100 characters'**
  String get nameTooLong;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccessful;

  /// No description provided for @registrationPendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Registration successful! Your account is pending approval.'**
  String get registrationPendingApproval;

  /// No description provided for @connectToServer.
  ///
  /// In en, this message translates to:
  /// **'Connect to Server'**
  String get connectToServer;

  /// No description provided for @enterServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter your Anchor server URL to get started'**
  String get enterServerUrl;

  /// No description provided for @serverUrl.
  ///
  /// In en, this message translates to:
  /// **'Server URL'**
  String get serverUrl;

  /// No description provided for @serverUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://your-server.com'**
  String get serverUrlHint;

  /// No description provided for @serverUrlHelper.
  ///
  /// In en, this message translates to:
  /// **'Example: https://anchor.example.com'**
  String get serverUrlHelper;

  /// No description provided for @allowSelfSigned.
  ///
  /// In en, this message translates to:
  /// **'Allow self-signed certificates'**
  String get allowSelfSigned;

  /// No description provided for @selfSignedWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Connection security is reduced'**
  String get selfSignedWarning;

  /// No description provided for @selfSignedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Self-signed certificates are now accepted. This reduces connection security.'**
  String get selfSignedSnackbar;

  /// No description provided for @test.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get test;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @selfHostedInfo.
  ///
  /// In en, this message translates to:
  /// **'Anchor is self-hosted. You need to run your own server to use this app.'**
  String get selfHostedInfo;

  /// No description provided for @pleaseEnterServerUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter the server URL'**
  String get pleaseEnterServerUrl;

  /// No description provided for @urlMustStartWith.
  ///
  /// In en, this message translates to:
  /// **'URL must start with http:// or https://'**
  String get urlMustStartWith;

  /// No description provided for @pleaseEnterValidUrl.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid URL'**
  String get pleaseEnterValidUrl;

  /// No description provided for @connectionTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Connection timed out. Check the URL and try again.'**
  String get connectionTimedOut;

  /// No description provided for @couldNotConnect.
  ///
  /// In en, this message translates to:
  /// **'Could not connect to server. Check the URL.'**
  String get couldNotConnect;

  /// No description provided for @certificateErrorTryToggle.
  ///
  /// In en, this message translates to:
  /// **'Certificate error. Try enabling \"Allow self-signed certificates\" below.'**
  String get certificateErrorTryToggle;

  /// No description provided for @failedToConnect.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to server'**
  String get failedToConnect;

  /// No description provided for @serverRunningVersion.
  ///
  /// In en, this message translates to:
  /// **'Server is running! Version: {version}'**
  String serverRunningVersion(String version);

  /// No description provided for @invalidServerResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid server response. Is this an Anchor server?'**
  String get invalidServerResponse;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @captureIdeasHere.
  ///
  /// In en, this message translates to:
  /// **'Capture your ideas here'**
  String get captureIdeasHere;

  /// No description provided for @noMatchingNotes.
  ///
  /// In en, this message translates to:
  /// **'No matching notes found'**
  String get noMatchingNotes;

  /// No description provided for @allNotes.
  ///
  /// In en, this message translates to:
  /// **'All Notes'**
  String get allNotes;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Your thoughts, secured'**
  String get appTagline;

  /// No description provided for @tagsSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'TAGS'**
  String get tagsSectionLabel;

  /// No description provided for @newTagTooltip.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get newTagTooltip;

  /// No description provided for @createTagsHint.
  ///
  /// In en, this message translates to:
  /// **'Create tags to organize your notes'**
  String get createTagsHint;

  /// No description provided for @renameTag.
  ///
  /// In en, this message translates to:
  /// **'Rename tag'**
  String get renameTag;

  /// No description provided for @deleteTag.
  ///
  /// In en, this message translates to:
  /// **'Delete tag'**
  String get deleteTag;

  /// No description provided for @renameTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename Tag'**
  String get renameTagTitle;

  /// No description provided for @tagNameHint.
  ///
  /// In en, this message translates to:
  /// **'Tag name'**
  String get tagNameHint;

  /// No description provided for @deleteTagTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Tag'**
  String get deleteTagTitle;

  /// No description provided for @deleteTagConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This will remove it from all notes.'**
  String deleteTagConfirm(String name);

  /// No description provided for @newTagTitle.
  ///
  /// In en, this message translates to:
  /// **'New Tag'**
  String get newTagTitle;

  /// No description provided for @createTagSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create a tag to organize your notes'**
  String get createTagSubtitle;

  /// No description provided for @tagNotesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} note} other{{count} notes}}'**
  String tagNotesCount(int count);

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New Note'**
  String get newNote;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search your thoughts...'**
  String get searchHint;

  /// No description provided for @filteringBy.
  ///
  /// In en, this message translates to:
  /// **'Filtering by'**
  String get filteringBy;

  /// No description provided for @viewOptions.
  ///
  /// In en, this message translates to:
  /// **'View options'**
  String get viewOptions;

  /// No description provided for @selectNotes.
  ///
  /// In en, this message translates to:
  /// **'Select notes'**
  String get selectNotes;

  /// No description provided for @notesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} note} other{{count} notes}}'**
  String notesCount(int count);

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @viewOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'View Options'**
  String get viewOptionsTitle;

  /// No description provided for @customizeDisplay.
  ///
  /// In en, this message translates to:
  /// **'Customize display'**
  String get customizeDisplay;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @layout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get layout;

  /// No description provided for @grid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get grid;

  /// No description provided for @list.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get list;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortDateModified.
  ///
  /// In en, this message translates to:
  /// **'Date Modified'**
  String get sortDateModified;

  /// No description provided for @sortTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get sortTitle;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get oldestFirst;

  /// No description provided for @aToZ.
  ///
  /// In en, this message translates to:
  /// **'A to Z'**
  String get aToZ;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get newestFirst;

  /// No description provided for @zToA.
  ///
  /// In en, this message translates to:
  /// **'Z to A'**
  String get zToA;

  /// No description provided for @archiveNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive Notes'**
  String get archiveNotesTitle;

  /// No description provided for @archiveNotesConfirm.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Archive {count} note?} other{Archive {count} notes?}}'**
  String archiveNotesConfirm(int count);

  /// No description provided for @notesArchived.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} note archived} other{{count} notes archived}}'**
  String notesArchived(int count);

  /// No description provided for @failedToArchiveNotes.
  ///
  /// In en, this message translates to:
  /// **'Failed to archive notes'**
  String get failedToArchiveNotes;

  /// No description provided for @deleteNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Notes'**
  String get deleteNotesTitle;

  /// No description provided for @deleteNotesConfirm.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Delete {count} note? This action cannot be undone.} other{Delete {count} notes? This action cannot be undone.}}'**
  String deleteNotesConfirm(int count);

  /// No description provided for @notesDeleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} note deleted} other{{count} notes deleted}}'**
  String notesDeleted(int count);

  /// No description provided for @failedToDeleteNotes.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete notes'**
  String get failedToDeleteNotes;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get deselectAll;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More Options'**
  String get moreOptions;

  /// No description provided for @moreOptionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize and manage your note'**
  String get moreOptionsSubtitle;

  /// No description provided for @background.
  ///
  /// In en, this message translates to:
  /// **'Background'**
  String get background;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Unarchive'**
  String get unarchive;

  /// No description provided for @unarchiveNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Unarchive Note'**
  String get unarchiveNoteTitle;

  /// No description provided for @noteMovedBack.
  ///
  /// In en, this message translates to:
  /// **'This note will be moved back to your notes.'**
  String get noteMovedBack;

  /// No description provided for @noteUnarchived.
  ///
  /// In en, this message translates to:
  /// **'Note unarchived'**
  String get noteUnarchived;

  /// No description provided for @failedToUnarchive.
  ///
  /// In en, this message translates to:
  /// **'Failed to unarchive note'**
  String get failedToUnarchive;

  /// No description provided for @archiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'Archive is empty'**
  String get archiveEmpty;

  /// No description provided for @archivedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archivedPrefix;

  /// No description provided for @restoreNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore Note'**
  String get restoreNoteTitle;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @noteRestored.
  ///
  /// In en, this message translates to:
  /// **'Note restored'**
  String get noteRestored;

  /// No description provided for @failedToRestore.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore note'**
  String get failedToRestore;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete Forever'**
  String get deleteForever;

  /// No description provided for @deleteForeverMessage.
  ///
  /// In en, this message translates to:
  /// **'This note will be permanently deleted and cannot be recovered.'**
  String get deleteForeverMessage;

  /// No description provided for @notePermanentlyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Note permanently deleted'**
  String get notePermanentlyDeleted;

  /// No description provided for @failedToDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete note'**
  String get failedToDeleteNote;

  /// No description provided for @trashEmpty.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get trashEmpty;

  /// No description provided for @movedToTrashPrefix.
  ///
  /// In en, this message translates to:
  /// **'Moved to trash'**
  String get movedToTrashPrefix;

  /// No description provided for @archiveNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive Note'**
  String get archiveNoteTitle;

  /// No description provided for @noteWillBeArchived.
  ///
  /// In en, this message translates to:
  /// **'This note will be moved to archive.'**
  String get noteWillBeArchived;

  /// No description provided for @noteArchived.
  ///
  /// In en, this message translates to:
  /// **'Note archived'**
  String get noteArchived;

  /// No description provided for @failedToArchive.
  ///
  /// In en, this message translates to:
  /// **'Failed to archive note'**
  String get failedToArchive;

  /// No description provided for @attachmentAdded.
  ///
  /// In en, this message translates to:
  /// **'Attachment added'**
  String get attachmentAdded;

  /// No description provided for @failedToAddAttachment.
  ///
  /// In en, this message translates to:
  /// **'Failed to add attachment'**
  String get failedToAddAttachment;

  /// No description provided for @deleteNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNoteTitle;

  /// No description provided for @deleteNoteMessage.
  ///
  /// In en, this message translates to:
  /// **'This note will be gone forever. Are you sure you want to let it go?'**
  String get deleteNoteMessage;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @noteMovedToTrash.
  ///
  /// In en, this message translates to:
  /// **'Note moved to trash'**
  String get noteMovedToTrash;

  /// No description provided for @noteWillBeRestored.
  ///
  /// In en, this message translates to:
  /// **'This note will be restored to your notes.'**
  String get noteWillBeRestored;

  /// No description provided for @deleteForeverMessageLong.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. This note will be permanently deleted and cannot be recovered.'**
  String get deleteForeverMessageLong;

  /// No description provided for @sharedBy.
  ///
  /// In en, this message translates to:
  /// **'Shared by {name}'**
  String sharedBy(String name);

  /// No description provided for @pinNote.
  ///
  /// In en, this message translates to:
  /// **'Pin Note'**
  String get pinNote;

  /// No description provided for @unpinNote.
  ///
  /// In en, this message translates to:
  /// **'Unpin Note'**
  String get unpinNote;

  /// No description provided for @shareNote.
  ///
  /// In en, this message translates to:
  /// **'Share Note'**
  String get shareNote;

  /// No description provided for @readOnlyTrashed.
  ///
  /// In en, this message translates to:
  /// **'This note is in trash and cannot be edited. Restore it to make changes.'**
  String get readOnlyTrashed;

  /// No description provided for @readOnlyViewer.
  ///
  /// In en, this message translates to:
  /// **'You have viewer access. Only the owner can edit this note.'**
  String get readOnlyViewer;

  /// No description provided for @titleHint.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleHint;

  /// No description provided for @untitledNote.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get untitledNote;

  /// No description provided for @moreOptionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptionsTooltip;

  /// No description provided for @startTyping.
  ///
  /// In en, this message translates to:
  /// **'Start typing...'**
  String get startTyping;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @selectTags.
  ///
  /// In en, this message translates to:
  /// **'Select Tags'**
  String get selectTags;

  /// No description provided for @organizeNote.
  ///
  /// In en, this message translates to:
  /// **'Organize your note'**
  String get organizeNote;

  /// No description provided for @createNewTagHint.
  ///
  /// In en, this message translates to:
  /// **'Create new tag...'**
  String get createNewTagHint;

  /// No description provided for @availableTags.
  ///
  /// In en, this message translates to:
  /// **'Available Tags'**
  String get availableTags;

  /// No description provided for @noTagsYet.
  ///
  /// In en, this message translates to:
  /// **'No tags yet'**
  String get noTagsYet;

  /// No description provided for @createFirstTagAbove.
  ///
  /// In en, this message translates to:
  /// **'Create your first tag above'**
  String get createFirstTagAbove;

  /// No description provided for @failedToLoadShares.
  ///
  /// In en, this message translates to:
  /// **'Failed to load shares'**
  String get failedToLoadShares;

  /// No description provided for @sharedWithUser.
  ///
  /// In en, this message translates to:
  /// **'Shared with {name}'**
  String sharedWithUser(String name);

  /// No description provided for @failedToShare.
  ///
  /// In en, this message translates to:
  /// **'Failed to share'**
  String get failedToShare;

  /// No description provided for @failedToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to update'**
  String get failedToUpdate;

  /// No description provided for @removedUser.
  ///
  /// In en, this message translates to:
  /// **'Removed {name}'**
  String removedUser(String name);

  /// No description provided for @failedToRemove.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove'**
  String get failedToRemove;

  /// No description provided for @collaborateWithOthers.
  ///
  /// In en, this message translates to:
  /// **'Collaborate with others'**
  String get collaborateWithOthers;

  /// No description provided for @searchByEmail.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email...'**
  String get searchByEmail;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @notSharedYet.
  ///
  /// In en, this message translates to:
  /// **'Not shared yet'**
  String get notSharedYet;

  /// No description provided for @searchToInvite.
  ///
  /// In en, this message translates to:
  /// **'Search by name or email to invite collaborators'**
  String get searchToInvite;

  /// No description provided for @collaborators.
  ///
  /// In en, this message translates to:
  /// **'Collaborators'**
  String get collaborators;

  /// No description provided for @shareWithName.
  ///
  /// In en, this message translates to:
  /// **'Share with {name}'**
  String shareWithName(String name);

  /// No description provided for @changePermission.
  ///
  /// In en, this message translates to:
  /// **'Change permission'**
  String get changePermission;

  /// No description provided for @viewer.
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get viewer;

  /// No description provided for @viewerDesc.
  ///
  /// In en, this message translates to:
  /// **'Can view but not edit'**
  String get viewerDesc;

  /// No description provided for @editorDesc.
  ///
  /// In en, this message translates to:
  /// **'Can view and edit'**
  String get editorDesc;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccess;

  /// No description provided for @changePasswordSubtitleLong.
  ///
  /// In en, this message translates to:
  /// **'Update your password to keep your account secure'**
  String get changePasswordSubtitleLong;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @pleaseEnterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password'**
  String get pleaseEnterCurrentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @pleaseEnterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password'**
  String get pleaseEnterNewPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password'**
  String get pleaseConfirmPassword;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String failedToPickImage(String error);

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @updateProfileInfo.
  ///
  /// In en, this message translates to:
  /// **'Update your profile information'**
  String get updateProfileInfo;

  /// No description provided for @enterYourName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterYourName;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @customizeNote.
  ///
  /// In en, this message translates to:
  /// **'Customize your note'**
  String get customizeNote;

  /// No description provided for @fmtUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get fmtUndo;

  /// No description provided for @fmtRedo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get fmtRedo;

  /// No description provided for @fmtBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get fmtBold;

  /// No description provided for @fmtItalic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get fmtItalic;

  /// No description provided for @fmtUnderline.
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get fmtUnderline;

  /// No description provided for @fmtStrikethrough.
  ///
  /// In en, this message translates to:
  /// **'Strikethrough'**
  String get fmtStrikethrough;

  /// No description provided for @fmtHeading1.
  ///
  /// In en, this message translates to:
  /// **'Heading 1'**
  String get fmtHeading1;

  /// No description provided for @fmtHeading2.
  ///
  /// In en, this message translates to:
  /// **'Heading 2'**
  String get fmtHeading2;

  /// No description provided for @fmtHeading3.
  ///
  /// In en, this message translates to:
  /// **'Heading 3'**
  String get fmtHeading3;

  /// No description provided for @fmtChecklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get fmtChecklist;

  /// No description provided for @fmtNumberedList.
  ///
  /// In en, this message translates to:
  /// **'Numbered List'**
  String get fmtNumberedList;

  /// No description provided for @fmtBulletList.
  ///
  /// In en, this message translates to:
  /// **'Bullet List'**
  String get fmtBulletList;

  /// No description provided for @fmtQuote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get fmtQuote;

  /// No description provided for @fmtCodeBlock.
  ///
  /// In en, this message translates to:
  /// **'Code Block'**
  String get fmtCodeBlock;

  /// No description provided for @fmtLink.
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get fmtLink;

  /// No description provided for @fmtEditLink.
  ///
  /// In en, this message translates to:
  /// **'Edit link'**
  String get fmtEditLink;

  /// No description provided for @linkTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get linkTextLabel;

  /// No description provided for @linkTextHint.
  ///
  /// In en, this message translates to:
  /// **'Link text'**
  String get linkTextHint;

  /// No description provided for @urlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get urlLabel;

  /// No description provided for @urlHint.
  ///
  /// In en, this message translates to:
  /// **'https://...'**
  String get urlHint;

  /// No description provided for @insertLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Insert Link'**
  String get insertLinkTitle;

  /// No description provided for @editLinkTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Link'**
  String get editLinkTitle;

  /// No description provided for @insert.
  ///
  /// In en, this message translates to:
  /// **'Insert'**
  String get insert;

  /// No description provided for @linkOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get linkOpen;

  /// No description provided for @linkCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get linkCopy;

  /// No description provided for @linkEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get linkEdit;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Secure your thoughts'**
  String get splashTagline;

  /// No description provided for @deleteAttachmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete attachment?'**
  String get deleteAttachmentTitle;

  /// No description provided for @deleteAttachmentMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete \"{filename}\".'**
  String deleteAttachmentMessage(String filename);

  /// No description provided for @availableWhenOnline.
  ///
  /// In en, this message translates to:
  /// **'Available when online'**
  String get availableWhenOnline;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get failedToLoadImage;

  /// No description provided for @failedToRenderImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to render image'**
  String get failedToRenderImage;

  /// No description provided for @playbackError.
  ///
  /// In en, this message translates to:
  /// **'Playback error: {error}'**
  String playbackError(String error);

  /// No description provided for @couldNotPlayAudio.
  ///
  /// In en, this message translates to:
  /// **'Could not play audio: {error}'**
  String couldNotPlayAudio(String error);

  /// No description provided for @failedToLoadAudio.
  ///
  /// In en, this message translates to:
  /// **'Failed to load audio'**
  String get failedToLoadAudio;

  /// No description provided for @deleteAudioTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete audio?'**
  String get deleteAudioTitle;

  /// No description provided for @tapToReplay.
  ///
  /// In en, this message translates to:
  /// **'Tap to replay'**
  String get tapToReplay;

  /// No description provided for @tapToPlay.
  ///
  /// In en, this message translates to:
  /// **'Tap to play'**
  String get tapToPlay;

  /// No description provided for @deleteAudioTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete audio'**
  String get deleteAudioTooltip;

  /// No description provided for @microphonePermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission required'**
  String get microphonePermissionRequired;

  /// No description provided for @unsupportedAudioFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported audio format. Allowed: mp3, wav, m4a, ogg, aac'**
  String get unsupportedAudioFormat;

  /// No description provided for @addAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add Attachment'**
  String get addAttachment;

  /// No description provided for @recordingInProgress.
  ///
  /// In en, this message translates to:
  /// **'Recording in progress'**
  String get recordingInProgress;

  /// No description provided for @reviewYourRecording.
  ///
  /// In en, this message translates to:
  /// **'Review your recording'**
  String get reviewYourRecording;

  /// No description provided for @imagesOrAudio.
  ///
  /// In en, this message translates to:
  /// **'Images or audio'**
  String get imagesOrAudio;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseImage.
  ///
  /// In en, this message translates to:
  /// **'Choose Image'**
  String get chooseImage;

  /// No description provided for @recordAudio.
  ///
  /// In en, this message translates to:
  /// **'Record Audio'**
  String get recordAudio;

  /// No description provided for @chooseAudioFile.
  ///
  /// In en, this message translates to:
  /// **'Choose Audio File'**
  String get chooseAudioFile;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop Recording'**
  String get stopRecording;

  /// No description provided for @recordingPreview.
  ///
  /// In en, this message translates to:
  /// **'Recording preview'**
  String get recordingPreview;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @reRecord.
  ///
  /// In en, this message translates to:
  /// **'Re-record'**
  String get reRecord;

  /// No description provided for @logsCopied.
  ///
  /// In en, this message translates to:
  /// **'Logs copied to clipboard'**
  String get logsCopied;

  /// No description provided for @saveLogs.
  ///
  /// In en, this message translates to:
  /// **'Save logs'**
  String get saveLogs;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @savedFile.
  ///
  /// In en, this message translates to:
  /// **'Saved {filename}'**
  String savedFile(String filename);

  /// No description provided for @clearLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get clearLogsTitle;

  /// No description provided for @clearLogsMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete all stored logs from this device. Continue?'**
  String get clearLogsMessage;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @noLogEntries.
  ///
  /// In en, this message translates to:
  /// **'No log entries yet'**
  String get noLogEntries;

  /// No description provided for @cancelSelection.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get cancelSelection;

  /// No description provided for @copyCount.
  ///
  /// In en, this message translates to:
  /// **'Copy ({count})'**
  String copyCount(int count);

  /// No description provided for @clearLogsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Clear logs'**
  String get clearLogsTooltip;

  /// No description provided for @exportToFile.
  ///
  /// In en, this message translates to:
  /// **'Export to file'**
  String get exportToFile;

  /// No description provided for @copyAll.
  ///
  /// In en, this message translates to:
  /// **'Copy all'**
  String get copyAll;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @hideSearch.
  ///
  /// In en, this message translates to:
  /// **'Hide search'**
  String get hideSearch;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchMessagesAndTags.
  ///
  /// In en, this message translates to:
  /// **'Search messages and tags'**
  String get searchMessagesAndTags;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @invalidLink.
  ///
  /// In en, this message translates to:
  /// **'Invalid link'**
  String get invalidLink;

  /// No description provided for @linkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @notesPinned.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} note pinned} other{{count} notes pinned}}'**
  String notesPinned(int count);

  /// No description provided for @notesUnpinned.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} note unpinned} other{{count} notes unpinned}}'**
  String notesUnpinned(int count);

  /// No description provided for @notesTagged.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Tagged {count} note} other{Tagged {count} notes}}'**
  String notesTagged(int count);

  /// No description provided for @sharedWithCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{Shared with {count} person} other{Shared with {count} people}}'**
  String sharedWithCount(int count);

  /// No description provided for @logEntriesCopied.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} entry copied} other{{count} entries copied}}'**
  String logEntriesCopied(int count);

  /// No description provided for @failedToUpdatePins.
  ///
  /// In en, this message translates to:
  /// **'Failed to update pins'**
  String get failedToUpdatePins;

  /// No description provided for @failedToAddTags.
  ///
  /// In en, this message translates to:
  /// **'Failed to add tags'**
  String get failedToAddTags;

  /// No description provided for @addTags.
  ///
  /// In en, this message translates to:
  /// **'Add tags'**
  String get addTags;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @buyMeCoffee.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee'**
  String get buyMeCoffee;

  /// No description provided for @buyMeCoffeeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Support the development of Anchor'**
  String get buyMeCoffeeSubtitle;

  /// No description provided for @recentlySharedWith.
  ///
  /// In en, this message translates to:
  /// **'Recently shared with'**
  String get recentlySharedWith;

  /// No description provided for @couldNotOpenLink.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open link'**
  String get couldNotOpenLink;

  /// No description provided for @logViewerSessionInfo.
  ///
  /// In en, this message translates to:
  /// **'This list shows logs from the current session only. Export and Copy all include the full saved history.'**
  String get logViewerSessionInfo;

  /// No description provided for @logLevelDebug.
  ///
  /// In en, this message translates to:
  /// **'Debug'**
  String get logLevelDebug;

  /// No description provided for @logLevelInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get logLevelInfo;

  /// No description provided for @logLevelWarn.
  ///
  /// In en, this message translates to:
  /// **'Warn'**
  String get logLevelWarn;

  /// No description provided for @logLevelError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get logLevelError;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @dayAtTime.
  ///
  /// In en, this message translates to:
  /// **'{day} at {time}'**
  String dayAtTime(String day, String time);

  /// No description provided for @revisionCauseEdit.
  ///
  /// In en, this message translates to:
  /// **'Earlier version'**
  String get revisionCauseEdit;

  /// No description provided for @revisionCauseConflict.
  ///
  /// In en, this message translates to:
  /// **'Not saved'**
  String get revisionCauseConflict;

  /// No description provided for @revisionCauseRestore.
  ///
  /// In en, this message translates to:
  /// **'Before a restore'**
  String get revisionCauseRestore;

  /// No description provided for @revisionHintConflict.
  ///
  /// In en, this message translates to:
  /// **'Not saved. The note had already changed.'**
  String get revisionHintConflict;

  /// No description provided for @revisionHintRestore.
  ///
  /// In en, this message translates to:
  /// **'What the note said before a restore.'**
  String get revisionHintRestore;

  /// No description provided for @revisionAuthorSomeone.
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get revisionAuthorSomeone;

  /// No description provided for @revisionAuthorYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get revisionAuthorYou;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @currentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version'**
  String get currentVersion;

  /// No description provided for @historyUnreadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check for versions from your other devices.'**
  String get historyUnreadFailed;

  /// No description provided for @historyRetention.
  ///
  /// In en, this message translates to:
  /// **'Edits older than 90 days are removed.'**
  String get historyRetention;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @historyCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t check for earlier versions'**
  String get historyCheckFailed;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No earlier versions yet'**
  String get historyEmpty;

  /// No description provided for @historyOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'Versions kept on your other devices need a connection.'**
  String get historyOfflineHint;

  /// No description provided for @historyEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Edits to this note are kept here, so you can always go back.'**
  String get historyEmptyHint;

  /// No description provided for @restoreVersionTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore this version?'**
  String get restoreVersionTitle;

  /// No description provided for @restoreVersionMessage.
  ///
  /// In en, this message translates to:
  /// **'The note goes back to this version. What it says now is kept in the history.'**
  String get restoreVersionMessage;

  /// No description provided for @versionRestored.
  ///
  /// In en, this message translates to:
  /// **'This version is back on the note'**
  String get versionRestored;

  /// No description provided for @versionRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore this version'**
  String get versionRestoreFailed;

  /// No description provided for @versionSameAsNext.
  ///
  /// In en, this message translates to:
  /// **'Same text as the version after this one.'**
  String get versionSameAsNext;

  /// No description provided for @versionSameAsCurrent.
  ///
  /// In en, this message translates to:
  /// **'Same text as the note as it is now.'**
  String get versionSameAsCurrent;

  /// No description provided for @versionNoText.
  ///
  /// In en, this message translates to:
  /// **'This version has no text.'**
  String get versionNoText;

  /// No description provided for @versionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionTitle;

  /// No description provided for @versionGone.
  ///
  /// In en, this message translates to:
  /// **'This version is no longer here.'**
  String get versionGone;

  /// No description provided for @serverNeedsUpdatingTitle.
  ///
  /// In en, this message translates to:
  /// **'Server needs updating'**
  String get serverNeedsUpdatingTitle;

  /// No description provided for @appNeedsUpdatingTitle.
  ///
  /// In en, this message translates to:
  /// **'App needs updating'**
  String get appNeedsUpdatingTitle;

  /// No description provided for @serverNeedsUpdatingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your Anchor server is too old to sync with this app. Update the server to continue.'**
  String get serverNeedsUpdatingMessage;

  /// No description provided for @appNeedsUpdatingMessage.
  ///
  /// In en, this message translates to:
  /// **'This app is too old to sync with your Anchor server. Update the app to continue.'**
  String get appNeedsUpdatingMessage;

  /// No description provided for @syncWarningNotesStay.
  ///
  /// In en, this message translates to:
  /// **'Your notes stay available on this device in the meantime.'**
  String get syncWarningNotesStay;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @connectAnyway.
  ///
  /// In en, this message translates to:
  /// **'Connect anyway'**
  String get connectAnyway;

  /// No description provided for @serverVersionMismatch.
  ///
  /// In en, this message translates to:
  /// **'Anchor v{version}. {reason}'**
  String serverVersionMismatch(String version, String reason);

  /// No description provided for @syncPausedIncompatible.
  ///
  /// In en, this message translates to:
  /// **'Sync paused, versions incompatible'**
  String get syncPausedIncompatible;

  /// No description provided for @displayDensity.
  ///
  /// In en, this message translates to:
  /// **'Display density'**
  String get displayDensity;

  /// No description provided for @densityStandard.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get densityStandard;

  /// No description provided for @densityCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get densityCompact;

  /// No description provided for @densityStandardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'More breathing room'**
  String get densityStandardSubtitle;

  /// No description provided for @densityCompactSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Fit more on screen'**
  String get densityCompactSubtitle;
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
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
