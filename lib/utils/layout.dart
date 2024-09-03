import 'package:flutter/material.dart';
import 'package:miru_app/router/router.dart';

class LayoutUtils {
static bool? _isTablet;

// 获取当前宽度
static double get width {
  return MediaQuery.of(currentContext).size.width;
}

// 获取当前高度
static double get height {
  return MediaQuery.of(currentContext).size.height;
}

// 获取屏幕短边的长度
static double get shortestSide {
  return MediaQuery.of(currentContext).size.shortestSide;
}

// 是否是平板
static bool get isTablet {
  return _isTablet ??= shortestSide > 600;
}
}
