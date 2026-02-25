import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth/auth_providers.dart';
import '../../app/l10n/l10n_ext.dart';
import '../../app/utils/date_format_util.dart';
import '../../app/widgets/app_header.dart';
import 'income_expense_screen.dart';

enum _DateRange { last1Month, last3Months, last6Months, last1Year }

extension on _DateRange {
  int get months => switch (this) {
        _DateRange.last1Month => 1,
        _DateRange.last3Months => 3,
        _DateRange.last6Months => 6,
        _DateRange.last1Year => 12,
      };
}

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  final _searchController = TextEditingController();
  _DateRange _dateRange = _DateRange.last3Months;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filter(
    List<Map<String, dynamic>> items,
    String query,
    _DateRange range,
  ) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - range.months, now.day);
    final filtered = items.where((e) {
      final dateStr = (e['date'] ?? '').toString();
      final dt = parseApi(dateStr);
      if (dt != null && dt.isBefore(start)) return false;
      final desc = ((e['description'] ?? '') as String).toLowerCase();
      if (query.trim().isEmpty) return true;
      return desc.contains(query.trim().toLowerCase());
    }).toList();
    filtered.sort((a, b) {
      final da = parseApi((a['date'] ?? '').toString());
      final db = parseApi((b['date'] ?? '').toString());
      if (da == null || db == null) return 0;
      return db.compareTo(da);
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final async = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppHeader(
        title: Text(l10n.expensesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _openAddDialog(context, ref),
          ),
        ],
      ),
      body: async.when(
        data: (allItems) {
          final items = _filter(allItems, _searchController.text, _dateRange);
          final total = items.fold<double>(
            0,
            (sum, e) => sum + (double.tryParse((e['amount'] ?? 0).toString()) ?? 0),
          );
          final now = DateTime.now();
          final start = DateTime(now.year, now.month - _dateRange.months, now.day);
          final rangeText = '${formatForDisplay(start)} - ${formatForDisplay(now)}';

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 900 : double.infinity),
                  child: RefreshIndicator(
                    onRefresh: () async => ref.invalidate(expensesProvider),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: l10n.search,
                            prefixIcon: const Icon(Icons.search),
                            border: const UnderlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.dateRangeLabel,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<_DateRange>(
                          value: _dateRange,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(value: _DateRange.last1Month, child: Text(l10n.dateRangeLast1Month)),
                            DropdownMenuItem(value: _DateRange.last3Months, child: Text(l10n.dateRangeLast3Months)),
                            DropdownMenuItem(value: _DateRange.last6Months, child: Text(l10n.dateRangeLast6Months)),
                            DropdownMenuItem(value: _DateRange.last1Year, child: Text(l10n.dateRangeLast1Year)),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _dateRange = v);
                          },
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rangeText,
                          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.totalExpense,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '₺${total.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (items.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(l10n.noData),
                            ),
                          )
                        else
                          ...items.map(
                            (e) => _ExpenseItem(
                              description: (e['description'] ?? '').toString(),
                              date: (e['date'] ?? '').toString(),
                              amount: double.tryParse((e['amount'] ?? 0).toString()) ?? 0,
                              onEdit: () => _openEditDialog(context, ref, e),
                              onDelete: () => _deleteExpense(context, ref, e),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.serverError),
              TextButton(
                onPressed: () => ref.invalidate(expensesProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddDialog(BuildContext context, WidgetRef ref) {
    IncomeExpenseScreen.openAddExpenseDialog(context, ref, () => setState(() {}));
  }

  void _openEditDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> item) {
    IncomeExpenseScreen.openEditExpenseDialog(context, ref, item, () => setState(() {}));
  }

  Future<void> _deleteExpense(BuildContext context, WidgetRef ref, Map<String, dynamic> item) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.deleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancelDelete)),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.delete)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final id = (item['id'] ?? item['_id'] ?? '').toString();
    if (id.isEmpty) return;
    try {
      final api = ref.read(apiClientProvider);
      await api.deleteJson('/expenses/$id');
      if (context.mounted) {
        ref.invalidate(expensesProvider);
        setState(() {});
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.serverError)));
      }
    }
  }
}

class _ExpenseItem extends StatelessWidget {
  const _ExpenseItem({
    required this.description,
    required this.date,
    required this.amount,
    required this.onEdit,
    required this.onDelete,
  });

  final String description;
  final String date;
  final double amount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          description,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(toDisplayDate(date), style: theme.textTheme.bodySmall),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₺${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red.shade600,
                fontSize: 15,
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) {
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
