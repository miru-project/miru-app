import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';

class SearchAllTileTitle extends StatefulWidget {
  const SearchAllTileTitle(this.text, {Key? key, required this.onClick})
      : super(key: key);
  final String text;
  final Function() onClick;

  @override
  State<SearchAllTileTitle> createState() => _SearchAllTileTitleState();
}

class _SearchAllTileTitleState extends State<SearchAllTileTitle> {
  bool _hoverTitle = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) {
        setState(() {
          _hoverTitle = true;
        });
      },
      onExit: (event) {
        setState(() {
          _hoverTitle = false;
        });
      },
      child: GestureDetector(
        onTap: () {
          widget.onClick();
        },
        child: AnimatedContainer(
          padding: EdgeInsets.symmetric(
              horizontal: _hoverTitle ? 20 : 10, vertical: 10),
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: _hoverTitle
                ? const Color.fromARGB(19, 27, 26, 25)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                fluent.FluentIcons.chevron_right_med,
                size: 14,
              )
            ],
          ),
        ),
      ),
    );
  }
}
