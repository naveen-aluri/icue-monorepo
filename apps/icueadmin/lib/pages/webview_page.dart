import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../services/analytics_service.dart';
import '../services/injectable.dart';

class WebviewPage extends StatefulWidget {
  const WebviewPage({super.key, required this.url, required this.title});
  final String url;
  final String title;

  @override
  State<WebviewPage> createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebviewPage> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllowFullscreen: true,
  );

  double progress = 0;

  @override
  void initState() {
    super.initState();
    getIt<AnalyticsService>().logScreenView(
      screenName: 'webview-page',
      parameters: {'url': widget.url, 'title': widget.title},
    );
  }

  // The PDF file is downloaded instead of opening in the webview

  @override
  Widget build(BuildContext context) {
    log('WEBVIEW: ${widget.url}');
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: settings,
            onWebViewCreated: (controller) {
              webViewController = controller;
            },
            onLoadStart: (controller, url) {},
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                resources: request.resources,
                action: PermissionResponseAction.GRANT,
              );
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              final uri = navigationAction.request.url!;

              if (![
                'http',
                'https',
                'file',
                'chrome',
                'data',
                'javascript',
                'about',
              ].contains(uri.scheme)) {
                // and cancel the request
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) async {},
            onReceivedError: (controller, request, error) {},
            onProgressChanged: (controller, progress) {
              if (progress == 100) {}
              setState(() {
                this.progress = progress / 100;
              });
            },
            onUpdateVisitedHistory: (controller, url, androidIsReload) {},
          ),
          if (progress < 1.0)
            LinearProgressIndicator(value: progress)
          else
            Container(),
        ],
      ),
    );
  }
}
