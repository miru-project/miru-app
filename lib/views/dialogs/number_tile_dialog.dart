import 'package:flutter/material.dart';

class NumberTileDialog extends StatefulWidget {
  const NumberTileDialog({
    super.key,
    required this.title,
    required this.value,
    required this.onChange,
    required this.onClear,
    this.max,
    this.min,
  });
  final String title;
  final num? value;
  final num? min;
  final num? max;
  final Function(double) onChange;
  final Function onClear;

  @override
  State<NumberTileDialog> createState() => _NumberTileDialogState();
}

class _NumberTileDialogState extends State<NumberTileDialog> {
  late final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _buildContent() {
    if (widget.value == null || widget.value == widget.min) {
      return Text(widget.title);
    }
    return Text(
      widget.value.toString() + (widget.max == null ? '' : '/${widget.max}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _controller.text = widget.value.toString();
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (context) => Padding(
            padding: const EdgeInsets.all(20),
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // number
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Number",
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            if (widget.min != null &&
                                num.parse(value) < widget.min!) {
                              _controller.text = widget.min.toString();
                            }
                            if (widget.max != null &&
                                num.parse(value) > widget.max!) {
                              _controller.text = widget.max.toString();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          widget.onClear();
                          Navigator.pop(context);
                        },
                        child: const Text("Clear"),
                      ),
                      FilledButton(
                        onPressed: () {
                          widget.onChange(double.parse(_controller.text));
                          Navigator.pop(context);
                        },
                        child: const Text("Confirm"),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
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
