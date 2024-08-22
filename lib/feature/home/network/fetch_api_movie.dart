import 'dart:convert';
import 'package:app/config/key_app.dart';
import 'package:app/config/print_color.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FetchApiMovie {
  FetchApiMovie._();

  static Future<Map<String, dynamic>> getMovies(int page) async {
    if (page < 1) {
      page = 1;
    }
    var uri =
        Uri.https(KeyApp.Base_URL, KeyApp.NEW_UPDATE_MOVIES, {'page': '$page'});
    _logUri(uri);
    Map<String, dynamic> result = {};
    try {
      final response = await http.get(uri);
      _logResponse(response);

      switch (response.statusCode) {
        case 200:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 400:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 401:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 404:
          var data = jsonDecode(response.body);
          result = data;
          break;
        default:
          var data = jsonDecode(response.body);
          result = data;
      }

      return result;
    } catch (e) {
      printRed(e.toString());
    }
    return result;
  }

  static Future<Map<String, dynamic>> getMovieDetails(String slug) async {
    var uri = Uri.https(
      KeyApp.Base_URL,
      '/phim/$slug',
    );
    _logUri(uri);
    Map<String, dynamic> result = {};
    try {
      final response = await http.get(uri);
      _logResponse(response);

      switch (response.statusCode) {
        case 200:
          Map<String, dynamic> data = jsonDecode(response.body);
          result = data;
          break;
        case 400:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 401:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 404:
          var data = jsonDecode(response.body);
          result = data;

          break;
        default:
      }
      return result;
    } catch (e) {
      printRed(e.toString());
    }

    return result;
  }

  static Future<Map<String, dynamic>> getAListOfIndividualMovies(int page) async {
    var uri = Uri.https(KeyApp.Base_URL, KeyApp.SINGLE_MOVIES, {'limit': '${KeyApp.MAX_SIZE}', 'page': '$page'});
    _logUri(uri);
    Map<String, dynamic> result = {};
    try {
      final response = await http.get(uri);
      _logResponse(response);

      switch (response.statusCode) {
        case 200:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 400:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 401:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 404:
          var data = jsonDecode(response.body);
          result = data;
          break;
        default:
          var data = jsonDecode(response.body);
          result = data;
      }

      return result;
    } catch (e) {
      printRed(e.toString());
    }
    return result;
  }

  static Future<Map<String, dynamic>> getTheListOfMoviesAndSeries(int page) async {
    var uri = Uri.https(KeyApp.Base_URL, KeyApp.SERIES_MOVIES, {'limit': '${KeyApp.MAX_SIZE}', 'page': '$page'});
    _logUri(uri);
    Map<String, dynamic> result = {};
    try {
      final response = await http.get(uri);
      _logResponse(response);

      switch (response.statusCode) {
        case 200:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 400:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 401:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 404:
          var data = jsonDecode(response.body);
          result = data;
          break;
        default:
          var data = jsonDecode(response.body);
          result = data;
      }

      return result;
    } catch (e) {
      printRed(e.toString());
    }
    return result;
  }

  static Future<Map<String, dynamic>> getTheListOfCartoons(int page) async {
    var uri = Uri.https(KeyApp.Base_URL, KeyApp.CARTOON, {'limit': '${KeyApp.MAX_SIZE}', 'page': '$page'});
    _logUri(uri);
    Map<String, dynamic> result = {};
    try {
      final response = await http.get(uri);
      _logResponse(response);

      switch (response.statusCode) {
        case 200:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 400:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 401:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 404:
          var data = jsonDecode(response.body);
          result = data;
          break;
        default:
          var data = jsonDecode(response.body);
          result = data;
      }

      return result;
    } catch (e) {
      printRed(e.toString());
    }
    return result;
  }

  static Future<Map<String, dynamic>> movieSearch(String keyWord) async {
    var uri = Uri.https(KeyApp.Base_URL, KeyApp.MOVIES_SEARCH,
        {'keyword': keyWord, 'limit': '10'});
    _logUri(uri);
    Map<String, dynamic> result = {};
    try {
      final response = await http.get(uri);
      _logResponse(response);

      switch (response.statusCode) {
        case 200:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 400:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 401:
          var data = jsonDecode(response.body);
          result = data;
          break;
        case 404:
          var data = jsonDecode(response.body);
          result = data;
          break;
        default:
          var data = jsonDecode(response.body);
          result = data;
      }

      return result;
    } catch (e) {
      printRed(e.toString());
    }
    return result;
  }

  static Uri _logUri(Uri uri) {
    if (kDebugMode) {
      print('Fetching movies from: $uri');
    }
    return uri;
  }

  static void _logResponse(http.Response response) {
    if (kDebugMode) {
      print('API response status code: ${response.statusCode}');
      print('API response data: ${response.body}');
    }
  }
}
