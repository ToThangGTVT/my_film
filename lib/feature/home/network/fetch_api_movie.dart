// lib/feature/home/network/fetch_api_movie.dart
import 'dart:convert';
import 'package:app/config/key_app.dart';
import 'package:app/config/print_color.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:app/feature/home/network/api_cache.dart';

class FetchApiMovie {
  FetchApiMovie._();

  // Tinh chỉnh TTL cho từng endpoint nếu muốn
  static const Duration _defaultMaxAge = Duration(minutes: 10);
  static const Duration _detailsMaxAge = Duration(minutes: 30);

  static Map<String, String> get _defaultHeaders => const {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=utf-8',
    'Connection': 'keep-alive',
    'Accept-Encoding': 'gzip',
    'User-Agent': 'app/1.0 (Flutter; dart:io)',
  };

  /* =================== Public APIs (y như cũ) =================== */

  static Future<Map<String, dynamic>> getMovies(int page) async {
    final p = page < 1 ? 1 : page;
    final uri = Uri.https(KeyApp.Base_URL, KeyApp.NEW_UPDATE_MOVIES, {'page': '$p'});
    return _getJsonCached(uri, maxAge: _defaultMaxAge);
  }

  static Future<Map<String, dynamic>> getMovieDetails(String slug) async {
    final uri = Uri.https(KeyApp.Base_URL, '/phim/$slug');
    return _getJsonCached(uri, maxAge: _detailsMaxAge);
  }

  static Future<Map<String, dynamic>> getAListOfIndividualMovies(int page) async {
    final uri = Uri.https(
      KeyApp.Base_URL,
      KeyApp.SINGLE_MOVIES,
      {'limit': '${KeyApp.MAX_SIZE}', 'page': '$page'},
    );
    return _getJsonCached(uri, maxAge: _defaultMaxAge);
  }

  static Future<Map<String, dynamic>> getTheListOfMoviesAndSeries(int page) async {
    final uri = Uri.https(
      KeyApp.Base_URL,
      KeyApp.SERIES_MOVIES,
      {'limit': '${KeyApp.MAX_SIZE}', 'page': '$page'},
    );
    return _getJsonCached(uri, maxAge: _defaultMaxAge);
  }

  static Future<Map<String, dynamic>> getTheListOfCategory(String category, int page) async {
    final path = "${KeyApp.CATEGORIES}/$category";
    final uri = Uri.https(
      KeyApp.Base_URL,
      path,
      {'limit': '${KeyApp.MAX_SIZE}', 'page': '$page'},
    );
    return _getJsonCached(uri, maxAge: _defaultMaxAge);
  }

  static Future<Map<String, dynamic>> getTheListOfCartoons(int page) async {
    final uri = Uri.https(
      KeyApp.Base_URL,
      KeyApp.CARTOON,
      {'limit': '${KeyApp.MAX_SIZE}', 'page': '$page'},
    );
    return _getJsonCached(uri, maxAge: _defaultMaxAge);
  }

  static Future<Map<String, dynamic>> movieSearch(String keyWord) async {
    final uri = Uri.https(
      KeyApp.Base_URL,
      KeyApp.MOVIES_SEARCH,
      {'keyword': keyWord, 'limit': '10'},
    );
    // Search thường muốn dữ liệu mới → giảm TTL
    return _getJsonCached(uri, maxAge: const Duration(minutes: 2));
  }

  /* =================== Core (Cache + Conditional) =================== */

  static Future<Map<String, dynamic>> _getJsonCached(
      Uri uri, {
        Duration maxAge = const Duration(minutes: 10),
      }) async {
    await ApiCache.ensureOpen();

    // 1) Nếu có cache tươi → trả ngay
    final cached = await ApiCache.read(uri);
    if (cached != null && ApiCache.isFresh(cached, maxAge)) {
      if (kDebugMode) print('🟢 [CACHE] $uri');
      return compute(_parseJsonToMap, cached.body);
    }

    // 2) Conditional request nếu có etag/lastModified
    final headers = {..._defaultHeaders};
    if (cached?.etag?.isNotEmpty == true) {
      headers['If-None-Match'] = cached!.etag!;
    }
    if (cached?.lastModified?.isNotEmpty == true) {
      headers['If-Modified-Since'] = cached!.lastModified!;
    }

    _logUri(uri);

    http.Response res;
    try {
      res = await http.get(uri, headers: headers).timeout(const Duration(seconds: 20));
    } catch (e) {
      printRed('Fetch error for $uri: $e');
      // Nếu lỗi mạng và có cache cũ → trả cache cũ (dù hết hạn) để không blank UI
      if (cached != null) {
        if (kDebugMode) print('🟠 [STALE-CACHE] $uri');
        return compute(_parseJsonToMap, cached.body);
      }
      return const {};
    }

    _logResponseLite(res);

    // 3) 304 → dùng lại cache
    if (res.statusCode == 304 && cached != null) {
      if (kDebugMode) print('🔵 [304] Not Modified $uri');
      // Cập nhật savedAt để “tươi” lại
      await ApiCache.write(
        uri,
        ApiCacheItem(
          body: cached.body,
          etag: cached.etag,
          lastModified: cached.lastModified,
          savedAt: DateTime.now(),
        ),
      );
      return compute(_parseJsonToMap, cached.body);
    }

    // 4) 200 → lưu body mới + etag/lastModified nếu có
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final newEtag = res.headers['etag'];
      final newLast = res.headers['last-modified'];

      final item = ApiCacheItem(
        body: res.body,
        etag: newEtag,
        lastModified: newLast,
        savedAt: DateTime.now(),
      );
      await ApiCache.write(uri, item);

      return compute(_parseJsonToMap, res.body);
    }

    // 5) Lỗi HTTP khác → fallback cache nếu có
    printRed('HTTP ${res.statusCode} for $uri');
    if (cached != null) {
      if (kDebugMode) print('🟠 [FALLBACK-CACHE] $uri');
      return compute(_parseJsonToMap, cached.body);
    }
    return const {};
  }

  static Map<String, dynamic> _parseJsonToMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }

  static void _logUri(Uri uri) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('➡️ GET $uri');
    }
  }

  static void _logResponseLite(http.Response response) {
    if (kDebugMode) {
      final body = response.body;
      final preview = body.length > 200 ? '${body.substring(0, 200)}...' : body;
      // ignore: avoid_print
      print('⬅️ ${response.statusCode} ${response.request?.url}\n$preview');
    }
  }
}
