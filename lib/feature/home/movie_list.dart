import 'dart:async';

import 'package:app/component/header_title_app.dart';
import 'package:app/config/app_size.dart';
import 'package:app/feature/home/models/movie_information.dart';
import 'package:app/feature/home/watch_a_movie.dart';
import 'package:app/feature/home/widgets/item_movie_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'cubit/movie/movie_cubit.dart';
import 'cubit/movie/movie_state.dart';



class MovieList extends StatefulWidget {
  const MovieList(
      {super.key,
      this.title = '',
      required this.slug,
      required this.itemFilms});
  final String title;
  final String slug;
  final List<MovieInformation> itemFilms;

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  List<MovieInformation> listFilm = [];
  int page = 1;
  late ScrollController controller;
  var isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    controller = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (controller.position.extentAfter < (context.size?.height ?? 0)) {
      _getMoreData();
    }
  }

  void _getMoreData() {
    if (isLoading) {
      return;
    }

    // Debounce logic to prevent rapid calls
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      isLoading = true;
      var movieCubit = context.read<MovieCubit>();
      switch (widget.slug) {
        case 'phim-le':
          movieCubit.getAListOfIndividualMovies(++page);
          break;
        case 'hoat-hinh':
          movieCubit.getTheListOfCartoons(++page);
          break;
        case 'phim-bo':
          movieCubit.getTheListOfMoviesAndSeries(++page);
          break;
        default:
          break;
      }
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final app = AppLocalizations.of(context);
    final theme = Theme.of(context);
    var listFilm = widget.itemFilms;

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Column(
        children: [
          HeaderTitleApp(
            onTap: () {
              Navigator.pop(context);
            },
            title: widget.title,
          ),
          Expanded(
            child: BlocBuilder<MovieCubit, MovieState>(
              builder: (context, state) {
                isLoading = false;
                return listFilm.isEmpty
                    ? Container(
                        alignment: Alignment.center,
                        height: height - 136,
                        width: width,
                        child: Text(app!.movieListIsEmpty),
                      )
                    : ListView.separated(
                        controller: controller,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WatchAMovie(
                                      movieInformation: listFilm[index]),
                                ),
                              );
                            },
                            child: ItemMovieInformation(
                              imageUrl: listFilm[index].thumb_url,
                              name: listFilm[index].name,
                              year: listFilm[index].year.toString(),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(
                          height: AppSize.size16,
                        ),
                        itemCount: listFilm.length,
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
