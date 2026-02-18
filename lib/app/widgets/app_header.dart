import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n_ext.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.actions,
  });

  final Widget title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateText = DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(now);

    return AppBar(
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FlutterLogo(size: 22),
          const SizedBox(width: 8),
          Flexible(child: title),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            child: Text(
              '${context.l10n.todayLabel}: $dateText',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
        ),
        ...?actions,
      ],
    );
  }
}


