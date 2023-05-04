import 'package:flutter/material.dart';

class ExtensionPage extends StatefulWidget {
  const ExtensionPage({Key? key}) : super(key: key);

  static const routeName = "/extension";

  @override
  State<ExtensionPage> createState() => _ExtensionPageState();
}

class _ExtensionPageState extends State<ExtensionPage> {
  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: Center(
          child: Text("Extension Page"),
        ),
      ),
    );
  }
}
