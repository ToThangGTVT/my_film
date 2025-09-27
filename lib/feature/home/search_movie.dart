import 'dart:ui';
import 'package:app/component/loading_widget.dart';
import 'package:app/config/debounce.dart';
import 'package:app/config/print_color.dart';
import 'package:app/feature/home/watch_a_movie.dart';
import 'package:app/feature/home/widgets/item_movie_information.dart';
import 'package:app/l10n/cubit/locale_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import 'cubit/movie/movie_cubit.dart';
import 'cubit/movie/movie_state.dart';

class SearchMovie extends StatefulWidget {
  const SearchMovie({super.key});

  @override
  State<SearchMovie> createState() => _SearchMovieState();
}

class _SearchMovieState extends State<SearchMovie> {
  final TextEditingController searchController = TextEditingController();
  late MovieCubit movieCubit;
  bool isPlaySearch = false;
  bool isFirst = true;

  final Debounce debounce = Debounce();

  @override
  void initState() {
    super.initState();
    movieCubit = context.read<MovieCubit>();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _runSearch() async {
    if (searchController.text.trim().isEmpty) return;
    setState(() {
      isPlaySearch = true;
    });
    FocusScope.of(context).unfocus();
    await movieCubit.moviesSearch(searchController.text.trim());
    isPlaySearch = false;
    isFirst = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Container(
          // Nền gradient nhẹ, không đổi logic
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.98),
                theme.colorScheme.primary.withOpacity(0.96),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 16),
                  // Thanh tiêu đề + ô tìm kiếm
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // Ô nhập tìm kiếm
                        Expanded(
                          child: SizedBox(
                            height: 44,
                            child: TextField(
                              controller: searchController,
                              autofocus: true,
                              onSubmitted: (_) => _runSearch(),
                              cursorColor: theme.colorScheme.onPrimary,
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: app?.search ?? '',
                                hintStyle: TextStyle(
                                  color: theme.colorScheme.tertiary.withOpacity(0.9),
                                  fontWeight: FontWeight.w400,
                                ),
                                filled: true,
                                fillColor: theme.colorScheme.surface.withOpacity(0.7),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                prefixIcon: Icon(Icons.search, color: theme.colorScheme.tertiary),
                                suffixIcon: GestureDetector(
                                  onTap: _runSearch,
                                  child: Icon(Icons.arrow_forward_rounded, color: theme.colorScheme.tertiary),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: theme.colorScheme.outline.withOpacity(0.25),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    width: 1.2,
                                    color: theme.colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Nút Cancel
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                            child: Text(
                              app!.cancel,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Khu vực kết quả
                  isFirst
                      ? const SizedBox.shrink() // sau này đặt lịch sử tìm kiếm
                      : BlocBuilder<MovieCubit, MovieState>(
                    builder: (context, state) {
                      if (state.moviesSearch.isEmpty) {
                        // Empty state đẹp hơn
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.movie_filter_outlined, color: theme.colorScheme.tertiary),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    app.movieNotFound,
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Expanded(
                        child: ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
                          itemCount: state.moviesSearch.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = state.moviesSearch[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  movieCubit.addToWatchHistory(itemFilm: item);
                                  printRed(item.slug);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => WatchAMovie(movieInformation: item),
                                    ),
                                  );
                                },
                                child: Ink(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: theme.colorScheme.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    child: ItemMovieInformation(
                                      movieInformation: item,
                                      isThumb: true,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),

              // Loading overlay – giữ nguyên logic
              if (isPlaySearch)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.35),
                    child: const Center(child: LoadingWidget()),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
