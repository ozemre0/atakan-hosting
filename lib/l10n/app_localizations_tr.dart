// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'ComPeople';

  @override
  String get companyName => 'ComPeople';

  @override
  String get showPassword => 'Şifreyi göster';

  @override
  String get hidePassword => 'Şifreyi gizle';

  @override
  String get apiConfigTitle => 'API Ayarları';

  @override
  String get apiBaseUrlLabel => 'API Base URL';

  @override
  String get fieldRequired => 'Bu alan zorunlu';

  @override
  String get invalidUrl => 'Geçersiz URL';

  @override
  String get save => 'Kaydet';

  @override
  String get continueLabel => 'Devam';

  @override
  String get cancel => 'İptal';

  @override
  String get adminGateTitle => 'Admin Girişi';

  @override
  String get adminUsernameLabel => 'Admin kullanıcı adı';

  @override
  String get adminPasswordLabel => 'Admin şifresi';

  @override
  String get login => 'Giriş';

  @override
  String get setupAdminPasswordTitle => 'Admin şifresi oluştur';

  @override
  String get setupAdminPasswordHint => 'Uygulamayı korumak için şifre oluştur';

  @override
  String get setupAdminUsernameHint => 'Admin kullanıcı adını belirle';

  @override
  String get passwordTooShort => 'Şifre çok kısa';

  @override
  String get invalidCredentials => 'Hatalı şifre';

  @override
  String get adminAlreadySet => 'Admin şifresi zaten oluşturulmuş';

  @override
  String get adminNotSet => 'Admin şifresi oluşturulmamış';

  @override
  String get adminPasswordChangeTitle => 'Admin şifresi değiştir';

  @override
  String get oldPasswordLabel => 'Mevcut şifre';

  @override
  String get newPasswordLabel => 'Yeni şifre';

  @override
  String get changePassword => 'Şifreyi değiştir';

  @override
  String get adminPasswordChangeSuccess => 'Admin şifresi güncellendi';

  @override
  String get adminPasswordChangeError => 'Şifre değiştirilemedi';

  @override
  String get serverError => 'Sunucu hatası';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get customersShortcut => 'Müşteriler';

  @override
  String get navLabelHidden => '';

  @override
  String get hostingsShortcut => 'Hosting';

  @override
  String get domainsShortcut => 'Domain';

  @override
  String get sslsShortcut => 'SSL';

  @override
  String get hostingsListTitle => 'Hosting Hizmetleri';

  @override
  String get totalHostingsCountLabel => 'Toplam hosting sayısı';

  @override
  String get totalDomainsCountLabel => 'Toplam domain sayısı';

  @override
  String get totalSslsCountLabel => 'Toplam SSL sayısı';

  @override
  String get domainsListTitle => 'Domain Tescili';

  @override
  String get sslsListTitle => 'SSL Hizmeti';

  @override
  String get filterAll => 'Tümü';

  @override
  String get filterActive => 'Aktif';

  @override
  String get filterPassive => 'Pasif';

  @override
  String get expiredOnly => 'Sadece süresi bitmişler göster';

  @override
  String get domainName => 'Domain adı';

  @override
  String get customer => 'Müşteri';

  @override
  String get status => 'Durum';

  @override
  String get startDate => 'Başlangıç tarihi';

  @override
  String get activeLabel => 'Aktif';

  @override
  String get expiredLabel => 'Süresi Bitmiş';

  @override
  String get todayLabel => 'Bugün';

  @override
  String get themeTitle => 'Tema';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeDark => 'Koyu';

  @override
  String get logout => 'Çıkış';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get search => 'Ara';

  @override
  String get sort => 'Sırala';

  @override
  String get sortByName => 'Ad Soyad';

  @override
  String get sortByCompany => 'Firma';

  @override
  String get sortByCustomerNo => 'Müşteri No';

  @override
  String get sortByRenewals => 'Yenileme';

  @override
  String get ascending => 'Artan';

  @override
  String get descending => 'Azalan';

  @override
  String get customersTitle => 'Müşteriler';

  @override
  String get totalCustomersCountLabel => 'Toplam müşteri sayısı';

  @override
  String get customerNo => 'Müşteri No';

  @override
  String get nameSurname => 'Ad Soyad';

  @override
  String get company => 'Firma';

  @override
  String get renewalCount => 'Yenileme sayısı';

  @override
  String renewalCountShortWithValue(Object count) {
    return 'YS : $count';
  }

  @override
  String get servicesTitle => 'Hizmetler';

  @override
  String get domainsTitle => 'Domainler';

  @override
  String get hostingsTitle => 'Hosting hizmetleri';

  @override
  String get sslsTitle => 'SSL hizmetleri';

  @override
  String get statusActive => 'Aktif';

  @override
  String get statusPassive => 'Pasif';

  @override
  String get endDate => 'Bitiş tarihi';

  @override
  String get endDateShort => 'BT';

  @override
  String get paidAmount => 'Ödenen miktar';

  @override
  String get renewalDates => 'Yenileme tarihleri';

  @override
  String get renewalDatesHint =>
      'GG-AA-YYYY (her satıra bir tarih veya virgülle ayırarak yazabilirsiniz)';

  @override
  String get description => 'Açıklama';

  @override
  String get ftpUsername => 'FTP kullanıcı adı';

  @override
  String get ftpPassword => 'FTP şifresi';

  @override
  String get urlLabel => 'URL';

  @override
  String get smtpTitle => 'SMTP Ayarları';

  @override
  String get smtpHost => 'Sunucu adı';

  @override
  String get smtpPort => 'Port';

  @override
  String get smtpSecure => 'SSL/TLS';

  @override
  String get smtpUsername => 'Kullanıcı adı';

  @override
  String get smtpPassword => 'Şifre';

  @override
  String get noData => 'Veri yok';

  @override
  String get notImplementedYet => 'Henüz eklenmedi';

  @override
  String get expiringServicesTitle => 'Süresi Biten Hizmetler';

  @override
  String get renewalTrackingTitle => 'Yenileme Takibi';

  @override
  String get renewalTrackingDescription =>
      'Seçilen tarih aralığında süresi dolan hizmetleri listele ve hatırlatma e-postaları gönder';

  @override
  String get incomeExpenseTitle => 'Gelir Gider';

  @override
  String get dateRangeLabel => 'Tarih aralığı';

  @override
  String get dateRangeLast1Month => 'Son 1 ay';

  @override
  String get dateRangeLast3Months => 'Son 3 ay';

  @override
  String get dateRangeLast6Months => 'Son 6 ay';

  @override
  String get dateRangeLast1Year => 'Son 1 yıl';

  @override
  String get dateRangeNext1Month => 'Önümüzdeki 1 ay';

  @override
  String get dateRangeNext3Months => 'Önümüzdeki 3 ay';

  @override
  String get dateRangeNext6Months => 'Önümüzdeki 6 ay';

  @override
  String get dateRangeNext1Year => 'Önümüzdeki 1 yıl';

  @override
  String get dateRangeCustom => 'Özel tarih aralığı';

  @override
  String get serviceTypeLabel => 'Hizmet türü';

  @override
  String get noServicesExpiringInRange =>
      'Seçilen tarih aralığında süresi dolan hizmet yok';

  @override
  String get sendReminderEmailsButton => 'Hatırlatma maili gönder';

  @override
  String get sendReminderEmailsSuccess => 'Hatırlatma e-postaları gönderildi';

  @override
  String get sendReminderEmailsError =>
      'Hatırlatma e-postaları gönderilirken bir hata oluştu';

  @override
  String get incomesTitle => 'Gelirler';

  @override
  String get expensesTitle => 'Giderler';

  @override
  String get amount => 'Tutar';

  @override
  String get totalIncome => 'Toplam Gelir';

  @override
  String get totalExpense => 'Toplam Gider';

  @override
  String get addIncome => 'Gelir Ekle';

  @override
  String get addExpense => 'Gider Ekle';

  @override
  String get languageTitle => 'Dil';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'İngilizce';

  @override
  String get add => 'Ekle';

  @override
  String get edit => 'Düzenle';

  @override
  String get delete => 'Sil';

  @override
  String get update => 'Güncelle';

  @override
  String get back => 'Geri';

  @override
  String get close => 'Kapat';

  @override
  String get confirm => 'Onayla';

  @override
  String get cancelDelete => 'İptal';

  @override
  String get deleteConfirm => 'Silmek istediğinize emin misiniz?';

  @override
  String get firstName => 'Ad';

  @override
  String get lastName => 'Soyad';

  @override
  String get email => 'E-posta';

  @override
  String get phone => 'Telefon';

  @override
  String get address => 'Adres';

  @override
  String get city => 'Şehir';

  @override
  String get country => 'Ülke';

  @override
  String get taxOffice => 'Vergi Dairesi';

  @override
  String get taxNo => 'Vergi No';

  @override
  String get registrationDate => 'Kayıt Tarihi';

  @override
  String get customerPassword => 'Müşteri Şifresi';

  @override
  String get ns1 => 'NS1';

  @override
  String get ns2 => 'NS2';

  @override
  String get expired => 'Süresi Bitmiş';

  @override
  String get active => 'Aktif';

  @override
  String get passive => 'Pasif';

  @override
  String get email1 => 'E-posta 1';

  @override
  String get email2 => 'E-posta 2';

  @override
  String get email3 => 'E-posta 3';

  @override
  String get phone1 => 'Telefon 1';

  @override
  String get phone2 => 'Telefon 2';

  @override
  String get generatePassword => 'Şifre Üret';

  @override
  String get customerPasswordHint => 'Boş bırakılırsa otomatik üretilir';

  @override
  String get invalidEmail => 'Geçersiz e-posta adresi';

  @override
  String get invalidDate => 'Geçersiz tarih';

  @override
  String get success => 'Başarılı';

  @override
  String get error => 'Hata';

  @override
  String get customerAdded => 'Müşteri eklendi';

  @override
  String get customerUpdated => 'Müşteri güncellendi';

  @override
  String get customerDeleted => 'Müşteri silindi';

  @override
  String get customerDeleteHasActiveServices =>
      'Bu müşteriye bağlı aktif hizmetler var. Önce bu hizmetleri pasif duruma almalısınız.';

  @override
  String get customerDeleteHasServices =>
      'Bu müşteriye bağlı hizmetler var. Önce tüm bağlı hizmetleri silmelisiniz.';

  @override
  String get selectDate => 'Tarih Seç';

  @override
  String get newCustomer => 'Yeni Müşteri';

  @override
  String get editCustomer => 'Müşteri Düzenle';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get newService => 'Yeni Hizmet';

  @override
  String get editService => 'Hizmet Düzenle';

  @override
  String get selectCustomer => 'Müşteri Seç';

  @override
  String get customerRequired => 'Müşteri seçimi zorunludur';

  @override
  String get serviceAdded => 'Hizmet eklendi';

  @override
  String get serviceUpdated => 'Hizmet güncellendi';

  @override
  String get serviceDeleted => 'Hizmet silindi';

  @override
  String get newHosting => 'Yeni Hosting';

  @override
  String get newDomain => 'Yeni Domain';

  @override
  String get newSsl => 'Yeni SSL';

  @override
  String get editHosting => 'Hosting Düzenle';

  @override
  String get editDomain => 'Domain Düzenle';

  @override
  String get editSsl => 'SSL Düzenle';

  @override
  String get autoGenerate => 'Otomatik Üret';

  @override
  String get defaultCountry => 'Türkiye';

  @override
  String get exitConfirm => 'Uygulamadan çıkmak istediğinize emin misiniz?';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';
}
