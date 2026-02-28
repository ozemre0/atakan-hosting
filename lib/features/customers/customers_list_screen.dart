import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth/auth_providers.dart';
import '../../app/l10n/l10n_ext.dart';
import '../../app/widgets/app_header.dart';

class CustomersListScreen extends ConsumerStatefulWidget {
  const CustomersListScreen({super.key});

  @override
  ConsumerState<CustomersListScreen> createState() => _CustomersListScreenState();
}

enum _CustomerSort { name, company, customerNo, renewals }

class _CustomersListScreenState extends ConsumerState<CustomersListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  _CustomerSort _sort = _CustomerSort.name;
  bool _desc = false;

  Future<Map<String, dynamic>>? _listFuture;
  ({String q, String sort, bool desc})? _listFutureParams;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _loadCustomers() {
    final q = _searchController.text.trim();
    final sort = _sortKey();
    final desc = _desc;
    if (_listFuture != null &&
        _listFutureParams != null &&
        _listFutureParams!.q == q &&
        _listFutureParams!.sort == sort &&
        _listFutureParams!.desc == desc) {
      return _listFuture!;
    }
    _listFutureParams = (q: q, sort: sort, desc: desc);
    final api = ref.read(apiClientProvider);
    _listFuture = api.getJson(
      '/customers',
      queryParameters: {
        'q': q,
        'sort': sort,
        'dir': desc ? 'desc' : 'asc',
        'limit': 50,
        'offset': 0,
      },
    );
    return _listFuture!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: Text(context.l10n.customersTitle),
        actions: [
          IconButton(
            tooltip: context.l10n.add,
            onPressed: () => context.go('/customers/new'),
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
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
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
                    Expanded(
                      child: FutureBuilder<Map<String, dynamic>>(
                        future: _loadCustomers(),
                        builder: (context, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snap.hasError) {
                            return Center(child: Text(context.l10n.serverError));
                          }

                          final data = snap.data ?? const <String, dynamic>{};
                          final items = (data['items'] as List?)?.cast<Map>() ?? const [];
                          final total = data['total'] as int? ?? data['count'] as int? ?? items.length;

                          if (items.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('${context.l10n.totalCustomersCountLabel}: 0'),
                                  const SizedBox(height: 16),
                                  Text(context.l10n.noData),
                                ],
                              ),
                            );
                          }

                          return CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    '${context.l10n.totalCustomersCountLabel}: $total',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, i) {
                                    final m = items[i].cast<String, dynamic>();
                                    final id = (m['id'] ?? '').toString();
                                    final name = ((m['full_name'] ?? '') as String).trim();
                                    final company = ((m['company'] ?? '') as String).trim();
                                    final renewals = (m['total_renewals'] ?? '0').toString();
                                    final displayTitle = name.isEmpty ? company : name;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Card(
                                        child: ListTile(
                                          leading: SizedBox(
                                            width: 28,
                                            child: Text(
                                              '${i + 1}',
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                            ),
                                          ),
                                          onTap: () => context.go('/customers/$id'),
                                          title: Text(displayTitle),
                                          subtitle: (name.isEmpty || company.isEmpty)
                                              ? null
                                              : Text(
                                                  company,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  softWrap: false,
                                                ),
                                          trailing: Text(
                                            context.l10n.renewalCountShortWithValue(renewals),
                                            textAlign: TextAlign.right,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: items.length,
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

  String _sortKey() {
    return switch (_sort) {
      _CustomerSort.name => 'name',
      _CustomerSort.company => 'company',
      _CustomerSort.customerNo => 'customer_no',
      _CustomerSort.renewals => 'renewals',
    };
  }

  Future<void> _openSortMenu(BuildContext context) async {
    final res = await showModalBottomSheet<_SortResult>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(title: Text(context.l10n.sort), dense: true),
                DropdownButtonFormField<_CustomerSort>(
                  initialValue: _sort,
                  decoration: InputDecoration(labelText: context.l10n.sort),
                  items: [
                    DropdownMenuItem(value: _CustomerSort.name, child: Text(context.l10n.sortByName)),
                    DropdownMenuItem(value: _CustomerSort.company, child: Text(context.l10n.sortByCompany)),
                    DropdownMenuItem(value: _CustomerSort.customerNo, child: Text(context.l10n.sortByCustomerNo)),
                    DropdownMenuItem(value: _CustomerSort.renewals, child: Text(context.l10n.sortByRenewals)),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    Navigator.pop(context, _SortResult(v, _desc));
                  },
                ),
                const Divider(),
                SwitchListTile(
                  value: _desc,
                  onChanged: (v) => Navigator.pop(context, _SortResult(_sort, v)),
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

class _SortResult {
  const _SortResult(this.sort, this.desc);
  final _CustomerSort sort;
  final bool desc;
}


