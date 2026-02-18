import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/auth/auth_providers.dart';
import '../../app/l10n/l10n_ext.dart';
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

              final hostingActive = hosting['active']?.toString() ?? '0';
              final hostingExp = hosting['expired']?.toString() ?? '0';
              final domainActive = domains['active']?.toString() ?? '0';
              final domainExp = domains['expired']?.toString() ?? '0';
              final sslActive = ssls['active']?.toString() ?? '0';
              final sslExp = ssls['expired']?.toString() ?? '0';

              final expiredAll = [
                ...expiredHostings.map((e) => _ExpiredRow.fromMap(e, '/hostings', context.l10n.hostingsShortcut)),
                ...expiredDomains.map((e) => _ExpiredRow.fromMap(e, '/domains', context.l10n.domainsShortcut)),
                ...expiredSsls.map((e) => _ExpiredRow.fromMap(e, '/ssls', context.l10n.sslsShortcut)),
              ]..sort((a, b) => a.endDate.compareTo(b.endDate));

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 900 : double.infinity),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        child: ListTile(
                          title: Text(
                            '${context.l10n.hostingsShortcut}: $hostingActive (Exp: $hostingExp)',
                          ),
                          onTap: () => context.go('/hostings'),
                          trailing: TextButton(
                            onPressed: () => context.go('/hostings?expiredOnly=1'),
                            child: Text('Exp: $hostingExp'),
                          ),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: Text(
                            '${context.l10n.domainsShortcut}: $domainActive (Exp: $domainExp)',
                          ),
                          onTap: () => context.go('/domains'),
                          trailing: TextButton(
                            onPressed: () => context.go('/domains?expiredOnly=1'),
                            child: Text('Exp: $domainExp'),
                          ),
                        ),
                      ),
                      Card(
                        child: ListTile(
                          title: Text(
                            '${context.l10n.sslsShortcut}: $sslActive (Exp: $sslExp)',
                          ),
                          onTap: () => context.go('/ssls'),
                          trailing: TextButton(
                            onPressed: () => context.go('/ssls?expiredOnly=1'),
                            child: Text('Exp: $sslExp'),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.expiringServicesTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (expiredAll.isEmpty)
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(context.l10n.noData),
                          ),
                        )
                      else
                        ...expiredAll.map(
                          (r) => Card(
                            child: ListTile(
                              title: Text('${r.serviceLabel}: ${r.domainName}'),
                              subtitle: Text('${r.customerName} • ${context.l10n.endDate}: ${r.endDate}'),
                              onTap: () => context.go('${r.basePath}/${r.id}'),
                            ),
                          ),
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
      endDate: (m['end_date'] ?? '').toString(),
    );
  }

  final String id;
  final String basePath;
  final String serviceLabel;
  final String domainName;
  final String customerName;
  final String endDate;
}


