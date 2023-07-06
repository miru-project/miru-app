import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/utils/extension.dart';
import 'package:miru_app/widgets/messenger.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';

class CodeEditPage extends StatefulWidget {
  const CodeEditPage({
    required this.extension,
    Key? key,
  }) : super(key: key);
  final Extension extension;
  @override
  State<CodeEditPage> createState() => _CodeEditPageState();
}

class _CodeEditPageState extends State<CodeEditPage> {
  CodeController controller = CodeController(
    language: javascript,
  );

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() async {
    final dir = await ExtensionUtils.getExtensionsDir;
    final file = File('$dir/${widget.extension.package}.js');
    if (await file.exists()) {
      final content = await file.readAsString();
      controller.text = content;
    }
  }

  _save() async {
    final dir = await ExtensionUtils.getExtensionsDir;
    final file = File('$dir/${widget.extension.package}.js');
    await file.writeAsString(controller.text);
    // ignore: use_build_context_synchronously
    showPlatformSnackbar(context: context, title: '保存代码', content: '保存成功');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.extension.name),
        actions: [
          IconButton(
            onPressed: () async {
              _save();
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: CodeTheme(
        data: CodeThemeData(styles: monokaiSublimeTheme),
        child: SingleChildScrollView(
          child: CodeField(
            controller: controller,
          ),
        ),
      ),
    );
  }
}
