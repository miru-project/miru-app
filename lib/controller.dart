import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/utils/miru_storage.dart';

class ApplicationController extends GetxController {
  static get find => Get.find();

  final themeText = "system".obs;

  @override
  void onInit() {
    themeText.value = MiruStorage.getSetting(SettingKey.theme);
    super.onInit();
  }

  ThemeData get currentThemeData {
    switch (themeText.value) {
      case "light":
        return ThemeData.light(useMaterial3: true);
      case "dark":
        return ThemeData.dark(useMaterial3: true);
      case "black":
        return ThemeData.dark(
          useMaterial3: true,
        ).copyWith(
          scaffoldBackgroundColor: Colors.black,
          canvasColor: Colors.black,
          cardColor: Colors.black,
          dialogBackgroundColor: Colors.black,
          primaryColor: Colors.black,
          hintColor: Colors.black,
          primaryColorDark: Colors.black,
          primaryColorLight: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            onBackground: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
            secondary: Colors.grey,
            surface: Colors.black,
            background: Colors.black,
            onPrimary: Colors.black,
            primaryContainer: Color.fromARGB(255, 31, 31, 31),
            surfaceTint: Colors.black,
          ),
        );
      default:
        return ThemeData.light(useMaterial3: true);
    }
  }

  ThemeMode get theme {
    switch (themeText.value) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      case "black":
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  changeTheme(String mode) {
    MiruStorage.setSetting(SettingKey.theme, mode);
    themeText.value = mode;
    Get.forceAppUpdate();
  }
}
