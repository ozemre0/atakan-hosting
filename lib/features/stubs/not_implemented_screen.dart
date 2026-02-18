import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/l10n_ext.dart';
import '../../app/widgets/app_header.dart';

class NotImplementedScreen extends ConsumerWidget {
  const NotImplementedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppHeader(title: Text(context.l10n.appTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(context.l10n.notImplementedYet),
        ),
      ),
    );
  }
}


