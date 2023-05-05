import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miru_app/pages/detail/index.dart';
import 'package:miru_app/pages/main/index.dart';

void main() {
  runApp(const MainApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle style = const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark);
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const MainPage(),
      routes: {
        '/detail': (context) => const DetailPage(),
      },
    );
  }
}
