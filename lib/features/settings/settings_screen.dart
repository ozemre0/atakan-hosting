import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/api/api_base_url.dart';
import '../../app/auth/auth_providers.dart';
import '../../app/l10n/l10n_ext.dart';
import '../../app/settings/app_settings.dart';
import '../../app/settings/settings_providers.dart';
import '../../app/widgets/app_header.dart';
import '../../app/settings/smtp_defaults.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _apiController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _adminUsernameController = TextEditingController();
  final _adminOldPasswordController = TextEditingController();
  final _adminNewPasswordController = TextEditingController();
  final _adminPasswordFormKey = GlobalKey<FormState>();
  bool _adminOldPasswordVisible = false;
  bool _adminNewPasswordVisible = false;
  bool _adminPasswordChangeLoading = false;

  final _smtpHostController = TextEditingController();
  final _smtpPortController = TextEditingController();
  final _smtpUsernameController = TextEditingController();
  final _smtpPasswordController = TextEditingController();
  bool _smtpSecure = false;
  bool _smtpPasswordVisible = false;
  bool _smtpLoading = false;

  @override
  void dispose() {
    _apiController.dispose();
    _adminUsernameController.dispose();
    _adminOldPasswordController.dispose();
    _adminNewPasswordController.dispose();
    _smtpHostController.dispose();
    _smtpPortController.dispose();
    _smtpUsernameController.dispose();
    _smtpPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitAdminPasswordChange() async {
    if (!_adminPasswordFormKey.currentState!.validate()) return;
    setState(() => _adminPasswordChangeLoading = true);
    try {
      final api = ref.read(apiClientProvider);
      final res = await api.postJson(
        '/auth/change-password',
        data: {
          'username': _adminUsernameController.text.trim(),
          'oldPassword': _adminOldPasswordController.text.trim(),
          'newPassword': _adminNewPasswordController.text.trim(),
        },
      );
      if (!mounted) return;
      if (res['ok'] == true) {
        _adminOldPasswordController.clear();
        _adminNewPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.adminPasswordChangeSuccess)),
        );
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (res['error'] ?? context.l10n.adminPasswordChangeError).toString(),
          ),
        ),
      );
    } on DioException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.adminPasswordChangeError)),
        );
      }
    } finally {
      if (mounted) setState(() => _adminPasswordChangeLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final settingsNotifier = ref.read(settingsControllerProvider.notifier);
    final api = ref.watch(apiClientProvider);

    if (_apiController.text.isEmpty && settings.apiBaseUrl.isNotEmpty) {
      _apiController.text = settings.apiBaseUrl;
    }

    if (_smtpHostController.text.isEmpty &&
        _smtpPortController.text.isEmpty &&
        _smtpUsernameController.text.isEmpty &&
        _smtpPasswordController.text.isEmpty) {
      _smtpHostController.text = defaultSmtpHost;
      _smtpPortController.text = defaultSmtpPort.toString();
      _smtpSecure = defaultSmtpSecure;
      _smtpUsernameController.text = defaultSmtpUsername;
      _smtpPasswordController.text = defaultSmtpPassword;
    }

    return Scaffold(
      appBar: AppHeader(title: Text(context.l10n.settingsTitle)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _apiController,
                  decoration: InputDecoration(
                    labelText: context.l10n.apiBaseUrlLabel,
                  ),
                  validator: (v) {
                    final value = (v ?? '');
                    if (value.trim().isEmpty) return context.l10n.fieldRequired;
                    final normalized = normalizeApiBaseUrl(value);
                    return normalized == null ? context.l10n.invalidUrl : null;
                  },
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    final normalized = normalizeApiBaseUrl(_apiController.text);
                    if (normalized == null) return;
                    await settingsNotifier.setApiBaseUrl(normalized);
                  },
                  child: Text(context.l10n.save),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.themeTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<AppThemeMode>(
                  segments: [
                    ButtonSegment(value: AppThemeMode.system, label: Text(context.l10n.themeSystem)),
                    ButtonSegment(value: AppThemeMode.light, label: Text(context.l10n.themeLight)),
                    ButtonSegment(value: AppThemeMode.dark, label: Text(context.l10n.themeDark)),
                  ],
                  selected: {settings.themeMode},
                  onSelectionChanged: (v) => settingsNotifier.setThemeMode(v.first),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.languageTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'tr', label: Text(context.l10n.languageTurkish)),
                    ButtonSegment(value: 'en', label: Text(context.l10n.languageEnglish)),
                  ],
                  selected: {settings.locale},
                  onSelectionChanged: (v) => settingsNotifier.setLocale(v.first),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                context.l10n.adminPasswordChangeTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Form(
                key: _adminPasswordFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _adminUsernameController,
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
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _adminOldPasswordController,
                      decoration: InputDecoration(
                        labelText: context.l10n.oldPasswordLabel,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _adminOldPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                              () => _adminOldPasswordVisible =
                                  !_adminOldPasswordVisible),
                          tooltip: _adminOldPasswordVisible
                              ? context.l10n.hidePassword
                              : context.l10n.showPassword,
                        ),
                      ),
                      obscureText: !_adminOldPasswordVisible,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return context.l10n.fieldRequired;
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _adminNewPasswordController,
                      decoration: InputDecoration(
                        labelText: context.l10n.newPasswordLabel,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _adminNewPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                              () => _adminNewPasswordVisible =
                                  !_adminNewPasswordVisible),
                          tooltip: _adminNewPasswordVisible
                              ? context.l10n.hidePassword
                              : context.l10n.showPassword,
                        ),
                      ),
                      obscureText: !_adminNewPasswordVisible,
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return context.l10n.fieldRequired;
                        if (value.length < 6) return context.l10n.passwordTooShort;
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton(
                        onPressed: _adminPasswordChangeLoading ? null : _submitAdminPasswordChange,
                        child: Text(context.l10n.changePassword),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.smtpTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: _smtpLoading
                        ? null
                        : () async {
                            setState(() => _smtpLoading = true);
                            try {
                              final res = await api.getJson('/settings/smtp');
                              final smtp = (res['smtp'] as Map?)?.cast<String, dynamic>();
                              if (smtp != null) {
                                _smtpHostController.text = (smtp['host'] ?? '').toString();
                                _smtpPortController.text = (smtp['port'] ?? '').toString();
                                _smtpSecure = (smtp['secure'] == true);
                                _smtpUsernameController.text = (smtp['username'] ?? '').toString();
                                _smtpPasswordController.text = (smtp['password'] ?? '').toString();
                              }
                            } finally {
                              if (mounted) setState(() => _smtpLoading = false);
                            }
                          },
                    tooltip: context.l10n.save,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _smtpHostController,
                decoration: InputDecoration(labelText: context.l10n.smtpHost),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _smtpPortController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: context.l10n.smtpPort),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _smtpSecure,
                      onChanged: (v) => setState(() => _smtpSecure = v),
                      title: Text(context.l10n.smtpSecure),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _smtpUsernameController,
                decoration: InputDecoration(labelText: context.l10n.smtpUsername),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _smtpPasswordController,
                obscureText: !_smtpPasswordVisible,
                decoration: InputDecoration(
                  labelText: context.l10n.smtpPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _smtpPasswordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(
                      () => _smtpPasswordVisible = !_smtpPasswordVisible,
                    ),
                    tooltip: _smtpPasswordVisible
                        ? context.l10n.hidePassword
                        : context.l10n.showPassword,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: _smtpLoading
                      ? null
                      : () async {
                          setState(() => _smtpLoading = true);
                          try {
                            await api.putJson(
                              '/settings/smtp',
                              data: {
                                'host': _smtpHostController.text.trim(),
                                'port': int.tryParse(_smtpPortController.text.trim()) ?? 0,
                                'secure': _smtpSecure,
                                'username': _smtpUsernameController.text.trim(),
                                'password': _smtpPasswordController.text,
                              },
                            );
                          } finally {
                            if (mounted) setState(() => _smtpLoading = false);
                          }
                        },
                  child: Text(context.l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


