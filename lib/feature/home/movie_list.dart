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

class MovieList extends StatelessWidget {
  const MovieList({super.key, this.title = '', this.itemFilms = const [], required this.slug});
  final String title;
  final String slug;
  final List<MovieInformation> itemFilms;


  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double height = MediaQuery.of(context).size.height;
    final app = AppLocalizations.of(context);
    final theme = Theme.of(context);
    var movieCubit = context.read<MovieCubit>();
    var localeCubit = context.read<LocaleCubit>();
    var page = 1;

    var listFilm = itemFilms;

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Column(
        children: [
          HeaderTitleApp(
            onTap: () {
              Navigator.pop(context);
            },
            title: title,
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
                      return ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 20),
                          itemBuilder: (context, index) {
                            print(index);
                            print("listFilm.length::::; ${listFilm.length}");
                            if (index >= listFilm.length - 1) {
                              // getMoreData();
                              switch (slug) {
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
                              movieCubit.getMovieDetails(slug, localeCubit.state.languageCode);
                              return const LoadingWidget();
                            }
                            if (state.seriesMovies.length > KeyApp.MAX_SIZE) {
                              listFilm = state.seriesMovies;
                            }
                            if (state.singleMovies.length > KeyApp.MAX_SIZE) {
                              listFilm = state.singleMovies;
                            }
                            if (state.cartoon.length > KeyApp.MAX_SIZE) {
                              listFilm = state.cartoon;
                            }

                            return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => WatchAMovie(
                                              movieInformation: listFilm[index])));
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

                    }
                  ),
                )
        ],
      ),
    );
  }
}
