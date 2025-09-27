import 'package:app/component/loading_widget.dart';
import 'package:app/config/app_size.dart';
import 'package:app/feature/home/models/data_film.dart';
import 'package:app/feature/home/models/movie_category.dart';
import 'package:app/feature/home/models/movie_episodes.dart';
import 'package:app/feature/home/models/movie_information.dart';
import 'package:app/feature/home/widgets/video_player_controll.dart';
import 'package:app/l10n/cubit/locale_cubit.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../../l10n/app_localizations.dart';
import '../cubit/movie/movie_cubit.dart';
import '../cubit/movie/movie_state.dart';
import '../movie_list.dart';

// ignore: must_be_immutable
class VideoPlayerWidget extends StatefulWidget {
  VideoPlayerWidget({
    super.key,
    required this.url,
    required this.dataFilm,
    required this.movieInformation,
  });

  final String url;
  final DataFilm? dataFilm;
  MovieInformation? movieInformation;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  // --- Chewie + video_player ---
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _playerReady = false;

  // --- Nội dung mô tả rút gọn ---
  bool isHidden = false;
  bool isCheckHidden = true;
  List<String> _items = [];
  String _summaryContent = '';

  @override
  void initState() {
    super.initState();
    _splitContentOnce();
    _initChewie(widget.url);
  }

