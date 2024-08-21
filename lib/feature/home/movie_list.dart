import 'package:app/component/header_title_app.dart';
import 'package:app/config/app_size.dart';
import 'package:app/config/key_app.dart';
import 'package:app/feature/home/models/movie_information.dart';
import 'package:app/feature/home/watch_a_movie.dart';
import 'package:app/feature/home/widgets/item_movie_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../component/loading_widget.dart';
import '../../l10n/cubit/locale_cubit.dart';
import 'cubit/movie_cubit.dart';
import 'cubit/movie_state.dart';

class MovieList extends StatefulWidget {
  final String title;
  final String slug;
  final List<MovieInformation> itemFilms;

  const MovieList({
    super.key,
    required this.title,
    required this.slug,
    required this.itemFilms,
  });

  @override
  _MovieListWidgetState createState() => _MovieListWidgetState();
}

class _MovieListWidgetState extends State<MovieList> {
  late ScrollController controller;
  var page = 1;
  var isLoading = true;

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
    var movieCubit = context.read<MovieCubit>();
    var localeCubit = context.read<LocaleCubit>();

    if (controller.position.extentAfter < context.size!.height) {
      if (isLoading == true) {
        return;
      }
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
      isLoading = true;
    }
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
          listFilm.isEmpty
              ? Container(
                  alignment: Alignment.center,
                  height: height - 136,
                  width: width,
                  child: Text(app!.movieListIsEmpty),
                )
              : Expanded(
                  child: BlocBuilder<MovieCubit, MovieState>(
                      builder: (context, state) {
                        isLoading = false;
                    return ListView.separated(
                        controller: controller,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        itemBuilder: (context, index) {
                          if (index >= listFilm.length - 1) {
                            // getMoreData();
                            return const LoadingWidget();
                          }

                          return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => WatchAMovie(
                                            movieInformation:
                                                listFilm[index])));
                              },
                              child: ItemMovieInformation(
                                imageUrl: listFilm[index].thumb_url,
                                name: listFilm[index].name,
                                year: listFilm[index].year.toString(),
                              ));
                        },
                        separatorBuilder: (context, index) => const SizedBox(
                              height: AppSize.size16,
                            ),
                        itemCount: listFilm.length);
                  }),
                )
        ],
      ),
    );
  }
}
