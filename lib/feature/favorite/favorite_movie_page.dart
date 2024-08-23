import 'package:app/component/header_app.dart';
import 'package:app/feature/home/cubit/movie/movie_cubit.dart';
import 'package:app/feature/home/watch_a_movie.dart';
import 'package:app/l10n/cubit/locale_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../home/cubit/movie/movie_state.dart';

class FavoriteMoviePage extends StatelessWidget {
  const FavoriteMoviePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        color: theme.colorScheme.primary,
        child: Column(
          children: [
            HeaderApp(title: app!.favoriteFilm),
            BlocBuilder<MovieCubit, MovieState>(
              builder: (context, state) {
                if (state.favoriteMovies.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Text(app.emptyList),
                    ),
                  );
                }
                return Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(10),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: state.favoriteMovies.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => WatchAMovie(
                                      movieInformation:
                                      state.favoriteMovies[index])));
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl:
                                  state.favoriteMovies[index]!.poster_url,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                  const Icon(Icons.warning),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              height: 40,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                context.watch<LocaleCubit>().state.languageCode ==
                                    'en'
                                    ? state.favoriteMovies[index]!.origin_name
                                    : state.favoriteMovies[index]!.name,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
