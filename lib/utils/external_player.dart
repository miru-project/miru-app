import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:url_launcher/url_launcher_string.dart';

Future<void> launchMobileExternalPlayer(String playUrl, String player) async {
  switch (player) {
    case "vlc":
      await _launchExternalPlayer("vlc://$playUrl");
      break;
    case "other":
      await AndroidIntent(
        action: 'action_view',
        data: playUrl,
        type: 'video/*',
      ).launch();
      break;
  }
}

// desktop
Future<void> launchDesktopExternalPlayer(String playUrl, String player) async {
  switch (player) {
    case "vlc":
      const vlc = 'C:\\Program Files\\VideoLAN\\VLC\\vlc.exe';
      await Process.run(vlc, [playUrl]);
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
