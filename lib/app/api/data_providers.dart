import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_providers.dart';

/// Cache key provider for invalidating caches
final cacheInvalidatorProvider = StateProvider<int>((ref) => 0);

/// Helper function to invalidate all caches
void invalidateCache(WidgetRef ref) {
  ref.read(cacheInvalidatorProvider.notifier).state++;
}

/// Cached customers list provider
final customersListProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>?>((ref, queryParams) async {
  // Watch cache invalidator to refresh when cache is invalidated
  ref.watch(cacheInvalidatorProvider);
  
  final api = ref.watch(apiClientProvider);
  final params = queryParams ?? {'limit': 200};
  return api.getJson('/customers', queryParameters: params);
});

/// Cached customer detail provider
final customerDetailProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, customerId) async {
  ref.watch(cacheInvalidatorProvider);
  
  final api = ref.watch(apiClientProvider);
  return api.getJson('/customers/$customerId');
});

/// Cached service detail provider
final serviceDetailProvider = FutureProvider.family<Map<String, dynamic>, ({String type, String id})>((ref, params) async {
  ref.watch(cacheInvalidatorProvider);
  
  final api = ref.watch(apiClientProvider);
  return api.getJson('${params.type}/${params.id}');
});

/// Cached dashboard provider
final dashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  ref.watch(cacheInvalidatorProvider);
  
  final api = ref.watch(apiClientProvider);
  return api.getJson('/dashboard');
});

/// Cached service list provider
final serviceListProvider = FutureProvider.family<Map<String, dynamic>, ({String path, Map<String, dynamic>? queryParams})>((ref, params) async {
  ref.watch(cacheInvalidatorProvider);
  
  final api = ref.watch(apiClientProvider);
  return api.getJson(params.path, queryParameters: params.queryParams);
});

