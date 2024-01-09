import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:miru_app/data/providers/anilist_provider.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class AnilistWebViewPage extends StatefulWidget {
  const AnilistWebViewPage({
    super.key,
    required this.url,
  });
  final String url;

  @override
  State<AnilistWebViewPage> createState() => _AnilistWebViewPageState();
}

class _AnilistWebViewPageState extends State<AnilistWebViewPage> {
  late String url = widget.url;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.url),
      ),
      body: InAppWebView(
          initialUrlRequest: URLRequest(
            url: Uri.parse(widget.url),
          ),
          onLoadStart: (controller, url) async {
            if (url != null && url.path != "/login") {
              debugPrint(url.host);
              AniListProvider.saveAuthToken(url.toString());
              Get.back();
            }
          }),
    );
  }
}
