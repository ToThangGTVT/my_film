import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ItemSliderImage extends StatelessWidget {
  const ItemSliderImage({
    super.key,
    required this.imageUrl,
    required this.onTap,
  });

  final String imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // bo góc đẹp hơn
        child: CachedNetworkImage(
          width: width,
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey.shade800,
            highlightColor: Colors.grey.shade600,
            child: Container(
              width: width,
              color: Colors.grey.shade900,
            ),
          ),
          errorWidget: (context, url, error) => Container(
            width: width,
            color: Colors.black26,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image_outlined,
              color: cs.tertiary,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}
