import 'package:package_info_plus/package_info_plus.dart';

late PackageInfo packageInfo;

class PackageInfoUtil {
  static Future ensureInitialized() async {
    packageInfo = await PackageInfo.fromPlatform();
    return packageInfo;
  }
}
