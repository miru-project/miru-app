import 'package:flutter/material.dart';

class DateTileDialog extends StatefulWidget {
  const DateTileDialog({
    super.key,
    required this.title,
    required this.value,
    required this.onChange,
    required this.onClear,
  });
  final String title;
  final DateTime? value;
  final Function(DateTime) onChange;
  final Function onClear;

  @override
  State<DateTileDialog> createState() => _DateTileDialogState();
}

class _DateTileDialogState extends State<DateTileDialog> {
  _buildContent() {
    if (widget.value == null) {
      return Text(widget.title);
    }
    return Text(widget.value.toString().split(' ')[0]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        // 日期选择器
        final value = await showDatePicker(
          context: context,
          initialDate: widget.value,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
          cancelText: 'clear',
        );
        if (value != null) {
          widget.onChange(value);
        } else {
          widget.onClear();
        }
      },
      child: Container(
        color: Theme.of(context).cardColor,
        child: Center(
          child: _buildContent(),
        ),
      ),
    );
  }
}
