import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Atakan'**
  String get appTitle;

  /// No description provided for @apiConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'API Settings'**
  String get apiConfigTitle;

  /// No description provided for @apiBaseUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'API Base URL'**
  String get apiBaseUrlLabel;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @invalidUrl.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get invalidUrl;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @adminGateTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Access'**
  String get adminGateTitle;

  /// No description provided for @adminUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin username'**
  String get adminUsernameLabel;

  /// No description provided for @adminPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin password'**
  String get adminPasswordLabel;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @setupAdminPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set admin password'**
  String get setupAdminPasswordTitle;

  /// No description provided for @setupAdminPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Create a password to protect the app'**
  String get setupAdminPasswordHint;

  /// No description provided for @setupAdminUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Create an admin username'**
  String get setupAdminUsernameHint;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password is too short'**
  String get passwordTooShort;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid credentials'**
  String get invalidCredentials;

  /// No description provided for @adminAlreadySet.
  ///
  /// In en, this message translates to:
  /// **'Admin password is already set'**
  String get adminAlreadySet;

  /// No description provided for @adminNotSet.
  ///
  /// In en, this message translates to:
  /// **'Admin password is not set'**
  String get adminNotSet;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @customersShortcut.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersShortcut;

  /// No description provided for @hostingsShortcut.
  ///
  /// In en, this message translates to:
  /// **'Hosting'**
  String get hostingsShortcut;

  /// No description provided for @domainsShortcut.
  ///
  /// In en, this message translates to:
  /// **'Domains'**
  String get domainsShortcut;

  /// No description provided for @sslsShortcut.
  ///
  /// In en, this message translates to:
  /// **'SSL'**
  String get sslsShortcut;

  /// No description provided for @hostingsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Hosting services'**
  String get hostingsListTitle;

  /// No description provided for @domainsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Domain registration'**
  String get domainsListTitle;

  /// No description provided for @sslsListTitle.
  ///
  /// In en, this message translates to:
  /// **'SSL service'**
  String get sslsListTitle;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get filterActive;

  /// No description provided for @filterPassive.
  ///
  /// In en, this message translates to:
  /// **'Passive'**
  String get filterPassive;

  /// No description provided for @expiredOnly.
  ///
  /// In en, this message translates to:
  /// **'Show expired only'**
  String get expiredOnly;

  /// No description provided for @domainName.
  ///
  /// In en, this message translates to:
  /// **'Domain name'**
  String get domainName;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get startDate;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// No description provided for @expiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expiredLabel;

  /// No description provided for @todayLabel.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayLabel;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeTitle;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// No description provided for @sortByCompany.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get sortByCompany;

  /// No description provided for @sortByCustomerNo.
  ///
  /// In en, this message translates to:
  /// **'Customer No'**
  String get sortByCustomerNo;

  /// No description provided for @sortByRenewals.
  ///
  /// In en, this message translates to:
  /// **'Renewals'**
  String get sortByRenewals;

  /// No description provided for @ascending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @customersTitle.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customersTitle;

  /// No description provided for @customerNo.
  ///
  /// In en, this message translates to:
  /// **'Customer No'**
  String get customerNo;

  /// No description provided for @nameSurname.
  ///
  /// In en, this message translates to:
  /// **'Name Surname'**
  String get nameSurname;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @renewalCount.
  ///
  /// In en, this message translates to:
  /// **'Renewal count'**
  String get renewalCount;

  /// No description provided for @servicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get servicesTitle;

  /// No description provided for @domainsTitle.
  ///
  /// In en, this message translates to:
  /// **'Domains'**
  String get domainsTitle;

  /// No description provided for @hostingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hosting services'**
  String get hostingsTitle;

  /// No description provided for @sslsTitle.
  ///
  /// In en, this message translates to:
  /// **'SSL services'**
  String get sslsTitle;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusPassive.
  ///
  /// In en, this message translates to:
  /// **'Passive'**
  String get statusPassive;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid amount'**
  String get paidAmount;

  /// No description provided for @renewalDates.
  ///
  /// In en, this message translates to:
  /// **'Renewal dates'**
  String get renewalDates;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @ftpUsername.
  ///
  /// In en, this message translates to:
  /// **'FTP username'**
  String get ftpUsername;

  /// No description provided for @ftpPassword.
  ///
  /// In en, this message translates to:
  /// **'FTP password'**
  String get ftpPassword;

  /// No description provided for @urlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get urlLabel;

  /// No description provided for @smtpTitle.
  ///
  /// In en, this message translates to:
  /// **'SMTP Settings'**
  String get smtpTitle;

  /// No description provided for @smtpHost.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get smtpHost;

  /// No description provided for @smtpPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get smtpPort;

  /// No description provided for @smtpSecure.
  ///
  /// In en, this message translates to:
  /// **'SSL/TLS'**
  String get smtpSecure;

  /// No description provided for @smtpUsername.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get smtpUsername;

  /// No description provided for @smtpPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get smtpPassword;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @notImplementedYet.
  ///
  /// In en, this message translates to:
  /// **'Not implemented yet'**
  String get notImplementedYet;

  /// No description provided for @expiringServicesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiring Services'**
  String get expiringServicesTitle;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageTurkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancelDelete.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelDelete;

  /// No description provided for @deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get deleteConfirm;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @taxOffice.
  ///
  /// In en, this message translates to:
  /// **'Tax Office'**
  String get taxOffice;

  /// No description provided for @taxNo.
  ///
  /// In en, this message translates to:
  /// **'Tax No'**
  String get taxNo;

  /// No description provided for @registrationDate.
  ///
  /// In en, this message translates to:
  /// **'Registration Date'**
  String get registrationDate;

  /// No description provided for @customerPassword.
  ///
  /// In en, this message translates to:
  /// **'Customer Password'**
  String get customerPassword;

  /// No description provided for @ns1.
  ///
  /// In en, this message translates to:
  /// **'NS1'**
  String get ns1;

  /// No description provided for @ns2.
  ///
  /// In en, this message translates to:
  /// **'NS2'**
  String get ns2;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @passive.
  ///
  /// In en, this message translates to:
  /// **'Passive'**
  String get passive;

  /// No description provided for @email1.
  ///
  /// In en, this message translates to:
  /// **'Email 1'**
  String get email1;

  /// No description provided for @email2.
  ///
  /// In en, this message translates to:
  /// **'Email 2'**
  String get email2;

  /// No description provided for @email3.
  ///
  /// In en, this message translates to:
  /// **'Email 3'**
  String get email3;

  /// No description provided for @phone1.
  ///
  /// In en, this message translates to:
  /// **'Phone 1'**
  String get phone1;

  /// No description provided for @phone2.
  ///
  /// In en, this message translates to:
  /// **'Phone 2'**
  String get phone2;

  /// No description provided for @generatePassword.
  ///
  /// In en, this message translates to:
  /// **'Generate Password'**
  String get generatePassword;

  /// No description provided for @customerPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to auto-generate'**
  String get customerPasswordHint;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get invalidEmail;

  /// No description provided for @invalidDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get invalidDate;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @customerAdded.
  ///
  /// In en, this message translates to:
  /// **'Customer added'**
  String get customerAdded;

  /// No description provided for @customerUpdated.
  ///
  /// In en, this message translates to:
  /// **'Customer updated'**
  String get customerUpdated;

  /// No description provided for @customerDeleted.
  ///
  /// In en, this message translates to:
  /// **'Customer deleted'**
  String get customerDeleted;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get newCustomer;

  /// No description provided for @editCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get editCustomer;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @newService.
  ///
  /// In en, this message translates to:
  /// **'New Service'**
  String get newService;

  /// No description provided for @editService.
  ///
  /// In en, this message translates to:
  /// **'Edit Service'**
  String get editService;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomer;

  /// No description provided for @customerRequired.
  ///
  /// In en, this message translates to:
  /// **'Customer selection is required'**
  String get customerRequired;

  /// No description provided for @serviceAdded.
  ///
  /// In en, this message translates to:
  /// **'Service added'**
  String get serviceAdded;

  /// No description provided for @serviceUpdated.
  ///
  /// In en, this message translates to:
  /// **'Service updated'**
  String get serviceUpdated;

  /// No description provided for @serviceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Service deleted'**
  String get serviceDeleted;

  /// No description provided for @newHosting.
  ///
  /// In en, this message translates to:
  /// **'New Hosting'**
  String get newHosting;

  /// No description provided for @newDomain.
  ///
  /// In en, this message translates to:
  /// **'New Domain'**
  String get newDomain;

  /// No description provided for @newSsl.
  ///
  /// In en, this message translates to:
  /// **'New SSL'**
  String get newSsl;

  /// No description provided for @editHosting.
  ///
  /// In en, this message translates to:
  /// **'Edit Hosting'**
  String get editHosting;

  /// No description provided for @editDomain.
  ///
  /// In en, this message translates to:
  /// **'Edit Domain'**
  String get editDomain;

  /// No description provided for @editSsl.
  ///
  /// In en, this message translates to:
  /// **'Edit SSL'**
  String get editSsl;

  /// No description provided for @autoGenerate.
  ///
  /// In en, this message translates to:
  /// **'Auto Generate'**
  String get autoGenerate;

  /// No description provided for @defaultCountry.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get defaultCountry;

  /// No description provided for @exitConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit the application?'**
  String get exitConfirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
