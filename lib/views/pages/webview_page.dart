import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:miru_app/data/services/extension_service.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    super.key,
    required this.extensionRuntime,
    required this.url,
  });
  final ExtensionService extensionRuntime;
  final String url;

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late String url = widget.extensionRuntime.extension.webSite + widget.url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(url),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(url),
        ),
        onLoadStop: (controller, url) async {
          if (url!.host !=
              Uri.parse(widget.extensionRuntime.extension.webSite).host) {
            return;
          }
          final cookies = await controller.evaluateJavascript(
            source: 'document.cookie',
          );
          widget.extensionRuntime.setCookie(cookies);
        },
      ),
    );
  }
}
