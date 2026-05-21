List<dynamic> extractList(dynamic decoded) {
  if (decoded is List) return decoded;

  if (decoded is Map) {
    final data = decoded['data'];

    if (data is List) return data;

    if (data is Map) {
      if (data['data'] is List) return data['data'];
      if (data['items'] is List) return data['items'];
      if (data['books'] is List) return data['books'];
      if (data['categories'] is List) return data['categories'];
    }

    if (decoded['items'] is List) return decoded['items'];
    if (decoded['books'] is List) return decoded['books'];
    if (decoded['categories'] is List) return decoded['categories'];
    if (decoded['recommended'] is List) return decoded['recommended'];
    if (decoded['result'] is List) return decoded['result'];
    if (decoded['results'] is List) return decoded['results'];
  }

  return [];
}

Map<String, dynamic> extractMeta(dynamic decoded) {
  if (decoded is! Map) return {};

  final data = decoded['data'];

  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }

  final meta = decoded['meta'];

  if (meta is Map) {
    return Map<String, dynamic>.from(meta);
  }

  return Map<String, dynamic>.from(decoded);
}