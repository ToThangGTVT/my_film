
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:m3u8_downloader/m3u8_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'movie_download_state.dart';

class MovieDownloadCubit extends Cubit<MovieDownloadState> {
  MovieDownloadCubit()
      : super(const MovieDownloadState());

  static final ReceivePort _port = ReceivePort();

  Future<void> download(String m3u8Url, String? movieName) async {
    M3u8Downloader.download(url: m3u8Url,
        name: movieName ?? "video-${DateTime
            .now()
            .millisecondsSinceEpoch}",
        progressCallback: progressCallback,
        successCallback: successCallback,
        errorCallback: errorCallback);
  }

  static Future<void> initAsync() async {
    String saveDir = await _findSavePath();
    M3u8Downloader.initialize(
        onSelect: () async {
          print('下载成功点击');
          return null;
        }
    );
    M3u8Downloader.config(
        saveDir: saveDir,
        threadCount: 2,
        convertMp4: false,
        debugMode: false
    );
    // 注册监听器
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      // 监听数据请求
      print(data);
    });
  }

  static Future<String> _findSavePath() async {
    late String saveDir;

    if (Platform.isAndroid) {
      // Get the Downloads directory on Android
      Directory? directory = Directory('/storage/emulated/0/Download');
      saveDir = directory.path;
    } else {
      // For other platforms, use the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      saveDir = path.join(directory.path, 'vPlayDownload');
    }

    Directory root = Directory(saveDir);
    if (!root.existsSync()) {
      await root.create(recursive: true);
    }

    print(saveDir);
    return saveDir;
  }

  @pragma('vm:entry-point')
  static progressCallback(dynamic args) {
    final SendPort? send = IsolateNameServer.lookupPortByName(
        'downloader_send_port');
    if (send != null) {
      args["status"] = 1;
      send.send(args);
    }
  }

  @pragma('vm:entry-point')
  static successCallback(dynamic args) {
    final SendPort? send = IsolateNameServer.lookupPortByName(
        'downloader_send_port');
    if (send != null) {
      send.send({
        "status": 2,
        "url": args["url"],
        "filePath": args["filePath"],
        "dir": args["dir"]
      });
    }
  }

  @pragma('vm:entry-point')
  static errorCallback(dynamic args) {
    final SendPort? send = IsolateNameServer.lookupPortByName(
        'downloader_send_port');
    if (send != null) {
      send.send({"status": 3, "url": args["url"]});
    }
  }
}