import 'package:flutter/material.dart';
import 'package:miru_app/views/widgets/cover.dart';
import 'package:miru_app/views/widgets/platform_widget.dart';

class GridItemTile extends StatefulWidget {
  const GridItemTile({
    super.key,
    required this.title,
    this.cover,
    this.subtitle,
    this.onTap,
    this.headers,
  });
  final String title;
  final String? cover;
  final String? subtitle;
  final Function()? onTap;
  final Map<String, String>? headers;

  @override
  State<GridItemTile> createState() => _GridItemTileState();
}

class _GridItemTileState extends State<GridItemTile> {
  bool _isHover = false;

  Widget _buildMobile(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Cover(
            alt: widget.title,
            url: widget.cover,
            headers: widget.headers,
          ),
        ),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: 350,
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // 文字只显示一行
                  SizedBox(
                    height: 20,
                    child: Text(
                      widget.title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (widget.subtitle != null)
                    Text(
                      widget.subtitle!,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            )),
        Positioned.fill(
            child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                widget.onTap?.call();
              },
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (event) {
        setState(() {
          _isHover = true;
        });
      },
      onExit: (event) {
        setState(() {
          _isHover = false;
        });
      },
      child: Column(
        // 居左
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                widget.onTap?.call();
              },
              child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AnimatedScale(
                    scale: _isHover ? 1.05 : 1,
                    duration: const Duration(milliseconds: 80),
                    child: Cover(
                      alt: widget.title,
                      url: widget.cover,
                      headers: widget.headers,
                    ),
                  )),
            ),
          ),
          const SizedBox(height: 8),
          // 文字只显示一行
          SizedBox(
            height: 20,
            child: Text(
              widget.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.subtitle != null)
            Text(
              widget.subtitle.toString(),
              style: const TextStyle(
                fontSize: 12,
              ),
            ),
        ],
      ),
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
