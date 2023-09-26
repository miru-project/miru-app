import 'package:flutter/material.dart';
import 'package:miru_app/router/router.dart';

class LayoutUtils {
  static bool? _isTablet;

  // 获取当前宽度
  static double get getWidth {
    return MediaQuery.of(currentContext).size.width;
  }

  // 获取当前高度
  static double get getHeight {
    return MediaQuery.of(currentContext).size.height;
  }

  // 是否是平板
  static bool get isTablet {
    return _isTablet ??= getWidth > 800;
  }
}
