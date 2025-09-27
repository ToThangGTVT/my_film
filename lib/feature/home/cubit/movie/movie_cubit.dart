import 'package:app/config/debounce.dart';
import 'package:app/config/key_app.dart';
import 'package:app/config/print_color.dart';
import 'package:app/feature/home/models/data_film.dart';
import 'package:app/feature/home/models/movie_information.dart';
import 'package:app/feature/home/network/fetch_api_movie.dart';
// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:translator/translator.dart';

import 'movie_state.dart';

class MovieCubit extends Cubit<MovieState> {
  MovieCubit() : super(const MovieState());

  // Cố gắng giữ state trong Cubit thay vì field ngoài.
  // Nhưng nếu cần cache tạm, dùng các field private:
  final List<MovieInformation> _newMovies = [];
  final List<MovieInformation> _newSingleMovies = [];
  final List<MovieInformation> _newSeriesMovies = [];
  final List<MovieInformation> _newCartoons = [];
  final List<MovieInformation> _newCategoryMovies = [];

  final translator = GoogleTranslator();
  final Debounce _debounce = Debounce(milliseconds: 10000);

  static const String _imgBase = 'https://img.phimapi.com/';

  /* ======================= Helpers ======================= */

  MovieInformation _normalizeImages(MovieInformation m) {
    // Chuẩn hoá URL ảnh nếu API trả về đường dẫn tương đối
    if (m.poster_url != null && !m.poster_url!.startsWith('http')) {
      m.poster_url = '$_imgBase${m.poster_url}';
    }
    if (m.thumb_url != null && !m.thumb_url!.startsWith('http')) {
      m.thumb_url = '$_imgBase${m.thumb_url}';
    }
    return m;
  }

  List<MovieInformation> _decodeItemsToMovies(List items) {
    return items
        .map<MovieInformation>((raw) => _normalizeImages(MovieInformation.fromJson(raw)))
        .toList(growable: true);
  }

  void _flagFavoritesInPlace(List<MovieInformation> list) {
    if (state.favoriteMovies.isEmpty || list.isEmpty) return;
    final favSlugs = state.favoriteMovies
        .where((e) => e?.slug != null)
        .map((e) => e!.slug)
        .toSet();
    for (final m in list) {
      if (m.slug != null && favSlugs.contains(m.slug)) {
        m.isFavorite = true;
      }
    }
  }

  Future<void> _persistListToBox(
      Box<MovieInformation> box,
      List<MovieInformation?> list,
      ) async {
    await box.clear();
    for (final e in list) {
      if (e != null) {
        await box.add(e);
      }
    }
  }

  /* ======================= Public APIs ======================= */

  Future<void> getMovie(int page) async {
    emit(state.copyWith(status: MovieStatus.loading));
    try {
      final data = await FetchApiMovie.getMovies(page);
      final items = (data['items'] as List?) ?? const [];
      _newMovies
        ..clear()
        ..addAll(MovieInformation.convertToList(items));
      _flagFavoritesInPlace(_newMovies);

      emit(state.copyWith(
        movies: List.unmodifiable(_newMovies),
        status: MovieStatus.success,
      ));
    } catch (e, st) {
      printRed('getMovie error: $e\n$st');
      emit(state.copyWith(status: MovieStatus.error));
    }
  }

  Future<void> getMovieDetails(String slug, String languageCode) async {
    emit(state.copyWith(status: MovieStatus.loading, dataFilm: null));
    try {
      final data = await FetchApiMovie.getMovieDetails(slug);
      if (data['status'] == false) {
        emit(state.copyWith(status: MovieStatus.error));
        return;
      }

      final newDataFilm = DataFilm.fromJson(data);

      if (languageCode == 'en') {
        // Dịch song song
        final movie = newDataFilm.movie;

        final futures = <Future>[];
        if ((movie.content ?? '').isNotEmpty) {
          futures.add(translator.translate(movie.content!, to: 'en').then((v) {
            movie.content = v.toString();
          }));
        }

        // Diễn viên
        if (movie.actor.isNotEmpty) {
          futures.add(Future.wait(
            movie.actor.map((a) => translator.translate(a, to: 'en')).toList(),
          ).then((list) {
            for (int i = 0; i < list.length; i++) {
              movie.actor[i] = list[i].toString();
            }
          }));
        }

        // Thể loại
        if (movie.category.isNotEmpty) {
          futures.add(Future.wait(
            movie.category.map((c) => translator.translate(c.name, to: 'en')).toList(),
          ).then((list) {
            for (int i = 0; i < list.length; i++) {
              movie.category[i].name = list[i].toString();
            }
          }));
        }

        await Future.wait(futures);
      }

      printGreen(newDataFilm.movie.content ?? '');
      emit(state.copyWith(dataFilm: newDataFilm, status: MovieStatus.success));
    } catch (e, st) {
      printRed('getMovieDetails error: $e\n$st');
      emit(state.copyWith(status: MovieStatus.error));
    }
  }

