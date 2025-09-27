// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/movie_information.dart';

@immutable
class ItemMovieInformation extends StatelessWidget {
  ItemMovieInformation({
    super.key,
    required this.movieInformation,
    required this.isThumb,
  });

  final MovieInformation movieInformation;
  final bool isThumb;

  late final String imageUrl = isThumb ? movieInformation.thumb_url : movieInformation.poster_url;
  late final String name = movieInformation.name;
  late final String year = movieInformation.year.toString();
  late final String time = movieInformation.time;
  late final String quality = movieInformation.quality;

  // Kích thước cố định cho item (giúp Row/Spacer có kích thước hữu hạn)
  static const double posterWidth = 86;
  static const double posterHeight = 120;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const double radius = 12;

    return Container(
      // Viền & bo góc ở NGOÀI để border hiện đủ 4 cạnh
      decoration: ShapeDecoration(
        color: cs.surface.withOpacity(0.55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: cs.outline.withOpacity(0.14)),
        ),
      ),
      height: posterHeight, // ràng buộc chiều cao item
      child: ClipRRect(
        // Clip NỘI DUNG theo cùng bán kính
        borderRadius: BorderRadius.circular(radius),
        child: Row(
          children: [
            // Poster + badge
            Stack(
              children: [
                // Poster + border riêng
                Container(
                  width: posterWidth,
                  height: posterHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: cs.outline.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: Colors.black12),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: Icon(Icons.image_not_supported_outlined, color: cs.tertiary),
                      ),
                    ),
                  ),
                ),

                // Quality badge
                Positioned(
                  left: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.onPrimary.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      quality,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // vạch ngăn cách mảnh
            Container(
              width: 1,
              height: posterHeight,
              color: cs.outline.withOpacity(0.08),
            ),

            // Nội dung
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // căn giữa dọc
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 14.5,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      time,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.tertiary,
                        fontSize: 12.5,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: cs.onPrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: cs.outline.withOpacity(0.18)),
                      ),
                      child: Text(
                        year,
                        style: TextStyle(
                          color: cs.onSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
