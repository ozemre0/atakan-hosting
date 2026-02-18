import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth/auth_providers.dart';
import '../../app/l10n/l10n_ext.dart';
import '../../app/widgets/app_header.dart';

class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
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
      appBar: AppHeader(title: Text(context.l10n.adminGateTitle)),
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
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: context.l10n.adminUsernameLabel,
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
                      return null;
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submit,
                      child: Text(context.l10n.login),
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
        '/auth/login',
        data: {
          'username': _usernameController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      );

      if (res['ok'] == true) {
        final token = (res['token'] ?? '').toString();
        await ref.read(authControllerProvider.notifier).setToken(token);
        return;
      }

      final err = (res['error'] ?? '').toString();
      if (!mounted) return;
      if (err == 'ADMIN_NOT_SET') {
        context.go('/auth/setup');
        return;
      }

      _showError(context.l10n.invalidCredentials);
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


