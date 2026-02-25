import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth/auth_providers.dart';
import '../../app/l10n/l10n_ext.dart';
import '../../app/utils/date_format_util.dart';
import '../../app/widgets/app_header.dart';
import '../services/service_type.dart';

enum _DateRange { next1Month, next3Months, next6Months, custom }

enum _ServiceTypeFilter { all, hostings, domains, ssls }

class RenewalTrackingScreen extends ConsumerStatefulWidget {
  const RenewalTrackingScreen({super.key});

  @override
  ConsumerState<RenewalTrackingScreen> createState() => _RenewalTrackingScreenState();
}

class _RenewalTrackingScreenState extends ConsumerState<RenewalTrackingScreen> {
  _DateRange _dateRange = _DateRange.next1Month;
  _ServiceTypeFilter _serviceType = _ServiceTypeFilter.all;
  Future<Map<ServiceType, List<Map<String, dynamic>>>>? _resultsFuture;
  bool _filterHighlight = false;
  bool _isSendingReminders = false;

   late final TextEditingController _hostingEmailTemplateController;
   late final TextEditingController _domainEmailTemplateController;
   late final TextEditingController _sslEmailTemplateController;
   bool _templatesInitialized = false;
   int _selectedTemplateIndex = 0;

  DateTime? _customStart;
  DateTime? _customEnd;

  DateTime get _rangeStart {
    final now = DateTime.now();
    if (_dateRange == _DateRange.custom) {
      return _customStart ?? DateTime(now.year, now.month, now.day);
    }
    return DateTime(now.year, now.month, now.day);
  }
  DateTime get _rangeEnd {
    final now = DateTime.now();
    return switch (_dateRange) {
      _DateRange.next1Month => DateTime(now.year, now.month + 1, now.day),
      _DateRange.next3Months => DateTime(now.year, now.month + 3, now.day),
      _DateRange.next6Months => DateTime(now.year, now.month + 6, now.day),
      _DateRange.custom => (_customEnd ?? _customStart) ??
          DateTime(now.year, now.month + 1, now.day),
    };
  }

  List<ServiceType> get _typesToFetch {
    return switch (_serviceType) {
      _ServiceTypeFilter.all => [ServiceType.hostings, ServiceType.domains, ServiceType.ssls],
      _ServiceTypeFilter.hostings => [ServiceType.hostings],
      _ServiceTypeFilter.domains => [ServiceType.domains],
      _ServiceTypeFilter.ssls => [ServiceType.ssls],
    };
  }

  Future<Map<ServiceType, List<Map<String, dynamic>>>> _loadExpiring() async {
    final api = ref.read(apiClientProvider);
    final start = _rangeStart;
    final end = _rangeEnd;

    final results = <ServiceType, List<Map<String, dynamic>>>{};
    for (final type in _typesToFetch) {
      final res = await api.getJson(
        type.apiCollectionPath,
        queryParameters: {'limit': 500, 'offset': 0},
      );
      final raw = res['data'] as List? ?? res['items'] as List? ?? [];
      final items = raw.map((e) => (e as Map).cast<String, dynamic>()).toList();
      final inRange = items.where((m) {
        final ed = (m['end_date'] ?? '').toString();
        if (ed.isEmpty) return false;
        final dt = parseApi(ed);
        if (dt == null) return false;
        final d = DateTime(dt.year, dt.month, dt.day);
        final s = DateTime(start.year, start.month, start.day);
        final e = DateTime(end.year, end.month, end.day);
        return !d.isBefore(s) && !d.isAfter(e);
      }).toList();
      inRange.sort((a, b) {
        final da = parseApi((a['end_date'] ?? '').toString()) ?? DateTime(0);
        final db = parseApi((b['end_date'] ?? '').toString()) ?? DateTime(0);
        return da.compareTo(db);
      });
      results[type] = inRange;
    }
    return results;
  }

  void _onSearch() {
    setState(() {
      _resultsFuture = _loadExpiring();
    });
  }

