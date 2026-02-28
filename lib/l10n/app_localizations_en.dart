// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ComPeople';

  @override
  String get companyName => 'ComPeople';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get apiConfigTitle => 'API Settings';

  @override
  String get apiBaseUrlLabel => 'API Base URL';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidUrl => 'Invalid URL';

  @override
  String get save => 'Save';

  @override
  String get continueLabel => 'Continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get adminGateTitle => 'Admin Access';

  @override
  String get adminUsernameLabel => 'Admin username';

  @override
  String get adminPasswordLabel => 'Admin password';

  @override
  String get login => 'Login';

  @override
  String get setupAdminPasswordTitle => 'Set admin password';

  @override
  String get setupAdminPasswordHint => 'Create a password to protect the app';

  @override
  String get setupAdminUsernameHint => 'Create an admin username';

  @override
  String get passwordTooShort => 'Password is too short';

  @override
  String get invalidCredentials => 'Invalid credentials';

  @override
  String get adminAlreadySet => 'Admin password is already set';

  @override
  String get adminNotSet => 'Admin password is not set';

  @override
  String get adminPasswordChangeTitle => 'Change admin password';

  @override
  String get oldPasswordLabel => 'Current password';

  @override
  String get newPasswordLabel => 'New password';

  @override
  String get changePassword => 'Change password';

  @override
  String get adminPasswordChangeSuccess => 'Admin password updated';

  @override
  String get adminPasswordChangeError => 'Failed to change password';

  @override
  String get serverError => 'Server error';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get customersShortcut => 'Customers';

  @override
  String get navLabelHidden => '';

  @override
  String get hostingsShortcut => 'Hosting';

  @override
  String get domainsShortcut => 'Domains';

  @override
  String get sslsShortcut => 'SSL';

  @override
  String get hostingsListTitle => 'Hosting services';

  @override
  String get totalHostingsCountLabel => 'Total hostings';

  @override
  String get totalDomainsCountLabel => 'Total domains';

  @override
  String get totalSslsCountLabel => 'Total SSL';

  @override
  String get domainsListTitle => 'Domain registration';

  @override
  String get sslsListTitle => 'SSL service';

  @override
  String get filterAll => 'All';

  @override
  String get filterActive => 'Active';

  @override
  String get filterPassive => 'Passive';

  @override
  String get expiredOnly => 'Show only expired';

  @override
  String get domainName => 'Domain name';

  @override
  String get customer => 'Customer';

  @override
  String get status => 'Status';

  @override
  String get startDate => 'Start date';

  @override
  String get activeLabel => 'Active';

  @override
  String get expiredLabel => 'Expired';

  @override
  String get todayLabel => 'Today';

  @override
  String get themeTitle => 'Theme';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get logout => 'Logout';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get search => 'Search';

  @override
  String get sort => 'Sort';

  @override
  String get sortByName => 'Name';

  @override
  String get sortByCompany => 'Company';

  @override
  String get sortByCustomerNo => 'Customer No';

  @override
  String get sortByRenewals => 'Renewals';

  @override
  String get ascending => 'Ascending';

  @override
  String get descending => 'Descending';

  @override
  String get customersTitle => 'Customers';

  @override
  String get totalCustomersCountLabel => 'Total customers';

  @override
  String get customerNo => 'Customer No';

  @override
  String get nameSurname => 'Name Surname';

  @override
  String get company => 'Company';

  @override
  String get renewalCount => 'Renewal count';

  @override
  String renewalCountShortWithValue(Object count) {
    return 'YS : $count';
  }

  @override
  String get servicesTitle => 'Services';

  @override
  String get domainsTitle => 'Domains';

  @override
  String get hostingsTitle => 'Hosting services';

  @override
  String get sslsTitle => 'SSL services';

  @override
  String get statusActive => 'Active';

  @override
  String get statusPassive => 'Passive';

  @override
  String get endDate => 'End date';

  @override
  String get endDateShort => 'ED';

  @override
  String get paidAmount => 'Paid amount';

  @override
  String get renewalDates => 'Renewal dates';

  @override
  String get renewalDatesHint =>
      'DD-MM-YYYY (one date per line or comma-separated)';

  @override
  String get description => 'Description';

  @override
  String get ftpUsername => 'FTP username';

  @override
  String get ftpPassword => 'FTP password';

  @override
  String get urlLabel => 'URL';

  @override
  String get smtpTitle => 'SMTP Settings';

  @override
  String get smtpHost => 'Host';

  @override
  String get smtpPort => 'Port';

  @override
  String get smtpSecure => 'SSL/TLS';

  @override
  String get smtpUsername => 'Username';

  @override
  String get smtpPassword => 'Password';

  @override
  String get noData => 'No data';

  @override
  String get notImplementedYet => 'Not implemented yet';

  @override
  String get expiringServicesTitle => 'Expiring Services';

  @override
  String get renewalTrackingTitle => 'Renewal Tracking';

  @override
  String get renewalTrackingDescription =>
      'List services expiring in the selected date range and send reminder emails';

  @override
  String get incomeExpenseTitle => 'Income & Expense';

  @override
  String get dateRangeLabel => 'Date range';

  @override
  String get dateRangeLast1Month => 'Last 1 month';

  @override
  String get dateRangeLast3Months => 'Last 3 months';

  @override
  String get dateRangeLast6Months => 'Last 6 months';

  @override
  String get dateRangeLast1Year => 'Last 1 year';

  @override
  String get dateRangeNext1Month => 'Next 1 month';

  @override
  String get dateRangeNext3Months => 'Next 3 months';

  @override
  String get dateRangeNext6Months => 'Next 6 months';

  @override
  String get dateRangeNext1Year => 'Next 1 year';

  @override
  String get dateRangeCustom => 'Custom range';

  @override
  String get serviceTypeLabel => 'Service Type';

  @override
  String get noServicesExpiringInRange =>
      'No services expiring in the selected date range';

  @override
  String get sendReminderEmailsButton => 'Send reminder emails';

  @override
  String get sendReminderEmailsSuccess => 'Reminder emails have been sent';

  @override
  String get sendReminderEmailsError =>
      'An error occurred while sending reminder emails';

  @override
  String get renewalEmailPreviewTitle => 'Renewal email';

  @override
  String get renewalEmailCopyButton => 'Copy text';

  @override
  String get incomesTitle => 'Incomes';

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get amount => 'Amount';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpense => 'Total Expense';

  @override
  String get addIncome => 'Add Income';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageTurkish => 'Turkish';

  @override
  String get languageEnglish => 'English';

  @override
  String get add => 'Add';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get update => 'Update';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancelDelete => 'Cancel';

  @override
  String get deleteConfirm => 'Are you sure you want to delete?';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get address => 'Address';

  @override
  String get city => 'City';

  @override
  String get country => 'Country';

  @override
  String get taxOffice => 'Tax Office';

  @override
  String get taxNo => 'Tax No';

  @override
  String get registrationDate => 'Registration Date';

  @override
  String get customerPassword => 'Customer Password';

  @override
  String get ns1 => 'NS1';

  @override
  String get ns2 => 'NS2';

  @override
  String get expired => 'Expired';

  @override
  String get active => 'Active';

  @override
  String get passive => 'Passive';

  @override
  String get email1 => 'Email 1';

  @override
  String get email2 => 'Email 2';

  @override
  String get email3 => 'Email 3';

  @override
  String get phone1 => 'Phone 1';

  @override
  String get phone2 => 'Phone 2';

  @override
  String get generatePassword => 'Generate Password';

  @override
  String get customerPasswordHint => 'Leave empty to auto-generate';

  @override
  String get invalidEmail => 'Invalid email address';

  @override
  String get invalidDate => 'Invalid date';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get customerAdded => 'Customer added';

  @override
  String get customerUpdated => 'Customer updated';

  @override
  String get customerDeleted => 'Customer deleted';

  @override
  String get customerDeleteHasActiveServices =>
      'This customer has active services. Please deactivate those services first.';

  @override
  String get customerDeleteHasServices =>
      'This customer still has related services. Please delete all related services first.';

  @override
  String get selectDate => 'Select Date';

  @override
  String get newCustomer => 'New Customer';

  @override
  String get editCustomer => 'Edit Customer';

  @override
  String get retry => 'Retry';

  @override
  String get newService => 'New Service';

  @override
  String get editService => 'Edit Service';

  @override
  String get selectCustomer => 'Select Customer';

  @override
  String get customerRequired => 'Customer selection is required';

  @override
  String get serviceAdded => 'Service added';

  @override
  String get serviceUpdated => 'Service updated';

  @override
  String get serviceDeleted => 'Service deleted';

  @override
  String get newHosting => 'New Hosting';

  @override
  String get newDomain => 'New Domain';

  @override
  String get newSsl => 'New SSL';

  @override
  String get editHosting => 'Edit Hosting';

  @override
  String get editDomain => 'Edit Domain';

  @override
  String get editSsl => 'Edit SSL';

  @override
  String get autoGenerate => 'Auto Generate';

  @override
  String get defaultCountry => 'Turkey';

  @override
  String get exitConfirm => 'Are you sure you want to exit the application?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';
}
