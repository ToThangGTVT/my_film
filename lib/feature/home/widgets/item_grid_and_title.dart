import 'dart:math';
import 'package:app/config/app_size.dart';
import 'package:app/feature/home/models/movie_information.dart';
import 'package:app/feature/home/movie_list.dart';
import 'package:app/feature/home/watch_a_movie.dart';
import 'package:app/l10n/cubit/locale_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shimmer/shimmer.dart';

import '../../../l10n/app_localizations.dart';
import '../cubit/movie/movie_cubit.dart';

// ignore: must_be_immutable
class ItemGridAndTitle extends StatefulWidget {
  ItemGridAndTitle({
    super.key,
    required this.itemFilms,
    required this.title,
    required this.slug,
  });

  List<MovieInformation> itemFilms;
  final String title;
  final String slug;

  @override
  State<ItemGridAndTitle> createState() => _ItemGridAndTitleState();
}

class _ItemGridAndTitleState extends State<ItemGridAndTitle> {
  bool isDetail = false;
  int itemCount = 12; // giữ logic cũ: 12 -> 21 khi xem thêm

  @override
  Widget build(BuildContext context) {
    final movieCubit = context.read<MovieCubit>();
    final theme = Theme.of(context);
    final app = AppLocalizations.of(context);

    if (widget.itemFilms.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final isEnglish = context.watch<LocaleCubit>().state.languageCode == 'en';
    final showCount = min(itemCount, widget.itemFilms.length); // tránh out of range

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
        child: Column(
          children: [
            // Header + See more
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MovieList(
                      itemFilms: widget.itemFilms,
                      title: widget.title,
                      slug: widget.slug,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: AppSize.size20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(app?.seeMore ?? "See more",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimary,
                        )),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward_ios_rounded,
                        size: 16, color: theme.colorScheme.onPrimary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: showCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.58, // hợp với poster 2:3 + 2 dòng tiêu đề
              ),
              itemBuilder: (context, index) {
                final item = widget.itemFilms[index];
                final title =
                isEnglish ? (item.origin_name) : (item.name);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      movieCubit.addToWatchHistory(itemFilm: item);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WatchAMovie(movieInformation: item),
                        ),
                      );
                    },
                    child: Ink(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Poster
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  CachedNetworkImage(
                                    imageUrl: item.poster_url,
                                    fit: BoxFit.cover,
                                    errorWidget: (ctx, url, error) => Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        color: theme.colorScheme.tertiary,
                                      ),
                                    ),
                                  ),
                                  // Overlay giúp text rõ nếu cần
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.35),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Title
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.2,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Xem thêm / Thu gọn
            GestureDetector(
              onTap: () {
                isDetail = !isDetail;
                itemCount = isDetail ? 21 : 12; // giữ như logic cũ
                setState(() {});
              },
              child: Container(
                alignment: Alignment.center,
                height: 36,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isDetail ? (app?.hideLess ?? "Hide") : (app?.seeMore ?? "See more"),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ItemGridAndTitleShimmer extends StatefulWidget {
  const ItemGridAndTitleShimmer({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<ItemGridAndTitleShimmer> createState() =>
      _ItemGridAndTitleShimmerState();
}

class _ItemGridAndTitleShimmerState extends State<ItemGridAndTitleShimmer> {
  bool isDetail = false;
  int itemCount = 9;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = AppLocalizations.of(context);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 10),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: AppSize.size20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/chevron-right.svg',
                    color: theme.colorScheme.tertiary,
                    width: 16,
                    height: 16,
                  )
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Grid shimmer
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itemCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.58,
              ),
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.18),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12)),
                            child: Container(color: Colors.grey),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(6, 6, 6, 8),
                          child: Column(
                            children: [
                              Container(
                                height: 10,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                height: 10,
                                width: 90,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Nút xem thêm (shimmer không cần toggle)
            Container
              (
              alignment: Alignment.center,
              height: 36,
              width: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isDetail ? (app?.hideLess ?? "Hide") : (app?.seeMore ?? "See more"),
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}
