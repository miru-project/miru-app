import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru_app/models/extension.dart';
import 'package:miru_app/pages/watch/widgets/reader/controller.dart';
import 'package:miru_app/utils/i18n.dart';
import 'package:miru_app/widgets/button.dart';
import 'package:miru_app/widgets/platform_widget.dart';
import 'package:miru_app/widgets/progress_ring.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;

class NovelReaderContent extends StatefulWidget {
  const NovelReaderContent(this.tag, {Key? key}) : super(key: key);
  final String tag;

  @override
  State<NovelReaderContent> createState() => _NovelReaderContentState();
}

class _NovelReaderContentState extends State<NovelReaderContent> {
  late final _c =
      Get.find<ReaderController<ExtensionFikushonWatch>>(tag: widget.tag);

  _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) => Obx(
        () {
          // // 宽度 大于 800 就是整体宽度的一半
          final maxWidth = constraints.maxWidth;
          // final width = maxWidth > 800 ? maxWidth / 2 : maxWidth;
          // final height = constraints.maxHeight;
          if (_c.error.value.isNotEmpty) {
            return Column(
              children: [
                Text(_c.error.value),
                PlatformButton(
                  child: Text('common.retry'.i18n),
                  onPressed: () {
                    _c.getContent();
                  },
                )
              ],
            );
          }

          if (_c.watchData.value == null) {
            return const Center(child: ProgressRing());
          }

          final watchData = _c.watchData.value!;

          final listviewPadding =
              maxWidth > 800 ? ((maxWidth - 800) / 2) : 16.0;

          return Center(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                  horizontal: listviewPadding, vertical: 16),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      _c.title + _c.playList[_c.playIndex].name,
                      style: const TextStyle(fontSize: 26),
                    ),
                  );
                }
                if (index == 1) {
                  return (watchData.subtitle != null)
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            watchData.subtitle!,
                            style: const TextStyle(fontSize: 20),
                          ),
                        )
                      : const SizedBox();
                }
                if (index == watchData.content.length + 2) {
                  return Row(
                    children: [
                      PlatformIconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (_c.index.value > 0) {
                            _c.index.value--;
                          }
                        },
                      ),
                      PlatformIconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () {
                          if (_c.index.value < _c.playList.length - 1) {
                            _c.index.value++;
                          }
                        },
                      ),
                    ],
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: SelectableText.rich(
                    TextSpan(
                      children: [
                        const WidgetSpan(child: SizedBox(width: 40.0)),
                        TextSpan(
                          text: watchData.content[index - 2],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            height: 2,
                            textBaseline: TextBaseline.ideographic,
                            fontFamily: 'Microsoft Yahei',
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              itemCount: watchData.content.length + 3,
            ),
          );

          // const TextStyle textStyle = TextStyle(
          //   fontSize: 18,
          //   fontWeight: FontWeight.w400,
          //   height: 2,
          //   textBaseline: TextBaseline.ideographic,
          // );

          // // 获取每句子的高
          // final List<double> heightList = [];
          // for (final String sentence in content) {
          //   final TextPainter painter = TextPainter(
          //     text: TextSpan(
          //       text: sentence,
          //       style: textStyle,
          //     ),
          //     textDirection: TextDirection.ltr,
          //   )..layout(maxWidth: width - 140);
          //   heightList.add(painter.height);
          // }

          // // 通过高度判断每页能放多少句子
          // final List<int> pageSentenceCount = [];
          // double pageHeight = 0;
          // int sentenceCount = 0;
          // for (final double textHeight in heightList) {
          //   pageHeight += textHeight;
          //   sentenceCount++;
          //   if (pageHeight > height) {
          //     pageSentenceCount.add(sentenceCount);
          //     pageHeight = 0;
          //     sentenceCount = 0;
          //   }
          // }

          // final List<Widget> pageViewList = [];

          // int pageStartIndex = 0;
          // for (final int sentenceCount in pageSentenceCount) {
          //   final List<String> pageContent = content.sublist(
          //     pageStartIndex,
          //     pageStartIndex + sentenceCount,
          //   );
          //   pageStartIndex += sentenceCount;
          //   pageViewList.add(
          //     ListView.builder(
          //       shrinkWrap: true,
          //       physics: const NeverScrollableScrollPhysics(),
          //       itemBuilder: (context, index) {
          //         return Text(
          //           pageContent[index],
          //           style: textStyle,
          //         );
          //       },
          //       itemCount: pageContent.length,
          //     ),
          //   );
          // }

          // return PageView(
          //   children: [
          //     //  如果大于 800 就是整体宽度的一半
          //     for (var i = 0;
          //         i < pageViewList.length;
          //         maxWidth > 800 ? i += 2 : i++)
          //       Row(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: [
          //           Expanded(
          //             child: Container(
          //               child: pageViewList[i],
          //             ),
          //           ),
          //           if (maxWidth > 800)
          //             i + 1 < pageViewList.length
          //                 ? Expanded(
          //                     child: Container(
          //                       child: pageViewList[i + 1],
          //                     ),
          //                   )
          //                 : const Expanded(child: SizedBox()),
          //         ],
          //       )
          //   ],
          // );
        },
      ),
    );
  }

  Widget _buildAndroid(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildContent()),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Container(
      color: fluent.FluentTheme.of(context).micaBackgroundColor,
      child: _buildContent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformBuildWidget(
      androidBuilder: _buildAndroid,
      desktopBuilder: _buildDesktop,
    );
  }
}
