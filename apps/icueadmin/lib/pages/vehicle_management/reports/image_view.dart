import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../services/analytics_service.dart';
import '../../../services/injectable.dart';
import '../../../widgets/cache_image.dart';

class ImageView extends StatelessWidget {
  const ImageView({super.key, required this.url, required this.isBase64});

  final bool isBase64;
  final String url;

  @override
  Widget build(BuildContext context) {
    getIt<AnalyticsService>().logScreenView(
      screenName: 'image-view-page',
      parameters: {'url': url, 'isBase64': isBase64.toString()},
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Image')),
      body: isBase64
          ? const SizedBox()
          : kIsWeb
          ? Image.network(
              url,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/document_placeholder.png',
                width: double.infinity,
                height: double.infinity,
              ),
            )
          : CacheImage(url: url, size: double.infinity),
    );
  }
}
