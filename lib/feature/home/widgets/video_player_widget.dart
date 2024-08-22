import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:app/component/loading_widget.dart';
import 'package:app/config/app_size.dart';
import 'package:app/config/print_color.dart';
import 'package:app/feature/home/cubit/movie_download/movie_download_cubit.dart';
import 'package:app/feature/home/cubit/movie_download/movie_download_state.dart';
import 'package:app/feature/home/models/data_film.dart';
import 'package:app/feature/home/models/movie_category.dart';
import 'package:app/feature/home/models/movie_episodes.dart';
import 'package:app/feature/home/models/movie_information.dart';
import 'package:app/l10n/cubit/locale_cubit.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:m3u8_downloader/m3u8_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../cubit/movie/movie_cubit.dart';
// ignore: must_be_immutable
class VideoPlayerWidget extends StatefulWidget {
  VideoPlayerWidget(
      {super.key,
      required this.url,
      required this.dataFilm,
      required this.movieInformation});
  final String url;
  final DataFilm? dataFilm;
  MovieInformation? movieInformation;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late FlickManager flickManager;
  bool isHidden = false;
  bool isCheckHidden = true;
  List<String> items = [];
  List<String> beginningOfContent = [];
  String summaryContent = '';
  final ReceivePort _port = ReceivePort();
  late final MovieDownloadCubit movieDownloadCubit;

  void splitContent() {
    // làm chức năng chia nhỏ content để hiện 1 phần
    setState(() {
      items = widget.dataFilm!.movie.content.split(' ');
      if (items.length >= 50) {
        isCheckHidden = false;
        isHidden = true;
        for (var i = 0; i < 35; i++) {
          beginningOfContent.add(items[i]);
        }
        summaryContent = beginningOfContent.join(' ');
        summaryContent = '$summaryContent ...';
        printYellow(summaryContent);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    splitContent();

    flickManager = FlickManager(
      autoPlay: true,
      autoInitialize: true,
      videoPlayerController: VideoPlayerController.networkUrl(
        Uri.parse(widget.url),
      ),
    );

    movieDownloadCubit = context.watch<MovieDownloadCubit>();
    movieDownloadCubit.initAsync();
  }

  Future<bool> _checkPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final LocaleCubit localeCubit = context.watch<LocaleCubit>();
    final double height = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final MovieCubit movieCubit = context.read<MovieCubit>();
    final MovieDownloadCubit movieDownloadCubit = context.watch<MovieDownloadCubit>();
    final app = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VideoPlayer(height: height, flickManager: flickManager),
        Container(
          color: theme.colorScheme.primary,
          padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
          height: height - (height * 0.3 + 32),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.film,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: AppSize.size16),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        if (widget.movieInformation!.isFavorite == false) {
                          movieCubit.addMoviesToFavoritesList(
                              itemFilm: widget.movieInformation);
                        } else {
                          movieCubit.removeMoviesToFavoritesList(
                              itemFilm: widget.movieInformation);
                        }
                        setState(() {
                          widget.movieInformation!.isFavorite =
                              !widget.movieInformation!.isFavorite;
                        });
                      },
                      child: Icon(
                        Icons.favorite_rounded,
                        size: AppSize.size28,
                        color: widget.movieInformation!.isFavorite
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        _checkPermission().then((hasGranted) async {
                        if (hasGranted) {
                          await M3u8Downloader.config(
                            convertMp4: true,
                          );

                          movieDownloadCubit.download(widget.url, widget.dataFilm?.movie.origin_name);
                        }
                        });
                      },
                      child: Icon(
                        Icons.arrow_circle_down_rounded,
                        size: AppSize.size28,
                        color: widget.movieInformation!.isFavorite
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    BlocBuilder<MovieDownloadCubit, MovieDownloadState>(
                      builder: (context, state) {
                      return Text(state.progress.toString());
                    },)
                  ],
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    localeCubit.state.languageCode == 'vi'
                        ? widget.dataFilm!.movie.name
                        : widget.dataFilm!.movie.origin_name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                widget.dataFilm!.episodes[0].server_data.length == 1
                    ? const SizedBox()
                    : EpisodeNumberOfTheMovie(
                        flickManager: flickManager,
                        items: widget.dataFilm!.episodes,
                      ),
                const SizedBox(
                  height: 10,
                ),
                TitleAndContent(
                    title: AppLocalizations.of(context)!.content,
                    content: isHidden
                        ? summaryContent
                        : widget.dataFilm!.movie.content),
                const SizedBox(
                  height: 5,
                ),
                isCheckHidden
                    ? const SizedBox()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isHidden = !isHidden;
                              });
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.25,
                              height: 20,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Text(
                                isHidden ? app!.seeMore : app!.hideLess,
                                style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: AppSize.size11),
                              ),
                            ),
                          )
                        ],
                      ),
                const SizedBox(
                  height: 10,
                ),
                ContentActor(items: widget.dataFilm?.movie.actor ?? []),
                const SizedBox(
                  height: 10,
                ),
                ContentCategory(items: widget.dataFilm!.movie.category),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class VideoPlayer extends StatelessWidget {
  const VideoPlayer({
    super.key,
    required this.height,
    required this.flickManager,
  });

  final double height;
  final FlickManager flickManager;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height * 0.3,
      child: FlickVideoPlayer(
        wakelockEnabled: true,
        flickManager: flickManager,
        flickVideoWithControls: FlickVideoWithControls(
          aspectRatioWhenLoading: 16 / 9,
          videoFit: BoxFit.fitWidth,
          controls: FlickPortraitControls(
            iconSize: 30,
            progressBarSettings: FlickProgressBarSettings(
              bufferedColor: Colors.white.withOpacity(0.5),
              playedColor: Colors.red,
              height: 4,
              handleRadius: 9,
              handleColor: Colors.red,
            ),
          ),
          playerLoadingFallback: const LoadingWidget(),
        ),
      ),
    );
  }
}

