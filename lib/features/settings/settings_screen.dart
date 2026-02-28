import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/api/api_base_url.dart';
import '../../app/auth/auth_providers.dart';
import '../../app/l10n/l10n_ext.dart';
import '../../app/settings/app_settings.dart';
import '../../app/settings/settings_providers.dart';
import '../../app/widgets/app_header.dart';
import '../../app/export/database_export_service.dart';
import '../../app/settings/smtp_defaults.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

enum _DbExportFormat { csv, excel }

enum _DbExportScope { allTables, singleTable }

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

  _DbExportFormat _dbExportFormat = _DbExportFormat.csv;
  _DbExportScope _dbExportScope = _DbExportScope.allTables;
  String _dbExportTableKey = 'customers';
  bool _dbExportLoading = false;

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

  Map<String, String> _dbExportTableLabels(BuildContext context) {
    final l10n = context.l10n;
    return <String, String>{
      'customers': l10n.customersTitle,
      'hostings': l10n.hostingsListTitle,
      'domains': l10n.domainsListTitle,
      'ssls': l10n.sslsListTitle,
      'incomes': l10n.incomesTitle,
      'expenses': l10n.expensesTitle,
    };
  }

  Set<DbExportTable> _selectedExportTables() {
    if (_dbExportScope == _DbExportScope.allTables) {
      return DbExportTable.values.toSet();
    }
    final table = DbExportTableX.fromKey(_dbExportTableKey);
    if (table == null) return <DbExportTable>{};
    return {table};
  }

  Future<void> _onExportDatabase() async {
    final l10n = context.l10n;
    final tables = _selectedExportTables();
    if (tables.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.dbExportNoTableSelected)),
      );
      return;
    }

    setState(() {
      _dbExportLoading = true;
    });

    try {
      final api = ref.read(apiClientProvider);
      final service = DatabaseExportService(api);

      List<String> savedPaths = [];
      switch (_dbExportFormat) {
        case _DbExportFormat.csv:
          savedPaths = await service.exportAsCsv(tables);
          break;
        case _DbExportFormat.excel:
          savedPaths = await service.exportAsExcel(tables);
          break;
      }

      if (!mounted) return;
      final pathLines = savedPaths
          .where((p) => p.trim().isNotEmpty)
          .map((p) => l10n.dbExportSavedToPath(p))
          .toList();
      final message = pathLines.isEmpty
          ? '${l10n.dbExportSuccess}\n${l10n.dbExportSavedToDownloads}'
          : '${l10n.dbExportSuccess}\n${pathLines.join('\n')}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SelectableText(message),
          duration: const Duration(seconds: 8),
        ),
      );
      // Paylaşım sayfasını aç: kullanıcı dosyayı İndirilenler / Dosyalar'a kaydedebilir (app path'e erişemediği için)
      if (savedPaths.isNotEmpty) {
        await Share.shareXFiles(
          savedPaths.map((p) => XFile(p)).toList(),
          text: l10n.dbExportSuccess,
        );
      }
    } catch (e, _) {
      if (!mounted) return;
      final message = e.toString().replaceFirst(RegExp(r'^Exception:?\s*'), '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: SelectableText(l10n.dbExportErrorWithDetail(message)),
          duration: const Duration(seconds: 10),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _dbExportLoading = false;
        });
      }
    }
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
      body: SafeArea(
        child: Center(
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
                context.l10n.dbExportTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.dbExportDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 600;
                  final tableLabels = _dbExportTableLabels(context);

                  final formatDropdown = DropdownButtonFormField<_DbExportFormat>(
                    value: _dbExportFormat,
                    decoration: InputDecoration(
                      labelText: context.l10n.dbExportFormatLabel,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: _DbExportFormat.csv,
                        child: Text(context.l10n.dbExportFormatCsv),
                      ),
                      DropdownMenuItem(
                        value: _DbExportFormat.excel,
                        child: Text(context.l10n.dbExportFormatExcel),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _dbExportFormat = v;
                      });
                    },
                  );
                  final scopeDropdown = DropdownButtonFormField<_DbExportScope>(
                    value: _dbExportScope,
                    decoration: InputDecoration(
                      labelText: context.l10n.dbExportScopeLabel,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: _DbExportScope.allTables,
                        child: Text(context.l10n.dbExportScopeAllTables),
                      ),
                      DropdownMenuItem(
                        value: _DbExportScope.singleTable,
                        child: Text(context.l10n.dbExportScopeSingleTable),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _dbExportScope = v;
                      });
                    },
                  );
                  final tableDropdown = DropdownButtonFormField<String>(
                    value: _dbExportTableKey,
                    decoration: InputDecoration(
                      labelText: context.l10n.dbExportTableLabel,
                    ),
                    items: tableLabels.entries
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e.key,
                            child: Text(e.value),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _dbExportTableKey = v;
                      });
                    },
                  );

                  if (isWide) {
                    return Row(
                      children: [
                        Flexible(child: formatDropdown),
                        const SizedBox(width: 12, height: 12),
                        Flexible(child: scopeDropdown),
                        if (_dbExportScope == _DbExportScope.singleTable)
                          const SizedBox(width: 12, height: 12),
                        if (_dbExportScope == _DbExportScope.singleTable)
                          Flexible(child: tableDropdown),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      formatDropdown,
                      const SizedBox(height: 12),
                      scopeDropdown,
                      if (_dbExportScope == _DbExportScope.singleTable) ...[
                        const SizedBox(height: 12),
                        tableDropdown,
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _dbExportLoading ? null : _onExportDatabase,
                  icon: _dbExportLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.download),
                  label: Text(
                    _dbExportLoading
                        ? context.l10n.dbExportInProgress
                        : context.l10n.dbExportButtonLabel,
                  ),
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
      ),
    );
  }
}


