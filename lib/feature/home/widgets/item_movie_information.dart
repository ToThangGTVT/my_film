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

  // Giữ nguyên cách chọn URL
  late String imageUrl =
  isThumb ? movieInformation.thumb_url : movieInformation.poster_url;
  late String name = movieInformation.name;
  late String year = movieInformation.year.toString();
  late String time = movieInformation.time;
  late String quality = movieInformation.quality;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Kích thước khung item: poster 2:3 (~80x120) + phần nội dung linh hoạt
    const double posterWidth = 86;
    const double posterHeight = 120;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Poster + Quality badge
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
            child: Stack(
              children: [
                // Giữ tỉ lệ poster 2:3
                SizedBox(
                  width: posterWidth,
                  height: posterHeight,
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
                // Badge QUALITY (góc trái trên)
                Positioned(
                  left: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.onPrimary.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quality,
                      style: TextStyle(
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
          ),

          // Nội dung
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // canh giữa theo chiều dọc
                children: [
                  // Tên phim
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

                  // Thời lượng / tập
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

                  // Năm phát hành (chip nhỏ)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.onPrimary.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: cs.outline.withOpacity(0.2)),
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
    );
  }
}