  void _onFilterChanged(VoidCallback updateState) {
    setState(() {
      updateState();
      _filterHighlight = true;
    });
    _onSearch();
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) setState(() => _filterHighlight = false);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onSearch());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_templatesInitialized) {
      final l10n = context.l10n;
      _hostingEmailTemplateController =
          TextEditingController(text: l10n.hostingRenewalEmailDefaultBody);
      _domainEmailTemplateController =
          TextEditingController(text: l10n.domainRenewalEmailDefaultBody);
      _sslEmailTemplateController =
          TextEditingController(text: l10n.sslRenewalEmailDefaultBody);
      _templatesInitialized = true;
    }
  }

  @override
  void dispose() {
    _hostingEmailTemplateController.dispose();
    _domainEmailTemplateController.dispose();
    _sslEmailTemplateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppHeader(title: Text(l10n.renewalTrackingTitle)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 600;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 900),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            l10n.renewalTrackingDescription,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          '${l10n.todayLabel}: ${formatForDisplay(DateTime.now())}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _filterHighlight
                            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildDateRangeDropdown(context)),
                                const SizedBox(width: 16),
                                Expanded(child: _buildServiceTypeDropdown(context)),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildDateRangeDropdown(context),
                                const SizedBox(height: 12),
                                _buildServiceTypeDropdown(context),
                              ],
                            ),
                          if (_dateRange == _DateRange.custom) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      _customStart != null
                                          ? formatForDisplay(_customStart!)
                                          : l10n.startDate,
                                    ),
                                    onPressed: () async {
                                      final initial = _customStart ?? DateTime.now();
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: initial,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        _onFilterChanged(() {
                                          final normalized = DateTime(picked.year, picked.month, picked.day);
                                          _customStart = normalized;
                                          if (_customEnd != null && _customEnd!.isBefore(normalized)) {
                                            _customEnd = normalized;
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      _customEnd != null
                                          ? formatForDisplay(_customEnd!)
                                          : l10n.endDate,
                                    ),
                                    onPressed: () async {
                                      final base = _customStart ?? DateTime.now();
                                      final initial = _customEnd ?? base;
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: initial,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2100),
                                      );
                                      if (picked != null) {
                                        _onFilterChanged(() {
                                          final normalized = DateTime(picked.year, picked.month, picked.day);
                                          _customEnd = normalized;
                                          if (_customStart != null &&
                                              _customStart!.isAfter(normalized)) {
                                            _customStart = normalized;
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${formatForDisplay(_rangeStart)} - ${formatForDisplay(_rangeEnd)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  _buildEmailTemplatesSection(context),
                  const SizedBox(height: 24),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: FutureBuilder<Map<ServiceType, List<Map<String, dynamic>>>>(
                        key: ValueKey('$_dateRange$_serviceType'),
                        future: _resultsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(snapshot.error.toString()),
                                    const SizedBox(height: 16),
                                    FilledButton(
                                      onPressed: _onSearch,
                                      child: Text(l10n.retry),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          final data = snapshot.data ?? {};
                          final allEmpty = data.values.every((l) => l.isEmpty);
                          if (allEmpty) {
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  l10n.noServicesExpiringInRange,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildResultsByServiceType(context, data),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FilledButton.icon(
                                  onPressed: _isSendingReminders
                                      ? null
                                      : () => _onSendReminderEmails(context, data),
                                  icon: _isSendingReminders
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.email_outlined),
                                  label: Text(l10n.sendReminderEmailsButton),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateRangeDropdown(BuildContext context) {
    final l10n = context.l10n;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.dateRangeLabel,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_DateRange>(
          value: _dateRange,
          isExpanded: true,
          items: [
            DropdownMenuItem(value: _DateRange.next1Month, child: Text(l10n.dateRangeNext1Month)),
            DropdownMenuItem(value: _DateRange.next3Months, child: Text(l10n.dateRangeNext3Months)),
            DropdownMenuItem(value: _DateRange.next6Months, child: Text(l10n.dateRangeNext6Months)),
            DropdownMenuItem(value: _DateRange.custom, child: Text(l10n.dateRangeCustom)),
          ],
          onChanged: (v) {
            if (v != null) {
              _onFilterChanged(() {
                _dateRange = v;
                if (v == _DateRange.custom && _customStart == null && _customEnd == null) {
                  final now = DateTime.now();
                  _customStart = DateTime(now.year, now.month, now.day);
                  _customEnd = DateTime(now.year, now.month + 1, now.day);
                }
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildServiceTypeDropdown(BuildContext context) {
    final l10n = context.l10n;
    return InputDecorator(
      decoration: InputDecoration(
        labelText: l10n.serviceTypeLabel,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<_ServiceTypeFilter>(
          value: _serviceType,
          isExpanded: true,
          items: [
            DropdownMenuItem(value: _ServiceTypeFilter.all, child: Text(l10n.filterAll)),
            DropdownMenuItem(value: _ServiceTypeFilter.hostings, child: Text(l10n.hostingsListTitle)),
            DropdownMenuItem(value: _ServiceTypeFilter.domains, child: Text(l10n.domainsListTitle)),
            DropdownMenuItem(value: _ServiceTypeFilter.ssls, child: Text(l10n.sslsListTitle)),
          ],
          onChanged: (v) {
            if (v != null) _onFilterChanged(() => _serviceType = v);
          },
        ),
      ),
    );
  }

  Widget _buildResultsByServiceType(
    BuildContext context,
    Map<ServiceType, List<Map<String, dynamic>>> data,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final endDateShort = l10n.endDateShort;

    final typeOrder = [ServiceType.hostings, ServiceType.domains, ServiceType.ssls];
    final entries = typeOrder
        .where((t) => (data[t] ?? []).isNotEmpty)
        .map((t) => MapEntry(t, data[t]!))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: entries.map((entry) {
        final type = entry.key;
        final items = entry.value;
        final title = type.title(context);
        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...items.map((m) {
                final id = (m['id'] ?? '').toString();
                final domainName = (m['domain_name'] ?? '').toString();
                final customerName = (m['customer_name'] ?? '').toString();
                final endDate = toDisplayDate((m['end_date'] ?? '').toString());
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Card(
                    child: ListTile(
                      title: Text(domainName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (customerName.isNotEmpty) Text(customerName),
                          Text('$endDateShort: $endDate'),
                        ],
                      ),
                      onTap: () => context.go('${type.apiCollectionPath}/$id'),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmailTemplatesSection(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final labels = <String>[];
    final controllers = <TextEditingController>[];

    void addHosting() {
      labels.add(l10n.hostingRenewalEmailLabel);
      controllers.add(_hostingEmailTemplateController);
    }

    void addDomain() {
      labels.add(l10n.domainRenewalEmailLabel);
      controllers.add(_domainEmailTemplateController);
    }

    void addSsl() {
      labels.add(l10n.sslRenewalEmailLabel);
      controllers.add(_sslEmailTemplateController);
    }

    switch (_serviceType) {
      case _ServiceTypeFilter.all:
        addHosting();
        addDomain();
        addSsl();
        break;
      case _ServiceTypeFilter.hostings:
        addHosting();
        break;
      case _ServiceTypeFilter.domains:
        addDomain();
        break;
      case _ServiceTypeFilter.ssls:
        addSsl();
        break;
    }

    if (labels.isEmpty) {
      return const SizedBox.shrink();
    }

    final effectiveSelectedIndex =
        _selectedTemplateIndex.clamp(0, labels.length - 1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.renewalEmailTemplatesTitle,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.renewalEmailTemplatesDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 600;
                final editor = _buildTemplateEditor(
                  controllers[effectiveSelectedIndex],
                  theme,
                );
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTemplateSelector(labels, theme),
                      ),
                      const SizedBox(width: 16),
                      Expanded(flex: 5, child: editor),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildTemplateSelector(labels, theme),
                    const SizedBox(height: 12),
                    editor,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateSelector(List<String> labels, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < labels.length; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == labels.length - 1 ? 0 : 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: i == _selectedTemplateIndex
                    ? theme.colorScheme.primary.withValues(alpha: 0.08)
                    : null,
              ),
              onPressed: () {
                setState(() {
                  _selectedTemplateIndex = i;
                });
              },
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(labels[i]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTemplateEditor(
    TextEditingController controller,
    ThemeData theme,
  ) {
    return TextField(
      controller: controller,
      maxLines: 10,
      minLines: 5,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      style: theme.textTheme.bodyMedium,
    );
  }

  Future<void> _onSendReminderEmails(
    BuildContext context,
    Map<ServiceType, List<Map<String, dynamic>>> data,
  ) async {
    if (_isSendingReminders) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    // Hazır listeden yalnızca id ve servis tipini çıkartıyoruz; ekstra istek yok.
    final services = <Map<String, dynamic>>[];
    data.forEach((type, items) {
      for (final m in items) {
        final id = (m['id'] ?? '').toString();
        if (id.isEmpty) continue;
        services.add({
          'id': id,
          'type': switch (type) {
            ServiceType.hostings => 'hosting',
            ServiceType.domains => 'domain',
            ServiceType.ssls => 'ssl',
          },
        });
      }
    });
    if (services.isEmpty) {
      return;
    }

    setState(() {
      _isSendingReminders = true;
    });

    try {
      final api = ref.read(apiClientProvider);
      await api.postJson(
        '/renewals/send-reminders',
        data: {
          'start_date': _rangeStart.toIso8601String(),
          'end_date': _rangeEnd.toIso8601String(),
          'services': services,
          'templates': {
            'hosting': _hostingEmailTemplateController.text,
            'domain': _domainEmailTemplateController.text,
            'ssl': _sslEmailTemplateController.text,
          },
        },
      );
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.sendReminderEmailsSuccess)),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.sendReminderEmailsError)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingReminders = false;
        });
      }
    }
  }
}
