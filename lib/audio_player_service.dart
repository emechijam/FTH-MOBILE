import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'hymn_data.dart'; // We need this to know what hymn is playing

// This service will manage the audio player's state for the entire app.
class AudioPlayerService extends ChangeNotifier {
  AudioPlayerService._privateConstructor();
  static final AudioPlayerService instance =
      AudioPlayerService._privateConstructor();

  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLooping = false;
  Hymn? _currentHymn;

  // Getters for the player's state
  PlayerState get playerState => _playerState;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get isLooping => _isLooping;
  Hymn? get currentHymn => _currentHymn;

  void init() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _playerState = state;
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      _duration = duration;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _position = position;
      notifyListeners();
    });
  }

  Future<void> loadHymn(Hymn hymn) async {
    _currentHymn = hymn;
    try {
      await _audioPlayer.setSource(AssetSource(hymn.audioAsset));
      notifyListeners();
    } catch (e) {
      print("Error setting audio source: $e");
    }
  }

  Future<void> play(Hymn hymn) async {
    _currentHymn = hymn;
    try {
      await _audioPlayer.play(AssetSource(hymn.audioAsset));
      notifyListeners();
    } catch (e) {
      // Error handling can be added here
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentHymn = null;
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> toggleLooping() async {
    _isLooping = !_isLooping;
    await _audioPlayer
        .setReleaseMode(_isLooping ? ReleaseMode.loop : ReleaseMode.stop);
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