  Future<void> getAListOfIndividualMovies(int page) async {
    emit(state.copyWith(status: MovieStatus.loading));
    try {
      final data = await FetchApiMovie.getAListOfIndividualMovies(page);
      final items = (data['data']?['items'] as List?) ?? const [];
      final movies = _decodeItemsToMovies(items);

      _newSingleMovies.addAll(movies);
      _flagFavoritesInPlace(_newSingleMovies);

      emit(state.copyWith(
        singleMovies: List.unmodifiable(_newSingleMovies),
        status: MovieStatus.success,
      ));
    } catch (e, st) {
      printRed('getAListOfIndividualMovies error: $e\n$st');
      emit(state.copyWith(status: MovieStatus.error));
    }
  }

  Future<void> getTheListOfMoviesAndSeries(int page) async {
    emit(state.copyWith(status: MovieStatus.loading));
    try {
      final data = await FetchApiMovie.getTheListOfMoviesAndSeries(page);
      final items = (data['data']?['items'] as List?) ?? const [];
      final movies = _decodeItemsToMovies(items);

      _newSeriesMovies.addAll(movies);
      _flagFavoritesInPlace(_newSeriesMovies);

      emit(state.copyWith(
        seriesMovies: List.unmodifiable(_newSeriesMovies),
        status: MovieStatus.success,
      ));
    } catch (e, st) {
      printRed('getTheListOfMoviesAndSeries error: $e\n$st');
      emit(state.copyWith(status: MovieStatus.error));
    }
  }

  Future<void> getTheListOfCategory(String category, int page) async {
    emit(state.copyWith(status: MovieStatus.loading));
    try {
      final data = await FetchApiMovie.getTheListOfCategory(category, page);
      final items = (data['data']?['items'] as List?) ?? const [];
      final movies = _decodeItemsToMovies(items);

      _newCategoryMovies.addAll(movies);
      _flagFavoritesInPlace(_newCategoryMovies);

      emit(state.copyWith(
        categoryMovies: List.unmodifiable(_newCategoryMovies),
        status: MovieStatus.success,
      ));
    } catch (e, st) {
      printRed('getTheListOfCategory error: $e\n$st');
      emit(state.copyWith(status: MovieStatus.error));
    }
  }

  Future<void> getTheListOfCartoons(int page) async {
    emit(state.copyWith(status: MovieStatus.loading));
    try {
      final data = await FetchApiMovie.getTheListOfCartoons(page);
      final items = (data['data']?['items'] as List?) ?? const [];
      final movies = _decodeItemsToMovies(items);

      _newCartoons.addAll(movies);
      _flagFavoritesInPlace(_newCartoons);

      emit(state.copyWith(
        cartoon: List.unmodifiable(_newCartoons),
        status: MovieStatus.success,
      ));
    } catch (e, st) {
      printRed('getTheListOfCartoons error: $e\n$st');
      emit(state.copyWith(status: MovieStatus.error));
    }
  }

  Future<void> moviesSearch(String keyWord) async {
    emit(state.copyWith(status: MovieStatus.loading));
    try {
      final data = await FetchApiMovie.movieSearch(keyWord);
      final items = (data['data']?['items'] as List?) ?? const [];
      final result = _decodeItemsToMovies(items);
      _flagFavoritesInPlace(result);

      emit(state.copyWith(
        moviesSearch: List.unmodifiable(result),
        status: MovieStatus.success,
      ));
    } catch (e, st) {
      printRed('moviesSearch error: $e\n$st');
      emit(state.copyWith(status: MovieStatus.error));
    }
  }

  /* ======================= Favorites ======================= */

  Future<void> getMovieDataTheLocalStorage() async {
    emit(state.copyWith(status: MovieStatus.loading));
    try {
      final box = Hive.box<MovieInformation>(KeyApp.FAVORITE_MOVIE_BOX);
      if (box.isEmpty) {
        emit(state.copyWith(favoriteMovies: const [], status: MovieStatus.success));
        return;
      }
      final items = List<MovieInformation?>.generate(
        box.length,
            (i) => box.getAt(i),
        growable: false,
      );
      emit(state.copyWith(favoriteMovies: items, status: MovieStatus.success));
    } catch (e, st) {
      printRed('getMovieDataTheLocalStorage error: $e\n$st');
      emit(state.copyWith(status: MovieStatus.error));
    }
  }

