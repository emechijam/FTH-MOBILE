import 'package:flutter/material.dart';
import 'hymn_data.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

enum DownloadStatus { idle, checking, downloading, success, failure }

class DownloadService extends ChangeNotifier {
  DownloadService._privateConstructor();
  static final DownloadService instance = DownloadService._privateConstructor();

  final Set<String> _downloadedHymns = {};
  DownloadStatus _status = DownloadStatus.idle;
  double _progress = 0.0;
  String _errorMessage = '';
  String _progressDetails = '';

  DownloadStatus get status => _status;
  double get progress => _progress;
  String get errorMessage => _errorMessage;
  String get progressDetails => _progressDetails;

  bool isHymnDownloaded(String hymnNumber) {
    return _downloadedHymns.contains(hymnNumber);
  }

  Future<void> _startDownload(Future<void> Function() downloadLogic) async {
    _status = DownloadStatus.checking;
    notifyListeners();

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _status = DownloadStatus.failure;
      _errorMessage =
          'No internet connection. Please connect to a network and try again.';
      notifyListeners();
      return;
    }

    try {
      await Future.delayed(const Duration(seconds: 2));
      throw Exception("Resource not found on the server.");

      _status = DownloadStatus.downloading;
      notifyListeners();

      await downloadLogic();

      _status = DownloadStatus.success;
    } catch (e) {
      _status = DownloadStatus.failure;
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
    } finally {
      notifyListeners();
    }
  }

  Future<void> downloadHymn(Hymn hymn) async {
    await _startDownload(() async {
      _downloadedHymns.add(hymn.number);
    });
  }

  Future<void> downloadAllHymns() async {
    await _startDownload(() async {
      for (var hymn in allHymns) {
        _downloadedHymns.add(hymn.number);
      }
    });
  }

  void resetStatus() {
    _status = DownloadStatus.idle;
    _progress = 0.0;
    _errorMessage = '';
    _progressDetails = '';
    notifyListeners();
  }
}
