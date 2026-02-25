import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth/auth_providers.dart';
import '../../app/l10n/l10n_ext.dart';
import '../../app/utils/date_format_util.dart';
import '../../app/settings/app_settings.dart';
import '../../app/settings/settings_providers.dart';
import '../../app/widgets/app_header.dart';

final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return api.getJson('/dashboard');
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final async = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppHeader(
        title: Text(context.l10n.dashboardTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                await ref.read(authControllerProvider.notifier).clear();
                return;
              }
              final notifier = ref.read(settingsControllerProvider.notifier);
              if (value == 'theme_system') await notifier.setThemeMode(AppThemeMode.system);
              if (value == 'theme_light') await notifier.setThemeMode(AppThemeMode.light);
              if (value == 'theme_dark') await notifier.setThemeMode(AppThemeMode.dark);
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'theme_system', child: Text(context.l10n.themeSystem)),
              PopupMenuItem(value: 'theme_light', child: Text(context.l10n.themeLight)),
              PopupMenuItem(value: 'theme_dark', child: Text(context.l10n.themeDark)),
              const PopupMenuDivider(),
              PopupMenuItem(value: 'logout', child: Text(context.l10n.logout)),
            ],
          ),
        ],
      ),
      body: async.when(
        data: (data) {
          final hosting = (data['hosting'] as Map?)?.cast<String, dynamic>() ?? {};
          final domains = (data['domains'] as Map?)?.cast<String, dynamic>() ?? {};
          final ssls = (data['ssls'] as Map?)?.cast<String, dynamic>() ?? {};
          final expired = (data['expired'] as Map?)?.cast<String, dynamic>() ?? {};
          final expiredHostings = (expired['hostings'] as List?) ?? const [];
          final expiredDomains = (expired['domains'] as List?) ?? const [];
          final expiredSsls = (expired['ssls'] as List?) ?? const [];

          return LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth >= 720;
              final l10n = context.l10n;

              final hostingActive = hosting['active']?.toString() ?? '0';
              final hostingExp = hosting['expired']?.toString() ?? '0';
              final domainActive = domains['active']?.toString() ?? '0';
              final domainExp = domains['expired']?.toString() ?? '0';
              final sslActive = ssls['active']?.toString() ?? '0';
              final sslExp = ssls['expired']?.toString() ?? '0';

              final expiredHostingRows = expiredHostings
                  .map((e) => _ExpiredRow.fromMap(e, '/hostings', l10n.hostingsShortcut))
                  .toList();
              final expiredDomainRows = expiredDomains
                  .map((e) => _ExpiredRow.fromMap(e, '/domains', l10n.domainsShortcut))
                  .toList();
              final expiredSslRows = expiredSsls
                  .map((e) => _ExpiredRow.fromMap(e, '/ssls', l10n.sslsShortcut))
                  .toList();

              final theme = Theme.of(context);
              const renewalBlue = Color(0xFF1E65AE);

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 900 : double.infinity),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _ServiceCountCard(
                        label: l10n.hostingsShortcut,
                        active: hostingActive,
                        expired: hostingExp,
                        onTap: () => context.go('/hostings'),
                        onExpTap: () => context.go('/hostings?expiredOnly=1'),
                      ),
                      const SizedBox(height: 8),
                      _ServiceCountCard(
                        label: l10n.domainsShortcut,
                        active: domainActive,
                        expired: domainExp,
                        onTap: () => context.go('/domains'),
                        onExpTap: () => context.go('/domains?expiredOnly=1'),
                      ),
                      const SizedBox(height: 8),
                      _ServiceCountCard(
                        label: l10n.sslsShortcut,
                        active: sslActive,
                        expired: sslExp,
                        onTap: () => context.go('/ssls'),
                        onExpTap: () => context.go('/ssls?expiredOnly=1'),
                      ),
                      const SizedBox(height: 12),
                      Material(
                        color: renewalBlue,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () => context.go('/renewals'),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            child: Row(
                              children: [
                                const Icon(Icons.notifications_active, color: Colors.white, size: 28),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        l10n.renewalTrackingTitle,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.renewalTrackingDescription,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.trending_up, color: Colors.green.shade600, size: 26),
                          title: Text(
                            l10n.incomesTitle,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () => context.go('/incomes'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.trending_down, color: Colors.red.shade600, size: 26),
                          title: Text(
                            l10n.expensesTitle,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                          onTap: () => context.go('/expenses'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.expiringServicesTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _ExpiredSection(
                        title: l10n.hostingsShortcut,
                        rows: expiredHostingRows,
                        endDateShort: l10n.endDateShort,
                      ),
                      _ExpiredSection(
                        title: l10n.domainsShortcut,
                        rows: expiredDomainRows,
                        endDateShort: l10n.endDateShort,
                      ),
                      _ExpiredSection(
                        title: l10n.sslsShortcut,
                        rows: expiredSslRows,
                        endDateShort: l10n.endDateShort,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        error: (e, st) => Center(child: Text(context.l10n.serverError)),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ServiceCountCard extends StatelessWidget {
  const _ServiceCountCard({
    required this.label,
    required this.active,
    required this.expired,
    required this.onTap,
    required this.onExpTap,
  });

  final String label;
  final String active;
  final String expired;
  final VoidCallback onTap;
  final VoidCallback onExpTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('$label: $active'),
        onTap: onTap,
        trailing: TextButton(
          onPressed: onExpTap,
          child: Text('${context.l10n.expiredLabel}: $expired'),
        ),
      ),
    );
  }
}

class _ExpiredSection extends StatelessWidget {
  const _ExpiredSection({
    required this.title,
    required this.rows,
    required this.endDateShort,
  });

  final String title;
  final List<_ExpiredRow> rows;
  final String endDateShort;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        ...rows.map(
          (r) => Card(
            margin: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                r.domainName.isEmpty ? r.customerName : r.domainName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              subtitle: r.domainName.isEmpty
                  ? null
                  : Text(
                      r.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
              trailing: Text(
                '$endDateShort: ${r.endDate}',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              onTap: () => context.go('${r.basePath}/${r.id}'),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ExpiredRow {
  const _ExpiredRow({
    required this.id,
    required this.basePath,
    required this.serviceLabel,
    required this.domainName,
    required this.customerName,
    required this.endDate,
  });

  factory _ExpiredRow.fromMap(Object raw, String basePath, String serviceLabel) {
    final m = (raw as Map).cast<String, dynamic>();
    return _ExpiredRow(
      id: (m['id'] ?? '').toString(),
      basePath: basePath,
      serviceLabel: serviceLabel,
      domainName: (m['domain_name'] ?? '').toString(),
      customerName: (m['customer_name'] ?? '').toString(),
      endDate: toDisplayDate((m['end_date'] ?? '').toString()),
    );
  }

  final String id;
  final String basePath;
  final String serviceLabel;
  final String domainName;
  final String customerName;
  final String endDate;
}


