import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:miru_app/data/services/extension_service.dart';
import 'package:miru_app/utils/miru_storage.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';

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
  final cookieManager = WebviewCookieManager();
  bool isByPassCloudFlare = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(url),
        actions: [
          if (isByPassCloudFlare)
            IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.check),
            ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(url),
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            userAgent: MiruStorage.getUASetting(),
          ),
        ),
        onLoadStop: (controller, url) async {
          if (url!.host != Uri.parse(this.url).host) {
            return;
          }
          cookieManager.getCookies(url.toString()).then((cookies) {
            final cookieString =
                cookies.map((e) => '${e.name}=${e.value}').toList().join(';');
            debugPrint('$url $cookieString');
            if (cookieString.contains('cf_clearance')) {
              setState(() {
                isByPassCloudFlare = true;
              });
            }
            widget.extensionRuntime.setCookie(
              cookieString,
            );
          });
        },
      ),
    );
  }
}
