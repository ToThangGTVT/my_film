import 'dart:async';
import 'dart:ui';
import 'package:app/config/app_size.dart';
import 'package:app/feature/home/models/movie_information.dart';
import 'package:app/feature/home/movie_list.dart';
import 'package:app/feature/home/watch_a_movie.dart';
import 'package:app/feature/home/widgets/item_film_horizontally.dart';
import 'package:app/feature/home/widgets/item_grid_and_title.dart';
import 'package:app/feature/home/widgets/item_slider_image.dart';
import 'package:app/feature/home/search_movie.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../l10n/app_localizations.dart';
import 'cubit/home_page/home_page_cubit.dart';
import 'cubit/home_page/home_page_state.dart';
import 'cubit/movie/movie_cubit.dart';
import 'cubit/movie/movie_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MovieCubit movieCubit;
  late HomePageCubit homePageCubit;

  Future<void> permissionHandle() async {
    if (await Permission.notification.request().isDenied) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (context) {
          final theme = Theme.of(context);
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.notifications_active_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(AppLocalizations.of(context)!.notification),
              ],
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(AppLocalizations.of(context)!.allowAppsToAccessNotifications),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.tertiary,
                ),
                child: Text(AppLocalizations.of(context)!.cancel),
                onPressed: () {
                  homePageCubit.notificationsEnabled();
                  Navigator.of(context).pop();
                },
              ),
              FilledButton.tonal(
                child: Text(AppLocalizations.of(context)!.ok),
                onPressed: () {
                  homePageCubit.notificationsEnabled();
                  Navigator.of(context).pop();
                  openAppSettings();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> checkStatusNetwork() async {
    homePageCubit.checkNetwork().then((value) async => {
      if (homePageCubit.state.isConnectNetwork == false)
        {
          Future.delayed(const Duration(seconds: 1), () {
            checkStatusNetwork();
          }),
        }
      else
        {
          await initialization(),
          Future.delayed(const Duration(seconds: 1), () {
            homePageCubit.loadingHomeIsFalse();
          }),
        }
    });
  }

  @override
  void initState() {
    super.initState();
    movieCubit = context.read<MovieCubit>();
    homePageCubit = context.read<HomePageCubit>();
    homePageCubit.state.isNotification ? {} : permissionHandle();
    checkStatusNetwork();
  }

  Future<void> initialization() async {
    movieCubit.getMovie(1);
    movieCubit.getAListOfIndividualMovies(1);
    movieCubit.getTheListOfMoviesAndSeries(1);
    movieCubit.getTheListOfCartoons(1);
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async => false,
      child: DecoratedBox(
        // Nền có gradient nhẹ
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.96),
              theme.colorScheme.primary.withOpacity(0.98),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocBuilder<HomePageCubit, HomePageState>(
          builder: (context, state) {
            final isOffline = context.read<HomePageCubit>().state.isConnectNetwork == false;
            if (isOffline) {
              return _offlineView(context);
            }

            if (context.watch<HomePageCubit>().state.isLoadingHome) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                appBar: _appBar(context, _scrollController),
                body: _bodyShimmer(context),
              );
            }

            return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: _appBar(context, _scrollController),
              body: BlocBuilder<MovieCubit, MovieState>(
                builder: (context, state) {
                  final theme = Theme.of(context);
                  return RefreshIndicator(
                    color: theme.colorScheme.onPrimary,
                    backgroundColor: theme.colorScheme.surface,
                    onRefresh: initialization,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      controller: _scrollController,
                      slivers: [
                        // Banner slider
                        _HeroSlider(state: state),

                        // Indicator
                        _SliderIndicator(movieCount: state.movies.length),

                        // Phim lẻ
                        ItemGridAndTitle(
                          itemFilms: state.singleMovies,
                          title: AppLocalizations.of(context)?.singleMovie ?? '',
                          slug: 'phim-le',
                        ),

                        // Hoạt hình
                        ItemGridAndTitle(
                          itemFilms: state.cartoon,
                          title: AppLocalizations.of(context)?.cartoon ?? '',
                          slug: 'hoat-hinh',
                        ),

                        // Phim bộ
                        ItemGridAndTitle(
                          itemFilms: state.seriesMovies,
                          title: AppLocalizations.of(context)?.seriesMovie ?? '',
                          slug: 'phim-bo',
                        ),

                        const SliverToBoxAdapter(child: SizedBox(height: 32)),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _offlineView(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off_rounded, size: 72, color: theme.colorScheme.tertiary),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.noNetworkConnection,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.allowAppsToAccessNotifications,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton.tonalIcon(
                          onPressed: checkStatusNetwork,
                          icon: const Icon(Icons.refresh),
                          label: Text(AppLocalizations.of(context)!.ok),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroSlider extends StatelessWidget {
  const _HeroSlider({required this.state});
  final MovieState state;

  @override
  Widget build(BuildContext context) {
    if (state.movies.isEmpty) return const SliverToBoxAdapter();
    final theme = Theme.of(context);
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final movieCubit = context.read<MovieCubit>();
    final homePageCubit = context.read<HomePageCubit>();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: SizedBox(
          height: height * 0.26,
          width: width,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: CarouselSlider.builder(
              itemCount: state.movies.length,
              itemBuilder: (context, i, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: _HeroCard(
                  imageUrl: state.movies[i].poster_url,
                  title: state.movies[i].name ?? '',
                  onTap: () {
                    movieCubit.addToWatchHistory(itemFilm: state.movies[i]);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WatchAMovie(movieInformation: state.movies[i]),
                      ),
                    );
                  },
                ),
              ),
              options: CarouselOptions(
                autoPlay: true,
                autoPlayCurve: Curves.easeInOutCubic,
                enlargeCenterPage: true,
                autoPlayInterval: const Duration(seconds: 6),
                viewportFraction: 0.4,
                onPageChanged: (index, reason) => homePageCubit.setPageIndex(index),
                aspectRatio: 9 / 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.imageUrl,
    required this.title,
    required this.onTap,
  });

  final String? imageUrl;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ItemSliderImage(imageUrl: imageUrl ?? "", onTap: () {  },),
            // overlay gradient để chữ nổi bật hơn
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.8)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Tiêu đề
            Positioned(
              left: 14,
              right: 14,
              bottom: 12,
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderIndicator extends StatelessWidget {
  const _SliderIndicator({required this.movieCount});
  final int movieCount;

  @override
  Widget build(BuildContext context) {
    if (movieCount == 0) return const SliverToBoxAdapter();

    final theme = Theme.of(context);
    final home = context.watch<HomePageCubit>();
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.25)),
            ),
            child: SmoothPageIndicator(
              controller: PageController(initialPage: home.state.currentIndexPage),
              count: movieCount,
              effect: WormEffect(
                dotWidth: 6,
                dotHeight: 6,
                spacing: 6,
                paintStyle: PaintingStyle.fill,
                activeDotColor: theme.colorScheme.onPrimary,
                dotColor: theme.colorScheme.onSurface.withOpacity(0.25),
              ),
              onDotClicked: (_) {},
            ),
          ),
        ),
      ),
    );
  }
}

Widget _bodyShimmer(BuildContext context) {
  final theme = Theme.of(context);
  final height = MediaQuery.of(context).size.height;
  final width = MediaQuery.of(context).size.width;

  Widget shimmerBox({double? h, double? w, BorderRadius? radius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: h,
        width: w,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: radius ?? BorderRadius.circular(16),
        ),
      ),
    );
  }

  return CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Container(
            height: height * 0.26,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.surface.withOpacity(0.15),
                  theme.colorScheme.surface.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: CarouselSlider.builder(
              itemCount: 5,
              itemBuilder: (context, i, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: shimmerBox(h: double.infinity, w: double.infinity, radius: BorderRadius.circular(22)),
              ),
              options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 0.8,
                aspectRatio: 16 / 9,
              ),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Center(
            child: shimmerBox(h: 18, w: 120, radius: BorderRadius.circular(12)),
          ),
        ),
      ),
      // Section 1
      ItemGridAndTitleShimmer(title: AppLocalizations.of(context)?.singleMovie ?? ''),
      // Section 2
      TitleAndChevronRightShimmer(
        title: AppLocalizations.of(context)?.cartoon ?? '',
        color: theme.colorScheme.tertiary,
      ),
      const ItemFilmHorizontallyShimmer(),
      // Section 3
      ItemGridAndTitleShimmer(title: AppLocalizations.of(context)?.seriesMovie ?? ''),
      const SliverToBoxAdapter(child: SizedBox(height: 30)),
    ],
  );
}

