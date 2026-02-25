import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/auth/auth_providers.dart';
import '../../app/l10n/l10n_ext.dart';
import '../../app/utils/date_format_util.dart';
import '../../app/widgets/app_header.dart';

final incomesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.getJson('/incomes');
  final list = res['items'];
  if (list == null || list is! List) return [];
  return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
});

final expensesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final res = await api.getJson('/expenses');
  final list = res['items'];
  if (list == null || list is! List) return [];
  return list.map((e) => (e as Map).cast<String, dynamic>()).toList();
});

class IncomeExpenseScreen extends ConsumerWidget {
  const IncomeExpenseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final incomesAsync = ref.watch(incomesProvider);
    final expensesAsync = ref.watch(expensesProvider);

    return Scaffold(
      appBar: AppHeader(
        title: Text(l10n.incomeExpenseTitle),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 900 : double.infinity),
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(incomesProvider);
                  ref.invalidate(expensesProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _Section(
                      title: l10n.incomesTitle,
                      totalLabel: l10n.totalIncome,
                      addLabel: l10n.addIncome,
                      async: incomesAsync,
                      isIncome: true,
                      onAdd: () => _openAddDialog(context, ref, true, null),
                      onRefresh: () {
                        ref.invalidate(incomesProvider);
                      },
                    ),
                    const SizedBox(height: 24),
                    _Section(
                      title: l10n.expensesTitle,
                      totalLabel: l10n.totalExpense,
                      addLabel: l10n.addExpense,
                      async: expensesAsync,
                      isIncome: false,
                      onAdd: () => _openAddDialog(context, ref, false, null),
                      onRefresh: () {
                        ref.invalidate(expensesProvider);
                      },
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

  static void _openAddDialog(BuildContext context, WidgetRef ref, bool isIncome, [VoidCallback? onSaved]) {
    final l10n = context.l10n;
    final dateController = TextEditingController(text: formatForDisplay(DateTime.now()));
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isIncome ? l10n.addIncome : l10n.addExpense),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: l10n.selectDate,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          dateController.text = formatForDisplay(picked);
                        }
                      },
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                    if (parseDisplay(v) == null) return l10n.invalidDate;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: l10n.description),
                  maxLines: 2,
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: l10n.amount),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                    if (double.tryParse(v.replaceAll(',', '.')) == null) return l10n.fieldRequired;
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final dateStr = displayStringToApi(dateController.text.trim());
              if (dateStr.isEmpty) return;
              final amount = double.tryParse(amountController.text.trim().replaceAll(',', '.')) ?? 0;
              final api = ref.read(apiClientProvider);
              try {
                final path = isIncome ? '/incomes' : '/expenses';
                await api.postJson(path, data: {
                  'date': dateStr,
                  'description': descriptionController.text.trim(),
                  'amount': amount,
                });
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ref.invalidate(isIncome ? incomesProvider : expensesProvider);
                  onSaved?.call();
                }
              } catch (_) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(l10n.serverError)));
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  /// Shared helpers for add/edit dialogs used by [IncomeListScreen] and [ExpenseListScreen].
  static void openAddIncomeDialog(BuildContext context, WidgetRef ref, [VoidCallback? onSaved]) {
    _openAddDialog(context, ref, true, onSaved);
  }

  static void openAddExpenseDialog(BuildContext context, WidgetRef ref, [VoidCallback? onSaved]) {
    _openAddDialog(context, ref, false, onSaved);
  }

  static void openEditIncomeDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> item, [
    VoidCallback? onSaved,
  ]) {
    _openEditDialog(context, ref, true, item, onSaved);
  }

  static void openEditExpenseDialog(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> item, [
    VoidCallback? onSaved,
  ]) {
    _openEditDialog(context, ref, false, item, onSaved);
  }

  static void _openEditDialog(
    BuildContext context,
    WidgetRef ref,
    bool isIncome,
    Map<String, dynamic> item,
    VoidCallback? onSaved,
  ) {
    final l10n = context.l10n;
    final dateStr = (item['date'] ?? '').toString();
    final initialDate = parseApi(dateStr) ?? DateTime.now();
    final dateController = TextEditingController(text: formatForDisplay(initialDate));
    final descriptionController = TextEditingController(text: (item['description'] ?? '').toString());
    final amountController = TextEditingController(text: (item['amount'] ?? '').toString());
    final formKey = GlobalKey<FormState>();
    final id = (item['id'] ?? item['_id'] ?? '').toString();
    if (id.isEmpty) return;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isIncome ? l10n.edit : l10n.edit),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: l10n.selectDate,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: initialDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          dateController.text = formatForDisplay(picked);
                        }
                      },
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                    if (parseDisplay(v) == null) return l10n.invalidDate;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: l10n.description),
                  maxLines: 2,
                  validator: (v) => (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: l10n.amount),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return l10n.fieldRequired;
                    if (double.tryParse(v.replaceAll(',', '.')) == null) return l10n.fieldRequired;
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final apiDateStr = displayStringToApi(dateController.text.trim());
              if (apiDateStr.isEmpty) return;
              final amount = double.tryParse(amountController.text.trim().replaceAll(',', '.')) ?? 0;
              final api = ref.read(apiClientProvider);
              try {
                final path = isIncome ? '/incomes/$id' : '/expenses/$id';
                await api.putJson(path, data: {
                  'date': apiDateStr,
                  'description': descriptionController.text.trim(),
                  'amount': amount,
                });
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ref.invalidate(isIncome ? incomesProvider : expensesProvider);
                  onSaved?.call();
                }
              } catch (_) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(l10n.serverError)));
                }
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.totalLabel,
    required this.addLabel,
    required this.async,
    required this.isIncome,
    required this.onAdd,
    required this.onRefresh,
  });

  final String title;
  final String totalLabel;
  final String addLabel;
  final AsyncValue<List<Map<String, dynamic>>> async;
  final bool isIncome;
  final VoidCallback onAdd;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return async.when(
      data: (items) {
        final total = items.fold<double>(
          0,
          (sum, e) => sum + (double.tryParse((e['amount'] ?? 0).toString()) ?? 0),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                ),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add, size: 20),
                  label: Text(addLabel),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$totalLabel: ${total.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(child: Text(l10n.noData)),
              )
            else
              ...items.map(
                (e) => Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    title: Text((e['description'] ?? '').toString()),
                    subtitle: Text(toDisplayDate((e['date'] ?? '').toString())),
                    trailing: Text(
                      (e['amount'] ?? 0).toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isIncome ? Colors.green.shade700 : Colors.red.shade700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
      error: (e, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.serverError),
          TextButton(onPressed: onRefresh, child: Text(l10n.retry)),
        ],
      ),
    );
  }
}
