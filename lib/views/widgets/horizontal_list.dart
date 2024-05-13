import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class HorizontalList extends StatefulWidget {
  const HorizontalList({
    super.key,
    required this.title,
    required this.onClickMore,
    this.itemCount,
    this.itemBuilder,
    this.contentBuilder,
  })  : assert(
          (itemCount != null && itemBuilder != null) || contentBuilder != null,
          "itemCount and itemBuilder or contentBuilder must not be null",
        );
  final String title;
  final void Function() onClickMore;
  final int? itemCount;
  final Widget? Function(BuildContext, int)? itemBuilder;
  final Widget Function(ScrollController)? contentBuilder;

  @override
  State<HorizontalList> createState() => _HorizontalListState();
}

class _HorizontalListState extends State<HorizontalList> {
  final ScrollController _controller = ScrollController();

  _horzontalMove(bool left) {
    _controller.animateTo(
      _controller.offset + (left ? -500 : 500),
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(widget.title),
            const Spacer(),
            TextButton(
              onPressed: widget.onClickMore,
              child: Text('common.show-all'.i18n),
            )
          ],
        ),
        const SizedBox(height: 8),
        if (widget.contentBuilder != null)
          widget.contentBuilder!(_controller)
        else
          SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _controller,
              itemCount: widget.itemCount,
              itemBuilder: ((context, index) {
                return Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 16),
                  child: widget.itemBuilder!(context, index),
                );
              }),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            HorizontalTitle(
              widget.title,
              onClick: widget.onClickMore,
            ),
            const Spacer(),
            Row(
              children: [
                fluent.IconButton(
                    icon: const Icon(fluent.FluentIcons.chevron_left),
                    onPressed: () {
                      _horzontalMove(true);
                    }),
                const SizedBox(width: 8),
                fluent.IconButton(
                  icon: const Icon(fluent.FluentIcons.chevron_right),
                  onPressed: () {
                    _horzontalMove(false);
                  },
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.contentBuilder != null)
          widget.contentBuilder!(_controller)
        else
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _controller,
              itemCount: widget.itemCount,
              itemBuilder: ((context, index) {
                return Container(
                  width: 170,
                  margin: const EdgeInsets.only(right: 16),
                  child: widget.itemBuilder!(context, index),
                );
              }),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      mobileBuilder: _buildMobile,
      desktopBuilder: _buildDesktop,
    );
  }
}

class HorizontalTitle extends StatefulWidget {
  const HorizontalTitle(this.text, {super.key, required this.onClick});
  final String text;
  final Function() onClick;

  @override
  State<HorizontalTitle> createState() => _HorizontalTitleState();
}

class _HorizontalTitleState extends State<HorizontalTitle> {
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
            horizontal: _hoverTitle ? 20 : 0,
            vertical: 10,
          ),
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: _hoverTitle
                ? fluent.FluentTheme.of(context).brightness == Brightness.light
                    ? const Color.fromARGB(19, 27, 26, 25)
                    : const Color.fromARGB(19, 186, 186, 186)
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
