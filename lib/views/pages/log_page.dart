import 'dart:convert';

import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/views/widgets/log/extension_log_tile.dart';

class ExtensionLogWindow extends StatefulWidget {
  const ExtensionLogWindow({
    Key? key,
    required this.windowController,
  }) : super(key: key);
  final WindowController windowController;

  @override
  State<ExtensionLogWindow> createState() => _ExtensionLogWindowState();
}

class _ExtensionLogWindowState extends State<ExtensionLogWindow> {
  List<ExtensionLog> logs = [];
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    DesktopMultiWindow.setMethodHandler((call, fromWindowId) async {
      if (call.method == "addLog") {
        final log = ExtensionLog.fromJson(jsonDecode(call.arguments));
        setState(() {
          logs.add(log);
        });
        // 延时
        await Future.delayed(const Duration(milliseconds: 100), () {
          _controller.animateTo(
            _controller.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        });
      }
      if (call.method == "state") {
        return "yes";
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        color: Colors.white,
        child: ListView(
          controller: _controller,
          padding: const EdgeInsets.all(16),
          children: [
            if (logs.isEmpty)
              const Center(
                child: Text("No log"),
              )
            else ...[
              for (var log in logs) ExtensionLogTile(log: log),
            ]
          ],
        ),
      ),
    );
  }
}
