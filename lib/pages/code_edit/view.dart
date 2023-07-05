import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';

class CodeEditPage extends StatefulWidget {
  const CodeEditPage({
    Key? key,
    required this.windowController,
    required this.args,
  }) : super(key: key);
  final WindowController windowController;
  final Map? args;
  @override
  State<CodeEditPage> createState() => _CodeEditPageState();
}

class _CodeEditPageState extends State<CodeEditPage> {
  CodeController controller = CodeController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Miru',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: CodeTheme(
          data: CodeThemeData(),
          child: SingleChildScrollView(
            child: CodeField(
              controller: controller,
            ),
          ),
        ),
      ),
    );
  }
}