  Future<void> addMoviesToFavoritesList({required MovieInformation? itemFilm}) async {
    if (itemFilm == null) return;
    emit(state.copyWith(status: MovieStatus.loading));
    try {
      final current = List<MovieInformation?>.from(state.favoriteMovies);
      // Tránh trùng slug
      final exists = current.any((e) => e?.slug == itemFilm.slug);
      final newList = exists ? current : [itemFilm, ...current];

      final box = Hive.box<MovieInformation>(KeyApp.FAVORITE_MOVIE_BOX);
      await _persistListToBox(box, newList);

      emit(state.copyWith(favoriteMovies: newList, status: MovieStatus.success));
    } catch (e, st) {
      printRed('addMoviesToFavoritesList error: $e\n$st');
      emit(state.copyWith(status: MovieStatus.error));
    }
  }

  Future<void> removeMoviesToFavoritesList({required MovieInformation? itemFilm}) async {
    if (itemFilm == null) return;
    emit(state.copyWith(status: MovieStatus.loading));
    try {
      final newList = List<MovieInformation?>.from(state.favoriteMovies)
        ..removeWhere((e) => e?.slug == itemFilm.slug);

      final box = Hive.box<MovieInformation>(KeyApp.FAVORITE_MOVIE_BOX);
      await _persistListToBox(box, newList);

      emit(state.copyWith(favoriteMovies: newList, status: MovieStatus.success));
    } catch (e, st) {
      printRed('removeMoviesToFavoritesList error: $e\n$st');
      emit(state.copyWith(status: MovieStatus.error));
    }
  }

  /* ======================= History ======================= */

  static const int _maxHistory = 20;

  Future<void> addToWatchHistory({required MovieInformation? itemFilm}) async {
    if (itemFilm == null) return;
    emit(state.copyWith(status: MovieStatus.loading));
    try {
      final box = Hive.box<MovieInformation>(KeyApp.VIEW_HISTORY_BOX);
      final current = List<MovieInformation?>.from(state.viewHistory);

      // Remove nếu đã tồn tại -> push lên đầu
      current.removeWhere((e) => e?.slug == itemFilm.slug);
      current.insert(0, itemFilm);

      // Cắt theo giới hạn
      if (current.length > _maxHistory) {
        current.removeRange(_maxHistory, current.length);
      }

      await _persistListToBox(box, current);

      emit(state.copyWith(viewHistory: current, status: MovieStatus.success));
    } catch (e, st) {
      printRed('addToWatchHistory error: $e\n$st');
      emit(state.copyWith(status: MovieStatus.error));
    }
  }

  Future<void> getViewHistoryTheLocalStorage() async {
    emit(state.copyWith(status: MovieStatus.loading));
    try {
      final box = Hive.box<MovieInformation>(KeyApp.VIEW_HISTORY_BOX);
      final items = <MovieInformation?>[];
      for (int i = 0; i < box.length; i++) {
        items.add(box.getAt(i));
      }
      printCyan('history length: ${items.length}');
      emit(state.copyWith(viewHistory: items, status: MovieStatus.success));
    } catch (e, st) {
      printRed('getViewHistoryTheLocalStorage error: $e\n$st');
      emit(state.copyWith(status: MovieStatus.error));
    }
  }

  Future<void> clearCache() async {
    emit(state.copyWith(status: MovieStatus.loading));
    try {
      final historyBox = Hive.box<MovieInformation>(KeyApp.VIEW_HISTORY_BOX);
      final favoriteBox = Hive.box<MovieInformation>(KeyApp.FAVORITE_MOVIE_BOX);
      await historyBox.clear();
      await favoriteBox.clear();
      emit(state.copyWith(
        status: MovieStatus.success,
        favoriteMovies: const [],
        viewHistory: const [],
      ));
    } catch (e, st) {
      printRed('clearCache error: $e\n$st');
      emit(state.copyWith(status: MovieStatus.error));
    }
  }

  /* ======================= Translate ======================= */

  Future<String> translate(String content) async {
    try {
      if (content.trim().isEmpty) return content;
      final v = await translator.translate(content, to: 'en');
      return v.toString();
    } catch (e) {
      // Nếu lỗi dịch, trả về nguyên bản để không crash UI
      printYellow('translate fallback: $e');
      return content;
    }
  }

  /* ======================= Debounce ======================= */

  void debounce(Function() onChanged) {
    _debounce.call(onChanged);
  }
}