  Future<void> _initChewie(String url) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoInitialize: true,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Theme.of(context).colorScheme.onPrimary,
        handleColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.18),
        bufferedColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
      ),
    );

    setState(() {
      _playerReady = true;
    });
  }

  Future<void> _playNewUrl(String url) async {
    final newController = VideoPlayerController.networkUrl(Uri.parse(url));
    await newController.initialize();

    // Dispose cũ
    _chewieController?.dispose();
    _videoController.dispose();

    // Assign mới
    _videoController = newController;
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoInitialize: true,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      allowFullScreen: true,
      allowMuting: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Theme.of(context).colorScheme.onPrimary,
        handleColor: Theme.of(context).colorScheme.onPrimary,
        backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.18),
        bufferedColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.25),
      ),
    );

    setState(() {});
  }

  void _splitContentOnce() {
    final content = widget.dataFilm?.movie.content ?? '';
    _items = content.split(' ');
    if (_items.length >= 50) {
      isCheckHidden = false;
      isHidden = true;
      _summaryContent = _items.take(35).join(' ') + ' ...';
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeCubit = context.watch<LocaleCubit>();
    final theme = Theme.of(context);
    final movieCubit = context.read<MovieCubit>();
    final app = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _VideoPlayerSurface(
          chewieController: _chewieController,
        ),

        // Info + meta
        Expanded(
          child: Container(
            color: theme.colorScheme.primary,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: theme.colorScheme.outline.withOpacity(0.2), height: 12),

                        // Title + favorite
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center, // 👈 căn giữa theo chiều dọc
                          children: [
                            Expanded(
                              child: Text(
                                localeCubit.state.languageCode == 'vi'
                                    ? widget.dataFilm!.movie.name
                                    : widget.dataFilm!.movie.origin_name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 20,
                                  height: 1.2,
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () {
                                if (widget.movieInformation!.isFavorite == false) {
                                  movieCubit.addMoviesToFavoritesList(itemFilm: widget.movieInformation);
                                } else {
                                  movieCubit.removeMoviesToFavoritesList(itemFilm: widget.movieInformation);
                                }
                                setState(() {
                                  widget.movieInformation!.isFavorite = !widget.movieInformation!.isFavorite;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: widget.movieInformation!.isFavorite
                                      ? theme.colorScheme.onPrimary.withOpacity(0.16)
                                      : theme.colorScheme.surface.withOpacity(0.5),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withOpacity(0.25),
                                  ),
                                ),
                                child: Icon(
                                  Icons.favorite_rounded,
                                  size: AppSize.size24,
                                  color: widget.movieInformation!.isFavorite
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.tertiary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        Divider(color: theme.colorScheme.outline.withOpacity(0.2), height: 16),

                        // Episodes picker (nếu nhiều)
                        if (widget.dataFilm!.episodes[0].server_data.length > 1)
                          _EpisodeNumberOfTheMovie(
                            items: widget.dataFilm!.episodes,
                            onSelect: (link) => _playNewUrl(link),
                          ),

                        const SizedBox(height: 8),

                        // Content
                        _TitleAndContentCard(
                          title: app!.content,
                          content: isHidden ? _summaryContent : (widget.dataFilm!.movie.content),
                          trailing: isCheckHidden
                              ? null
                              : TextButton(
                            onPressed: () => setState(() => isHidden = !isHidden),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: const Size(0, 0),
                            ),
                            child: Text(
                              isHidden ? (app.seeMore) : (app.hideLess),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Actors
                        _ContentActor(items: widget.dataFilm?.movie.actor ?? []),

                        const SizedBox(height: 10),

                        // Categories
                        _ContentCategory(items: widget.dataFilm!.movie.category),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VideoPlayerSurface extends StatelessWidget {
  const _VideoPlayerSurface({
    required this.chewieController,
  });

  final ChewieController? chewieController;

  double _resolveAspect() {
    // Ưu tiên AR của Chewie, rồi tới AR của video, cuối cùng 16:9
    final cc = chewieController;
    if (cc == null) return 16 / 9;

    final arChewie = cc.aspectRatio;
    if (arChewie != null && arChewie > 0) return arChewie;

    final vc = cc.videoPlayerController;
    final v = vc.value;
    if (v.isInitialized && v.aspectRatio > 0) return v.aspectRatio;

    return 16 / 9;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    if (chewieController == null) {
      // Fallback loading
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: theme.colorScheme.surfaceVariant,
          child: const Center(child: LoadingWidget()),
        ),
      );
    }

    final vc = chewieController!.videoPlayerController;
    final isReady = vc.value.isInitialized;

    // Dọc: luôn cố định 16:9
    if (isPortrait) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: isReady
            ? Chewie(controller: chewieController!)
            : ColoredBox(
          color: theme.colorScheme.surfaceVariant,
          child: const Center(child: LoadingWidget()),
        ),
      );
    }

    // Ngang: như hiện tại (dựa theo aspect thực tế)
    final ar = _resolveAspect();
    return AspectRatio(
      aspectRatio: ar,
      child: isReady
          ? Chewie(controller: chewieController!)
          : ColoredBox(
        color: theme.colorScheme.surfaceVariant,
        child: const Center(child: LoadingWidget()),
      ),
    );
  }
}


class _EpisodeNumberOfTheMovie extends StatefulWidget {
  const _EpisodeNumberOfTheMovie({
    super.key,
    required this.items,
    required this.onSelect,
  });

  final List<MovieEpisodes> items;
  final ValueChanged<String> onSelect; // nhận link m3u8

  @override
  State<_EpisodeNumberOfTheMovie> createState() => _EpisodeNumberOfTheMovieState();
}

class _EpisodeNumberOfTheMovieState extends State<_EpisodeNumberOfTheMovie> {
  int indexSelected = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = widget.items[0].server_data.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.episode,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: AppSize.size16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final isActive = indexSelected == index;
            return InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                if (!isActive) {
                  setState(() => indexSelected = index);
                  final link = widget.items[0].server_data[index].link_m3u8;
                  widget.onSelect(link);
                }
              },
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: isActive
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.surfaceVariant,
                  border: Border.all(
                    color: isActive
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: isActive
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ignore: camel_case_types
class _ContentActor extends StatelessWidget {
  const _ContentActor({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chips = items.map((name) {
      return Chip(
        label: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.colorScheme.surface.withOpacity(0.6),
        side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.actor,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: AppSize.size16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips,
        ),
      ],
    );
  }
}

// ignore: camel_case_types
class _ContentCategory extends StatelessWidget {
  const _ContentCategory({super.key, required this.items});

  final List<MovieCategory> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.category,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: AppSize.size16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            items.length,
                (index) => InputChip(
              backgroundColor: theme.colorScheme.surface.withOpacity(0.7),
              side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.25)),
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              label: Text(
                items[index].name,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              selectedColor: theme.colorScheme.onPrimary.withOpacity(0.15),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      var movieCubit = context.read<MovieCubit>();
                      movieCubit.getTheListOfCategory(items[index].slug, 0);
                      return BlocBuilder<MovieCubit, MovieState>(
                        builder: (context, state) {
                          return MovieList(
                            itemFilms: state.categoryMovies,
                            title: 'Thể loại ${items[index].name}',
                            slug: 'the-loai',
                            category: items[index].slug,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TitleAndContentCard extends StatelessWidget {
  const _TitleAndContentCard({super.key, this.title = '', this.content = '', this.trailing});

  final String title;
  final String content;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: MediaQuery.of(context).size.width - 24,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + (Xem thêm)
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: AppSize.size16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: TextStyle(color: theme.colorScheme.onSurface, height: 1.35),
          ),
        ],
      ),
    );
  }
}

/* --- helpers cũ nếu cần giữ lại ---
double handleWidthCategory(List items, BuildContext context) { ... }
double handleWidthActor(List items, BuildContext context) { ... }
*/