class EpisodeNumberOfTheMovie extends StatefulWidget {
  const EpisodeNumberOfTheMovie(
      {super.key, required this.items, required this.flickManager});

  final List<MovieEpisodes> items;
  final FlickManager flickManager;

  @override
  State<EpisodeNumberOfTheMovie> createState() =>
      _EpisodeNumberOfTheMovieState();
}

class _EpisodeNumberOfTheMovieState extends State<EpisodeNumberOfTheMovie> {
  int indexSelected = 0;

  void playNewVideo(FlickManager flickManager, String url) {
    setState(() {
      flickManager
          .handleChangeVideo(VideoPlayerController.networkUrl(Uri.parse(url)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.episode,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: AppSize.size16),
        ),
        const SizedBox(
          height: 10,
        ),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.items[0].server_data.length,
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 10,
              childAspectRatio: 0.8,
              mainAxisSpacing: 10),
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              if (indexSelected != index) {
                setState(() {
                  indexSelected = index;
                  print(indexSelected);
                });
                playNewVideo(widget.flickManager,
                    widget.items[0].server_data[index].link_m3u8);
              }
            },
            child: Container(
              alignment: Alignment.center,
              width: 2,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                color: indexSelected == index ? Colors.red : Colors.grey,
              ),
              child: Text('${index + 1}', style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),),
            ),
          ),
        ),
      ],
    );
  }
}

// ignore: camel_case_types
class ContentActor extends StatelessWidget {
  const ContentActor({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.actor,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: AppSize.size16),
        ),
        const SizedBox(
          height: 10,
        ),
        Wrap(
          spacing: 8.0, // Khoảng cách giữa các widget con
          runSpacing: 8.0, // Khoảng cách giữa các dòng
          alignment: WrapAlignment.center, // Căn giữa theo chiều ngang
          children: List.generate(
              items.length,
              (index) => Container(
                  alignment: Alignment.center,
                  width: handleWidthActor(items, context),
                  child: Text(items[index]))),
        )
      ],
    );
  }
}

// ignore: camel_case_types
class ContentCategory extends StatelessWidget {
  const ContentCategory({super.key, required this.items});

  final List<MovieCategory> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.category,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: AppSize.size16),
        ),
        const SizedBox(
          height: 10,
        ),
        Wrap(
          spacing: 8.0, // Khoảng cách giữa các widget con
          runSpacing: 8.0, // Khoảng cách giữa các dòng
          alignment: WrapAlignment.center, // Căn giữa theo chiều ngang
          children: List.generate(
              items.length,
              (index) => Container(
                  alignment: Alignment.center,
                  width: handleWidthCategory(items, context),
                  child: Text(items[index].name))),
        )
      ],
    );
  }
}

class TitleAndContent extends StatelessWidget {
  const TitleAndContent({super.key, this.title = '', this.content = ''});
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: AppSize.size16),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            textAlign: TextAlign.justify,
            content,
          ),
        ],
      ),
    );
  }
}

double handleWidthCategory(List items, BuildContext context) {
  double width = 0;
  if (items.length == 1) {
    width = MediaQuery.of(context).size.width - 20;
  } else if (items.length == 2) {
    width = (MediaQuery.of(context).size.width - 20) * 0.45;
  } else {
    width = (MediaQuery.of(context).size.width - 20) * 0.3;
  }
  return width;
}

double handleWidthActor(List items, BuildContext context) {
  double width = 0;
  if (items.length == 1) {
    width = MediaQuery.of(context).size.width - 0.95;
  } else {
    width = (MediaQuery.of(context).size.width - 20) * 0.45;
  }
  return width;
}
