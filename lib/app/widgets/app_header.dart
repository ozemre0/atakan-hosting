import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.title,
    this.actions,
  });

  final Widget? title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: Icon(Icons.lock_outline, size: 22, color: Theme.of(context).iconTheme.color),
      title: Image.asset(
        'assets/images/cp_logo.webp',
        height: 28,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 28),
      ),
      actions: [...?actions],
    );
  }
}


