import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth/auth_providers.dart';
import '../../app/l10n/l10n_ext.dart';
import '../../app/widgets/app_header.dart';
import 'service_type.dart';

enum _ServiceSort { domainName, customer, renewalCount, endDate }

enum _ServiceStatusFilter { all, active, passive }

class ServiceListScreen extends ConsumerStatefulWidget {
  const ServiceListScreen({
    super.key,
    required this.type,
    this.expiredOnly = false,
  });

  final ServiceType type;
  final bool expiredOnly;

  @override
  ConsumerState<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends ConsumerState<ServiceListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  _ServiceSort _sort = _ServiceSort.endDate;
  bool _desc = false;
  _ServiceStatusFilter _status = _ServiceStatusFilter.all;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final api = ref.watch(apiClientProvider);
    final title = widget.type.title(context);

    return Scaffold(
      appBar: AppHeader(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: context.l10n.add,
            onPressed: () {
              final path = switch (widget.type) {
                ServiceType.hostings => '/hostings/new',
                ServiceType.domains => '/domains/new',
                ServiceType.ssls => '/ssls/new',
              };
              context.go(path);
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: context.l10n.sort,
            onPressed: () => _openSortMenu(context),
            icon: const Icon(Icons.sort),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final isWide = c.maxWidth >= 900;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        labelText: context.l10n.search,
                      ),
                      onChanged: (_) {
                        _debounce?.cancel();
                        _debounce = Timer(const Duration(milliseconds: 300), () {
                          setState(() {});
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SegmentedButton<_ServiceStatusFilter>(
                          segments: [
                            ButtonSegment(
                              value: _ServiceStatusFilter.all,
                              label: Text(context.l10n.filterAll),
                            ),
                            ButtonSegment(
                              value: _ServiceStatusFilter.active,
                              label: Text(context.l10n.filterActive),
                            ),
                            ButtonSegment(
                              value: _ServiceStatusFilter.passive,
                              label: Text(context.l10n.filterPassive),
                            ),
                          ],
                          selected: {_status},
                          onSelectionChanged: (v) => setState(() => _status = v.first),
                        ),
                        FilterChip(
                          selected: widget.expiredOnly,
                          onSelected: (_) => setState(() {}),
                          label: Text(context.l10n.expiredOnly),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: api.getJson(
                          widget.type.apiCollectionPath,
                          queryParameters: {
                            'q': _searchController.text.trim(),
                            'status': _statusQueryValue(),
                            'sort': _sortQueryValue(),
                            'dir': _desc ? 'desc' : 'asc',
                            // keep requests bounded for performance; increase later with pagination
                            'limit': 200,
                            'offset': 0,
                          },
                        ),
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snap.hasError) {
                            return Center(child: Text(context.l10n.serverError));
                          }

                          final data = snap.data ?? const <String, dynamic>{};
                          final today = (data['today'] ?? '').toString();
                          final itemsRaw = (data['items'] as List?)?.cast<Map>() ?? const [];
                          var items = itemsRaw.map((e) => e.cast<String, dynamic>()).toList();

                          if (widget.expiredOnly && today.isNotEmpty) {
                            items = items.where((m) => (m['is_expired'] == 1) || (m['is_expired'] == true)).toList();
                          }

                          if (items.isEmpty) return Center(child: Text(context.l10n.noData));

                          return ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final m = items[i];
                              final id = (m['id'] ?? '').toString();
                              final domainName = (m['domain_name'] ?? '').toString();
                              final customerName = (m['customer_name'] ?? '').toString();
                              final renewalCount = (m['renewal_count'] ?? 0).toString();
                              final endDate = (m['end_date'] ?? '').toString();
                              final status = (m['status'] ?? 1);
                              final isExpired = (m['is_expired'] == 1) || (m['is_expired'] == true);

                              final bg = _rowBackgroundColor(
                                context: context,
                                status: status,
                                isExpired: isExpired,
                              );

                              return Card(
                                color: bg,
                                child: ListTile(
                                  onTap: () => context.go('${widget.type.apiCollectionPath}/$id'),
                                  title: Text(domainName),
                                  subtitle: Text(customerName),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('${context.l10n.renewalCount}: $renewalCount'),
                                      Text('${context.l10n.endDate}: $endDate'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (!isWide) const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _statusQueryValue() {
    return switch (_status) {
      _ServiceStatusFilter.all => 'all',
      _ServiceStatusFilter.active => 'active',
      _ServiceStatusFilter.passive => 'passive',
    };
  }

  String _sortQueryValue() {
    return switch (_sort) {
      _ServiceSort.domainName => 'domain_name',
      _ServiceSort.customer => 'customer',
      _ServiceSort.renewalCount => 'renewal_count',
      _ServiceSort.endDate => 'end_date',
    };
  }

  Color? _rowBackgroundColor({
    required BuildContext context,
    required Object status,
    required bool isExpired,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isPassive = status == 0 || status == false || status == '0';
    if (isPassive) return Color.alphaBlend(scheme.error.withValues(alpha: 0.14), scheme.surface);
    if (isExpired) return Color.alphaBlend(Colors.orange.withValues(alpha: 0.14), scheme.surface);
    return null;
  }

  Future<void> _openSortMenu(BuildContext context) async {
    final res = await showModalBottomSheet<_ServiceSortResult>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(title: Text(context.l10n.sort), dense: true),
                DropdownButtonFormField<_ServiceSort>(
                  initialValue: _sort,
                  decoration: InputDecoration(labelText: context.l10n.sort),
                  items: [
                    DropdownMenuItem(value: _ServiceSort.domainName, child: Text(context.l10n.domainName)),
                    DropdownMenuItem(value: _ServiceSort.customer, child: Text(context.l10n.customer)),
                    DropdownMenuItem(value: _ServiceSort.renewalCount, child: Text(context.l10n.renewalCount)),
                    DropdownMenuItem(value: _ServiceSort.endDate, child: Text(context.l10n.endDate)),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    Navigator.pop(context, _ServiceSortResult(v, _desc));
                  },
                ),
                const Divider(),
                SwitchListTile(
                  value: _desc,
                  onChanged: (v) => Navigator.pop(context, _ServiceSortResult(_sort, v)),
                  title: Text(_desc ? context.l10n.descending : context.l10n.ascending),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (res == null) return;
    setState(() {
      _sort = res.sort;
      _desc = res.desc;
    });
  }
}

class _ServiceSortResult {
  const _ServiceSortResult(this.sort, this.desc);
  final _ServiceSort sort;
  final bool desc;
}


