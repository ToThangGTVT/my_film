import 'package:app/component/loading_widget.dart';
import 'package:app/feature/home/models/movie_information.dart';
import 'package:app/feature/home/widgets/video_player_widget.dart';
import 'package:app/l10n/cubit/locale_cubit.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import 'cubit/movie/movie_cubit.dart';
import 'cubit/movie/movie_state.dart';

class WatchAMovie extends StatefulWidget {
  const WatchAMovie({super.key, required this.movieInformation});
  final MovieInformation? movieInformation;

  @override
  State<WatchAMovie> createState() => _WatchAMovieState();
}

class _WatchAMovieState extends State<WatchAMovie> {
  late MovieCubit movieCubit;
  late LocaleCubit localeCubit;

  bool isLoading = true;
  String linkPlay = '';

  @override
  void initState() {
    super.initState();
    movieCubit = context.read<MovieCubit>();
    localeCubit = context.read<LocaleCubit>();
    _fetchDetailsAndPrepare();
  }

  Future<void> _fetchDetailsAndPrepare() async {
    // Thứ tự call API: gọi getMovieDetails trước, set linkPlay sau → rồi mới tắt loading
    await movieCubit.getMovieDetails(
      widget.movieInformation!.slug,
      localeCubit.state.languageCode,
    );

    if (!mounted) return;
    final dataFilm = movieCubit.state.dataFilm;

    if (dataFilm != null) {
      linkPlay = _pickFirstPlayableUrl();
    }
    setState(() {
      isLoading = false;
    });
  }

  String _pickFirstPlayableUrl() {
    final dataFilm = movieCubit.state.dataFilm;
    if (dataFilm == null) return '';

    // Chọn link đầu tiên hợp lệ (phòng khi mảng rỗng/null)
    for (final ep in dataFilm.episodes) {
      for (final sd in ep.server_data) {
        final url = sd.link_m3u8;
        if ((url).toString().trim().isNotEmpty) {
          return url;
        }
      }
    }
    return '';
  }

  void _showExitHint() {
    CherryToast.info(
      title: const Text("Tips", style: TextStyle(color: Colors.black)),
      action: Text(
        AppLocalizations.of(context)?.pressTheButtonToExit ?? "",
        style: const TextStyle(color: Colors.black),
      ),
      actionHandler: () {},
    ).show(context); // Quan trọng: phải .show(context)
  }

  Future<bool> _onWillPop() async {
    _showExitHint();
    return false; // chặn back vật lý, user bấm nút back trên UI để thoát
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: BlocBuilder<MovieCubit, MovieState>(
        builder: (context, state) {
          final dataFilm = state.dataFilm;

          return Scaffold(
            backgroundColor: theme.colorScheme.primary,
            body: isLoading
                ? const Center(child: LoadingWidget())
                : dataFilm == null
                ? _movieUpdating(context)
                : WillPopScope(
              onWillPop: _onWillPop,
              child: Stack(
                children: [
                  // Video player
                  VideoPlayerWidget(
                    movieInformation: widget.movieInformation,
                    url: linkPlay,
                    dataFilm: dataFilm,
                  ),

                  // Top gradient để icon back dễ đọc trên nền video
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(
                      ignoring: true,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Back button
                  Positioned(
                    left: 16,
                    top: 16,
                    child: _BackButton(onTap: () {
                      Navigator.pop(context);
                    }),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _movieUpdating(BuildContext context) {
    final app = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.live_tv_outlined, size: 64, color: theme.colorScheme.tertiary),
            const SizedBox(height: 16),
            Text(
              app!.movieUpdate,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(app.ok),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
