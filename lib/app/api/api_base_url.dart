String? normalizeApiBaseUrl(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) return null;

  // Accept full URL or bare host (auto https).
  final candidate = trimmed.contains('://') ? trimmed : 'https://$trimmed';

  final uri = Uri.tryParse(candidate);
  if (uri == null) return null;
  if (!(uri.scheme == 'http' || uri.scheme == 'https')) return null;
  if (uri.host.isEmpty) return null;

  // Normalize to origin only, no trailing slash, no path/query/fragment.
  return uri.origin;
}


