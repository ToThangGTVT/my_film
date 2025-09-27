// lib/feature/home/network/api_cache.dart
import 'dart:convert';
import 'package:hive/hive.dart';

class ApiCacheItem {
  final String body;
  final String? etag;
  final String? lastModified;
  final DateTime savedAt;

  ApiCacheItem({
    required this.body,
    required this.savedAt,
    this.etag,
    this.lastModified,
  });

  Map<String, dynamic> toJson() => {
    'body': body,
    'etag': etag,
    'lastModified': lastModified,
    'savedAt': savedAt.toIso8601String(),
  };

  static ApiCacheItem fromJson(Map<String, dynamic> json) => ApiCacheItem(
    body: json['body'] as String,
    etag: json['etag'] as String?,
    lastModified: json['lastModified'] as String?,
    savedAt: DateTime.tryParse(json['savedAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}

class ApiCache {
  static const _boxName = 'api_cache';

  static Future<void> ensureOpen() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
  }

  static String _keyForUri(Uri uri) => uri.toString();

  static Future<ApiCacheItem?> read(Uri uri) async {
    final box = Hive.box<String>(_boxName);
    final raw = box.get(_keyForUri(uri));
    if (raw == null) return null;
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return ApiCacheItem.fromJson(map);
  }

  static Future<void> write(Uri uri, ApiCacheItem item) async {
    final box = Hive.box<String>(_boxName);
    await box.put(_keyForUri(uri), jsonEncode(item.toJson()));
  }

  static bool isFresh(ApiCacheItem item, Duration maxAge) {
    return DateTime.now().difference(item.savedAt) <= maxAge;
  }
}
