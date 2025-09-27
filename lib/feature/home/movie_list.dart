import 'dart:async';
import 'package:app/component/header_title_app.dart';
import 'package:app/config/app_size.dart';
import 'package:app/feature/home/models/movie_information.dart';
import 'package:app/feature/home/watch_a_movie.dart';
import 'package:app/feature/home/widgets/item_movie_information.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import 'cubit/movie/movie_cubit.dart';
import 'cubit/movie/movie_state.dart';

class MovieList extends StatefulWidget {
  const MovieList({
    super.key,
    this.title = '',
    this.category = '',
    required this.slug,
    required this.itemFilms,
  });

  final String title;
  final String slug; // 'phim-le' | 'hoat-hinh' | 'phim-bo' | 'the-loai'
  final List<MovieInformation> itemFilms; // seed ban đầu
  final String category;

  @override
  State<MovieList> createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  final ScrollController _controller = ScrollController();

  int _page = 1;
  bool _isLoadingMore = false;
  Timer? _debounce;

  String get _category => widget.category;

  @override
  void initState() {
    super.initState();
    // nếu có seed từ trang trước thì _page = 1 là hợp lý; các lệnh fetch thêm sẽ tăng dần
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;
    if (!_controller.hasClients) return;

    final threshold = 300.0; // px trước đáy
    final position = _controller.position;
    final shouldLoadMore = position.pixels >= position.maxScrollExtent - threshold;

    if (!shouldLoadMore) return;

    // Debounce để tránh spam
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _loadMore();
    });
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore) return;
    setState(() => _isLoadingMore = true);

    _page += 1;
    final movieCubit = context.read<MovieCubit>();

    switch (widget.slug) {
      case 'phim-le':
        await movieCubit.getAListOfIndividualMovies(_page);
        break;
      case 'hoat-hinh':
        await movieCubit.getTheListOfCartoons(_page);
        break;
      case 'phim-bo':
        await movieCubit.getTheListOfMoviesAndSeries(_page);
        break;
      case 'the-loai':
        await movieCubit.getTheListOfCategory(_category, _page);
        break;
      default:
        break;
    }

    if (mounted) {
      setState(() => _isLoadingMore = false);
    }
  }

  Future<void> _onRefresh() async {
    // reset về trang 1 và gọi lại (giữ logic gọi Cubit như cũ)
    _page = 1;
    final movieCubit = context.read<MovieCubit>();
    switch (widget.slug) {
      case 'phim-le':
      // có thể clear list trong Cubit trước, nhưng để nguyên logic hiện tại: gọi page 1
        await movieCubit.getAListOfIndividualMovies(_page);
        break;
      case 'hoat-hinh':
        await movieCubit.getTheListOfCartoons(_page);
        break;
      case 'phim-bo':
        await movieCubit.getTheListOfMoviesAndSeries(_page);
        break;
      case 'the-loai':
        await movieCubit.getTheListOfCategory(_category, _page);
        break;
    }
  }

  List<MovieInformation> _selectList(MovieState state) {
    // Lấy danh sách “sống” từ state để thấy item mới khi load-more
    switch (widget.slug) {
      case 'phim-le':
        return state.singleMovies;
      case 'hoat-hinh':
        return state.cartoon;
      case 'phim-bo':
        return state.seriesMovies;
      case 'the-loai':
        return state.categoryMovies;
      default:
      // fallback: dùng seed truyền vào
        return widget.itemFilms;
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.primary,
      body: Column(
        children: [
          HeaderTitleApp(
            onTap: () => Navigator.pop(context),
            title: widget.title,
          ),
          Expanded(
            child: BlocBuilder<MovieCubit, MovieState>(
              builder: (context, state) {
                final list = _selectList(state);

                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        app!.movieListIsEmpty,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  color: theme.colorScheme.onPrimary,
                  backgroundColor: theme.colorScheme.surface,
                  onRefresh: _onRefresh,
                  child: CustomScrollView(
                    controller: _controller,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        sliver: SliverList.separated(
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSize.size16),
                          itemBuilder: (context, index) {
                            final item = list[index];
                            return _MovieRowCard(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => WatchAMovie(movieInformation: item),
                                    ),
                                  );
                                },
                                child: ItemMovieInformation(
                                  movieInformation: item,
                                  isThumb: true,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Footer loading khi đang tải thêm
                      SliverToBoxAdapter(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _isLoadingMore
                              ? Padding(
                            padding: const EdgeInsets.only(bottom: 20, top: 8),
                            child: Center(
                              child: SizedBox(
                                height: 28,
                                width: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.6,
                                  valueColor: AlwaysStoppedAnimation(theme.colorScheme.onPrimary),
                                ),
                              ),
                            ),
                          )
                              : const SizedBox(height: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MovieRowCard extends StatelessWidget {
  const _MovieRowCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.18)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: child,
        ),
      ),
    );
  }
}
