import 'package:flutter/material.dart';
import 'package:dlna_dart/dlna.dart';
import 'package:miru_app/utils/log.dart';
import 'package:miru_app/views/widgets/progress.dart';

class VideoPlayerDLNA extends StatefulWidget {
  const VideoPlayerDLNA({
    super.key,
    this.onDeviceSelected,
  });
  final Function(DLNADevice device)? onDeviceSelected;

  @override
  State<VideoPlayerDLNA> createState() => _VideoPlayerDLNAState();
}

class _VideoPlayerDLNAState extends State<VideoPlayerDLNA> {
  late DLNAManager searcher;
  Map<String, DLNADevice> deviceList = {};

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    searcher = DLNAManager();
    logger.info('DLNA searching devices...');
    final m = await searcher.start();
    m.devices.stream.listen((deviceList) {
      logger.info('DLNA devices: $deviceList');
      setState(() {
        this.deviceList = deviceList;
      });
    });
  }

  @override
  void dispose() {
    logger.info('DLNA stop searching devices...');
    searcher.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text(
            'DLNA devices',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        const SizedBox(height: 10),
        for (final device in deviceList.entries)
          ListTile(
            title: Text(device.value.info.friendlyName),
            subtitle: Text(device.key),
            onTap: () async {
              widget.onDeviceSelected?.call(device.value);
            },
          ),
        const Center(
          child: ProgressRing(),
        )
      ],
    );
  }
}
