import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../l10n/l10n_ext.dart';
import '../../features/auth/admin_login_screen.dart';
import '../../features/auth/admin_setup_screen.dart';
import '../../features/config/api_config_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/customers/customers_list_screen.dart';
import '../../features/customers/customer_detail_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/services/service_list_screen.dart';
import '../../features/services/service_detail_screen.dart';
import '../../features/services/service_type.dart';
import '../../features/services/hosting_form_screen.dart';
import '../../features/services/domain_form_screen.dart';
import '../../features/services/ssl_form_screen.dart';
import '../../features/customers/customer_form_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();

GoRouter buildRouter({
  required String apiBaseUrl,
  required bool isLoggedIn,
}) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    redirect: (context, state) {
      final loc = state.uri.toString();
      final needsApi = apiBaseUrl.isEmpty;
      if (needsApi && loc != '/config/api') return '/config/api';
      if (!needsApi && loc == '/config/api') return '/';

      // If not logged in, gate everything except login/setup/config.
      final isAuthRoute = loc == '/auth/login' || loc == '/auth/setup' || loc == '/config/api';
      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && (loc == '/auth/login' || loc == '/auth/setup')) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/dashboard',
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/customers',
            builder: (context, state) => const CustomersListScreen(),
          ),
          GoRoute(
            path: '/customers/new',
            builder: (context, state) => const CustomerFormScreen(),
          ),
          GoRoute(
            path: '/customers/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              if (id == 'edit') {
                // This shouldn't happen, but handle it gracefully
                return const CustomerFormScreen();
              }
              return CustomerDetailScreen(customerId: id);
            },
          ),
          GoRoute(
            path: '/customers/:id/edit',
            builder: (context, state) => CustomerFormScreen(
              customerId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/hostings',
            builder: (context, state) => ServiceListScreen(
              type: ServiceType.hostings,
              expiredOnly: state.uri.queryParameters['expiredOnly'] == '1',
            ),
          ),
          GoRoute(
            path: '/hostings/new',
            builder: (context, state) => const HostingFormScreen(),
          ),
          GoRoute(
            path: '/hostings/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              if (id == 'edit') {
                return const HostingFormScreen();
              }
              return ServiceDetailScreen(
                type: ServiceType.hostings,
                serviceId: id,
              );
            },
          ),
          GoRoute(
            path: '/hostings/:id/edit',
            builder: (context, state) => HostingFormScreen(
              hostingId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/domains',
            builder: (context, state) => ServiceListScreen(
              type: ServiceType.domains,
              expiredOnly: state.uri.queryParameters['expiredOnly'] == '1',
            ),
          ),
          GoRoute(
            path: '/domains/new',
            builder: (context, state) => const DomainFormScreen(),
          ),
          GoRoute(
            path: '/domains/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              if (id == 'edit') {
                return const DomainFormScreen();
              }
              return ServiceDetailScreen(
                type: ServiceType.domains,
                serviceId: id,
              );
            },
          ),
          GoRoute(
            path: '/domains/:id/edit',
            builder: (context, state) => DomainFormScreen(
              domainId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/ssls',
            builder: (context, state) => ServiceListScreen(
              type: ServiceType.ssls,
              expiredOnly: state.uri.queryParameters['expiredOnly'] == '1',
            ),
          ),
          GoRoute(
            path: '/ssls/new',
            builder: (context, state) => const SslFormScreen(),
          ),
          GoRoute(
            path: '/ssls/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              if (id == 'edit') {
                return const SslFormScreen();
              }
              return ServiceDetailScreen(
                type: ServiceType.ssls,
                serviceId: id,
              );
            },
          ),
          GoRoute(
            path: '/ssls/:id/edit',
            builder: (context, state) => SslFormScreen(
              sslId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/config/api',
        builder: (context, state) => const ApiConfigScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/auth/setup',
        builder: (context, state) => const AdminSetupScreen(),
      ),
    ],
  );
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _indexForLocation(String location) {
    if (location.startsWith('/customers')) return 1;
    if (location.startsWith('/hostings')) return 2;
    if (location.startsWith('/domains')) return 3;
    if (location.startsWith('/ssls')) return 4;
    if (location.startsWith('/settings')) return 5;
    return 0;
  }

  String _locationForIndex(int index) {
    return switch (index) {
      0 => '/dashboard',
      1 => '/customers',
      2 => '/hostings',
      3 => '/domains',
      4 => '/ssls',
      _ => '/settings',
    };
  }

  bool _isRootRoute(String location) {
    final rootRoutes = ['/dashboard', '/customers', '/hostings', '/domains', '/ssls', '/settings'];
    return rootRoutes.contains(location);
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(loc);
    final router = GoRouter.of(context);
    final isRoot = _isRootRoute(loc);

    return WillPopScope(
      onWillPop: () async {
        if (isRoot) {
          // Root route'daysak, dialog göster
          final shouldExit = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            useRootNavigator: true,
            builder: (context) => AlertDialog(
              title: Text(context.l10n.exitConfirm),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
                  child: Text(context.l10n.no),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
                  child: Text(context.l10n.yes),
                ),
              ],
            ),
          );
          
          if (shouldExit == true && mounted) {
            SystemNavigator.pop();
            return false;
          }
          return false; // Dialog gösterildi, çıkış yapma
        } else {
          // Nested route'daysak, normal geri git
          if (router.canPop()) {
            router.pop();
            return false;
          } else if (context.canPop()) {
            context.pop();
            return false;
          }
          return true; // Çıkış yapılabilir
        }
      },
      child: Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(_locationForIndex(i)),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: context.l10n.dashboardTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.people_outline),
            selectedIcon: const Icon(Icons.people),
            label: context.l10n.customersShortcut,
          ),
          NavigationDestination(
            icon: const Icon(Icons.cloud_outlined),
            selectedIcon: const Icon(Icons.cloud),
            label: context.l10n.hostingsShortcut,
          ),
          NavigationDestination(
            icon: const Icon(Icons.public_outlined),
            selectedIcon: const Icon(Icons.public),
            label: context.l10n.domainsShortcut,
          ),
          NavigationDestination(
            icon: const Icon(Icons.verified_user_outlined),
            selectedIcon: const Icon(Icons.verified_user),
            label: context.l10n.sslsShortcut,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: context.l10n.settingsTitle,
          ),
        ],
      ),
      ),
    );
  }
}


