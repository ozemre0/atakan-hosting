import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/l10n/l10n_ext.dart';
import '../../app/api/api_base_url.dart';
import '../../app/settings/settings_providers.dart';
import '../../app/widgets/app_header.dart';

class ApiConfigScreen extends ConsumerStatefulWidget {
  const ApiConfigScreen({super.key});

  @override
  ConsumerState<ApiConfigScreen> createState() => _ApiConfigScreenState();
}

class _ApiConfigScreenState extends ConsumerState<ApiConfigScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);

    if (_controller.text.isEmpty && settings.apiBaseUrl.isNotEmpty) {
      _controller.text = settings.apiBaseUrl;
    }

    return Scaffold(
      appBar: AppHeader(title: Text(context.l10n.apiConfigTitle)),
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
                    controller: _controller,
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
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        final normalized = normalizeApiBaseUrl(_controller.text);
                        if (normalized == null) return;
                        await ref.read(settingsControllerProvider.notifier).setApiBaseUrl(normalized);
                      },
                      child: Text(context.l10n.save),
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
}


