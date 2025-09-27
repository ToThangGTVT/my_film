import 'dart:convert';
import 'package:app/config/key_app.dart';
import 'package:app/config/print_color.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FetchApiMovie {
  FetchApiMovie._();

  // ========= PUBLIC APIS (giữ nguyên chữ ký) =========

  static Future<Map<String, dynamic>> getMovies(int page) async {
    final safePage = page < 1 ? 1 : page;
    final uri = Uri.https(KeyApp.Base_URL, KeyApp.NEW_UPDATE_MOVIES, {'page': '$safePage'});
    return _getJson(uri);
  }

  static Future<Map<String, dynamic>> getMovieDetails(String slug) async {
    final uri = Uri.https(KeyApp.Base_URL, '/phim/$slug');
    return _getJson(uri);
  }

  static Future<Map<String, dynamic>> getAListOfIndividualMovies(int page) async {
    final uri = Uri.https(
      KeyApp.Base_URL,
      KeyApp.SINGLE_MOVIES,
      {'limit': '${KeyApp.MAX_SIZE}', 'page': '$page'},
    );
    return _getJson(uri);
  }

  static Future<Map<String, dynamic>> getTheListOfMoviesAndSeries(int page) async {
    final uri = Uri.https(
      KeyApp.Base_URL,
      KeyApp.SERIES_MOVIES,
      {'limit': '${KeyApp.MAX_SIZE}', 'page': '$page'},
    );
    return _getJson(uri);
  }

  static Future<Map<String, dynamic>> getTheListOfCategory(String category, int page) async {
    final path = "${KeyApp.CATEGORIES}/$category";
    final uri = Uri.https(
      KeyApp.Base_URL,
      path,
      {'limit': '${KeyApp.MAX_SIZE}', 'page': '$page'},
    );
    return _getJson(uri);
  }

  static Future<Map<String, dynamic>> getTheListOfCartoons(int page) async {
    final uri = Uri.https(
      KeyApp.Base_URL,
      KeyApp.CARTOON,
      {'limit': '${KeyApp.MAX_SIZE}', 'page': '$page'},
    );
    return _getJson(uri);
  }

  static Future<Map<String, dynamic>> movieSearch(String keyWord) async {
    final uri = Uri.https(
      KeyApp.Base_URL,
      KeyApp.MOVIES_SEARCH,
      {'keyword': keyWord, 'limit': '10'},
    );
    return _getJson(uri);
  }

  // ========= CORE HTTP + BACKGROUND PARSE =========

  static Future<Map<String, dynamic>> _getJson(Uri uri) async {
    _logUri(uri);

    try {
      final res = await http
          .get(uri, headers: _defaultHeaders)
          .timeout(const Duration(seconds: 20));

      _logResponse(res);

      if (res.statusCode < 200 || res.statusCode >= 300) {
        printRed('HTTP ${res.statusCode} for $uri');
        return const {};
      }

      // Parse JSON ở background isolate → trả kết quả về main
      final map = await compute(_parseJsonToMap, res.body);
      return map;
    } catch (e, st) {
      printRed('Fetch error for $uri: $e');
      if (kDebugMode) {
        // In dev: log thêm stacktrace cho dễ debug
        // ignore: avoid_print
        print(st);
      }
      return const {};
    }
  }

  // Hàm top-level để compute() có thể gọi (bắt buộc top-level/static)
  static Map<String, dynamic> _parseJsonToMap(String body) {
    final decoded = jsonDecode(body);
    // đảm bảo trả về Map<String, dynamic>
    if (decoded is Map<String, dynamic>) return decoded;
    // một số API có thể trả mảng ở root → bọc lại
    return {'data': decoded};
  }

  // ========= LOG & HEADERS =========

  static Map<String, String> get _defaultHeaders => <String, String>{
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=utf-8',
  };

  static void _logUri(Uri uri) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('➡️ GET $uri');
    }
  }

  static void _logResponse(http.Response response) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('⬅️ ${response.request?.url} — ${response.statusCode}');
      // ignore: avoid_print
      print('Body: ${response.body}');
    }
  }
}
