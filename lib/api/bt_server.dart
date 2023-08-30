import 'dart:typed_data';

import 'package:dio/dio.dart';

class BTServerApi {
  static const baseApi = "http://localhost:3000";
  static final dio = Dio(BaseOptions(
    baseUrl: baseApi,
  ));
  static Future<String> getVersion() async {
    return (await dio.get<String>("/version")).data!;
  }

  static Future<String> addTorrent(Uint8List torrent) async {
    return (await dio.post<Map<String, dynamic>>("/torrent",
            data: torrent,
            options: Options(
              headers: {
                "Content-Type": "application/x-bittorrent",
                "Content-Length": torrent.length,
              },
            )))
        .data!["infoHash"];
  }

  static Future<String> removeTorrent(String infoHash) async {
    return (await dio.delete<String>("/torrent/$infoHash")).data!;
  }

  static Future<List<String>> getFileList(String infoHash) async {
    final fileList = (await dio.get<Map<String, dynamic>>("/torrent/$infoHash"))
        .data!['files'];
    return List<String>.from(fileList);
  }
}
