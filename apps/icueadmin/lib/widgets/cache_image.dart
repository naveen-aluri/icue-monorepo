import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CacheImage extends StatelessWidget {
  const CacheImage({super.key, required this.url, required this.size});

  final double size;
  final String url;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: size,
      height: size,
      placeholder: (context, url) =>
          Image.asset('assets/logo.png', width: size, height: size),
      errorWidget: (context, url, error) =>
          Image.asset('assets/logo.png', width: size, height: size),
    );
  }
}
