import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth/auth_providers.dart';
import '../../app/l10n/l10n_ext.dart';
import '../../app/widgets/app_header.dart';

class AdminSetupScreen extends ConsumerStatefulWidget {
  const AdminSetupScreen({super.key});

  @override
  ConsumerState<AdminSetupScreen> createState() => _AdminSetupScreenState();
}

class _AdminSetupScreenState extends ConsumerState<AdminSetupScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: Text(context.l10n.setupAdminPasswordTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.setupAdminPasswordHint,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.adminUsernameLabel,
                      helperText: context.l10n.setupAdminUsernameHint,
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return context.l10n.fieldRequired;
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: context.l10n.adminPasswordLabel,
                    ),
                    obscureText: true,
                    validator: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) return context.l10n.fieldRequired;
                      if (value.length < 6) return context.l10n.passwordTooShort;
                      return null;
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: Text(context.l10n.continueLabel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.postJson(
        '/setup/admin',
        data: {
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      if (!mounted) return;

      if (res['ok'] == true) {
        context.go('/auth/login');
        return;
      }

      final err = (res['error'] ?? '').toString();
      if (err == 'ADMIN_ALREADY_SET') {
        context.go('/auth/login');
        return;
      }

      _showError(context.l10n.serverError);
    } on DioException {
      if (!mounted) return;
      _showError(context.l10n.serverError);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}


