import 'package:flutter/widgets.dart';

import '../../app/l10n/l10n_ext.dart';

enum ServiceType {
  hostings,
  domains,
  ssls,
}

extension ServiceTypeX on ServiceType {
  String get apiCollectionPath => switch (this) {
        ServiceType.hostings => '/hostings',
        ServiceType.domains => '/domains',
        ServiceType.ssls => '/ssls',
      };

  String title(BuildContext context) => switch (this) {
        ServiceType.hostings => context.l10n.hostingsListTitle,
        ServiceType.domains => context.l10n.domainsListTitle,
        ServiceType.ssls => context.l10n.sslsListTitle,
      };
}


