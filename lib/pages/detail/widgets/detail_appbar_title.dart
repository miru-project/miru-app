import 'package:flutter/material.dart';

class DetailAppbarTitle extends StatefulWidget {
  const DetailAppbarTitle(
    this.text, {
    Key? key,
    required this.controller,
  }) : super(key: key);
  final String text;
  final ScrollController controller;

  @override
  State<DetailAppbarTitle> createState() => _DetailAppbarTitleState();
}

class _DetailAppbarTitleState extends State<DetailAppbarTitle> {
  double _offset = 0;

  @override
  void initState() {
    widget.controller.addListener(() {
      setState(() {
        _offset = widget.controller.offset;
      });
    });
    super.initState();
  }

  double _scrollListener() {
    if (_offset <= 300) {
      return 0;
    } else {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.text,
      style: TextStyle(
        color: Colors.black.withOpacity(_scrollListener()),
      ),
    );
  }
}
