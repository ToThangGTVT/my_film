import 'package:app/config/app_size.dart';
import 'package:app/feature/home/models/movie_information.dart';
import 'package:app/feature/home/movie_list.dart';
import 'package:app/l10n/cubit/locale_cubit.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ItemGridAndTitle extends StatefulWidget {
  ItemGridAndTitle({
    super.key,
    required this.itemFilms,
    required this.title,
  });
  final List<MovieInformation> itemFilms;
  final String title;

  @override
  State<ItemGridAndTitle> createState() => _ItemGridAndTitleState();
}

class _ItemGridAndTitleState extends State<ItemGridAndTitle> {
  bool isDetail = false;
  int itemCount = 6;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = AppLocalizations.of(context);

    return SliverToBoxAdapter(
      child: widget.itemFilms.isEmpty
          ? const SizedBox()
          : Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 30),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MovieList(
                                    itemFilms: widget.itemFilms,
                                    title: widget.title,
                                  )));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                              fontSize: AppSize.size20,
                              fontWeight: FontWeight.w600),
                        ),
                        SvgPicture.asset(
                          'assets/icons/chevron-right.svg',
                          color: Colors.red,
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.6,
                    ),
                    itemCount: itemCount, // Số lượng items trong grid view
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          context.goNamed('watchAMovie', queryParameters: {
                            'slug': widget.itemFilms[index].slug
                          });
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      'https://img.phimapi.com/${widget.itemFilms[index].poster_url}',
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
                                context
                                            .watch<LocaleCubit>()
                                            .state
                                            .languageCode ==
                                        'en'
                                    ? widget.itemFilms[index].origin_name
                                    : widget.itemFilms[index].name,
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
                  const SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      isDetail = !isDetail;

                      if (isDetail) {
                        itemCount = 12;
                      } else {
                        itemCount = 6;
                      }
                      setState(() {});
                    },
                    child: Container(
                      alignment: Alignment.center,
                      height: 30,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(isDetail ? app!.hideLess : app!.seeMore),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
