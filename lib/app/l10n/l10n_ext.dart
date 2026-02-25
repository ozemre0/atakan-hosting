import 'package:flutter/widgets.dart';
import 'package:atakan/l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension RenewalEmailL10nX on AppLocalizations {
  String get renewalEmailTemplatesTitle =>
      localeName == 'tr' ? 'Hatırlatma e-posta metinleri' : 'Reminder email texts';

  String get renewalEmailTemplatesDescription => localeName == 'tr'
      ? 'Aşağıdaki şablonlar varsayılan olarak kullanılır. Göndermeden önce ihtiyaca göre düzenleyebilirsiniz.'
      : 'The templates below are used by default. You can adjust them before sending.';

  String get hostingRenewalEmailLabel =>
      localeName == 'tr' ? 'Hosting yenileme hatırlatması' : 'Hosting renewal reminder';

  String get domainRenewalEmailLabel =>
      localeName == 'tr' ? 'Domain yenileme hatırlatması' : 'Domain renewal reminder';

  String get sslRenewalEmailLabel =>
      localeName == 'tr' ? 'SSL yenileme hatırlatması' : 'SSL renewal reminder';

  String get hostingRenewalEmailDefaultBody => localeName == 'tr'
      ? '''Sayın {firstName} {lastName},

{hostingName} adresindeki hosting hesabınızın süresi {endDate} tarihinde dolacaktır.
Bu hizmetin süresini uzatmak için web sitemizi ziyaret edebilir, aşağıdaki linke tıklayabilir ya da bizimle temasa geçebilirsiniz.

https://www.compeople.com.tr/product/hosting-hizmeti/

Saygılarımızla,

Com People
Email: destek@compeople.com.tr'''
      : '''Dear {firstName} {lastName},

Your hosting service at {hostingName} will expire on {endDate}.
To extend this service, please visit our website, click the link below or contact us.

https://www.compeople.com.tr/product/hosting-hizmeti/

Best regards,

Com People
Email: destek@compeople.com.tr''';

  String get domainRenewalEmailDefaultBody => localeName == 'tr'
      ? '''Sayın {firstName} {lastName},

{domainName} domain adınızın süresi {endDate} tarihinde dolacaktır.
Bu hizmetin süresini uzatmak için web sitemizi ziyaret edebilir, aşağıdaki linke tıklayabilir ya da bizimle temasa geçebilirsiniz.

https://www.compeople.com.tr/product/domain-adi-tescili/

** İsim tescil yenilemelerinde, 6-15 gün gecikmelerde %25; 16 gün ve daha fazla gecikmelerde %50 gecikme ücreti ilave edilir.
*** Kurtarma süreçleri ve ücretlendirmesi uzantılara göre değişiklik göstermektedir

Saygılarımızla,

Com People
Email: destek@compeople.com.tr'''
      : '''Dear {firstName} {lastName},

Your domain name {domainName} will expire on {endDate}.
To extend this service, please visit our website, click the link below or contact us.

https://www.compeople.com.tr/product/domain-adi-tescili/

** For domain renewals, a 25% late fee is applied for delays of 6–15 days; a 50% late fee is applied for 16 days or more.
*** Recovery processes and pricing may vary depending on the extension.

Best regards,

Com People
Email: destek@compeople.com.tr''';

  String get sslRenewalEmailDefaultBody => localeName == 'tr'
      ? '''Sayın {firstName} {lastName},

{sslName} alan adınıza tanımlı SSL sertifikasının (https:// yönlendirme) süresi {endDate} tarihinde dolacaktır.
Bu hizmetin süresini uzatmak için web sitemizi ziyaret edebilir, aşağıdaki linke tıklayabilir ya da bizimle temasa geçebilirsiniz.

https://www.compeople.com.tr/product/ssl-hizmeti/

Saygılarımızla,

Com People
Email: destek@compeople.com.tr'''
      : '''Dear {firstName} {lastName},

The SSL certificate (https:// redirection) defined for {sslName} will expire on {endDate}.
To extend this service, please visit our website, click the link below or contact us.

https://www.compeople.com.tr/product/ssl-hizmeti/

Best regards,

Com People
Email: destek@compeople.com.tr''';
}

