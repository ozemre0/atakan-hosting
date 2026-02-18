import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n_ext.dart';

class BackButtonHandler extends StatefulWidget {
  const BackButtonHandler({
    super.key,
    required this.child,
    this.isRootRoute = false,
  });

  final Widget child;
  final bool isRootRoute;

  @override
  State<BackButtonHandler> createState() => _BackButtonHandlerState();
}

class _BackButtonHandlerState extends State<BackButtonHandler> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _showExitDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.exitConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
            child: Text(context.l10n.no),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
            child: Text(context.l10n.yes),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isRootRoute) {
      return widget.child;
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _showExitDialog();
        }
      },
      child: widget.child,
    );
  }
}

