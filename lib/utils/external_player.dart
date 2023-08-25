import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> launchMobileExternalPlayer(String playUrl, String player) async {
  switch (player) {
    case "vlc":
      await _launchExternalPlayer("vlc://$playUrl");
      break;
    case "mxplayer":
      await AndroidIntent(
        action: 'action_view',
        data: playUrl,
        package: 'com.mxtech.videoplayer.ad',
      ).launch();
      break;
    case "mpv":
      await AndroidIntent(
        action: 'action_view',
        data: playUrl,
        package: 'is.xyz.mpv',
      ).launch();
      break;
  }
}

// desktop
Future<void> launchDesktopExternalPlayer(String playUrl, String player) async {
  switch (player) {
    case "vlc":
      await _launchExternalPlayer("vlc://$playUrl");
      break;
    case "mpv":
      await _launchExternalPlayer("mpv://$playUrl");
      break;
    case "potplayer":
      await _launchExternalPlayer("potplayer://$playUrl");
      break;
  }
}

_launchExternalPlayer(String url) async {
  if (!await launchUrlString(url, mode: LaunchMode.externalApplication)) {
    throw Exception("Failed to launch $url");
  }
}