AppBar _appBar(BuildContext context, ScrollController scrollController) {
  final theme = Theme.of(context);
  final width = MediaQuery.of(context).size.width;
  final app = AppLocalizations.of(context);

  return AppBar(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    automaticallyImplyLeading: false,
    titleSpacing: 12,
    title: SafeArea(
      bottom: false,
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              scrollController.animateTo(
                0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: Ink(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.25)),
              ),
              child: const Icon(Icons.movie_creation_outlined, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    child: const SearchMovie(),
                    type: PageTransitionType.leftToRight,
                  ),
                );
              },
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.25)),
                ),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(Icons.search, size: 18, color: theme.colorScheme.tertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        app?.search ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppSize.size14,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.tertiary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.tune_rounded, size: 16, color: theme.colorScheme.tertiary.withOpacity(0.8)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class TitleAndChevronRight extends StatelessWidget {
  const TitleAndChevronRight({
    super.key,
    this.title = '',
    this.slug = '',
    this.color = Colors.black,
    this.itemFilms = const [],
  });

  final String title;
  final String slug;
  final Color color;
  final List<MovieInformation> itemFilms;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverPadding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 26, bottom: 10),
      sliver: SliverToBoxAdapter(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MovieList(
                  itemFilms: itemFilms,
                  title: title,
                  slug: slug,
                ),
              ),
            );
          },
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppSize.size20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Text(
                      "See more",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TitleAndChevronRightShimmer extends StatelessWidget {
  const TitleAndChevronRightShimmer({super.key, this.title = '', this.color = Colors.black});

  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 26, bottom: 10),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: AppSize.size20, fontWeight: FontWeight.w700),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  Text(
                    "…",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  SvgPicture.asset('assets/icons/chevron-right.svg', color: color, height: 14),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
