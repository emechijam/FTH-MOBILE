import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'audio_player_service.dart';
import 'hymn_data.dart';
import 'main.dart'; // Importing for the MusicPlayerControls and responsiveFontSize
import 'download_service.dart';

class MusicScreen extends StatefulWidget {
  final Hymn hymn;
  const MusicScreen({super.key, required this.hymn});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayerService _audioPlayerService = AudioPlayerService.instance;
  final DownloadService _downloadService = DownloadService.instance;
  late bool _isDownloaded;

  @override
  void initState() {
    super.initState();
    _isDownloaded = _downloadService.isHymnDownloaded(widget.hymn.number);
    _downloadService.addListener(_onDownloadStateChanged);
    if (_isDownloaded) {
      _audioPlayerService.loadHymn(widget.hymn);
    } else {
      _audioPlayerService.stop();
    }
  }

  @override
  void dispose() {
    _downloadService.removeListener(_onDownloadStateChanged);
    super.dispose();
  }

  void _onDownloadStateChanged() {
    if (mounted) {
      setState(() {
        _isDownloaded = _downloadService.isHymnDownloaded(widget.hymn.number);
        if (_isDownloaded) {
          _audioPlayerService.loadHymn(widget.hymn);
        }
      });
    }
  }

  void _showDownloadModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF130F31),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DownloadModal(hymn: widget.hymn);
      },
    ).whenComplete(() {
      _downloadService.resetStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090723),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Music sheet",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isDownloaded ? _buildMusicPlayer() : _buildDownloadPrompt(),
    );
  }

  Widget _buildMusicPlayer() {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.symmetric(horizontal: 24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: PhotoView(
                imageProvider: AssetImage(widget.hymn.imageAsset),
                backgroundDecoration: const BoxDecoration(
                  color: Colors.white,
                ),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.0,
              ),
            ),
          ),
        ),
        const SafeArea(
          child: MusicPlayerControls(),
        ),
      ],
    );
  }

  Widget _buildDownloadPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.download_for_offline_outlined,
              size: 80, color: Colors.white70),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Download resources to view the music sheet and play audio.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white70,
                  fontSize: responsiveFontSize(context, 18)),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _showDownloadModal,
            icon: const Icon(Icons.download, color: Color(0xFFFF7645)),
            label: Text('Download Resources',
                style: TextStyle(
                    color: const Color(0xFFFF7645),
                    fontSize: responsiveFontSize(context, 16))),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFF7645)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class DownloadModal extends StatefulWidget {
  final Hymn hymn;
  const DownloadModal({super.key, required this.hymn});

  @override
  State<DownloadModal> createState() => _DownloadModalState();
}

class _DownloadModalState extends State<DownloadModal> {
  final DownloadService _downloadService = DownloadService.instance;

  @override
  void initState() {
    super.initState();
    _downloadService.addListener(_onDownloadStateChanged);
  }

  @override
  void dispose() {
    _downloadService.removeListener(_onDownloadStateChanged);
    super.dispose();
  }

  void _onDownloadStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Download Resources',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: responsiveFontSize(context, 22),
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            'Download audio and music sheets for offline access. Files will be encrypted and only accessible through the app.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white70,
                fontSize: responsiveFontSize(context, 16)),
          ),
          const SizedBox(height: 24),
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_downloadService.status) {
      case DownloadStatus.checking:
        return _buildStatusIndicator(
          icon: const CircularProgressIndicator(color: Color(0xFFFF7645)),
          message: 'Checking connection...',
        );
      case DownloadStatus.downloading:
        return _buildDownloadingIndicator();
      case DownloadStatus.failure:
        return _buildFailureMessage();
      case DownloadStatus.idle:
      default:
        return _buildInitialOptions();
    }
  }

  Widget _buildInitialOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () => _downloadService.downloadHymn(widget.hymn),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7645),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text('Download this hymn (~2.5 MB)',
              style: TextStyle(fontSize: responsiveFontSize(context, 16))),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _downloadService.downloadAllHymns(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF090723),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Download all hymns (~2.5 GB)'),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator(
      {required Widget icon, required String message}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20, width: 20, child: icon),
        const SizedBox(height: 20),
        Text(
          message,
          style: TextStyle(
              color: Colors.white70, fontSize: responsiveFontSize(context, 16)),
        ),
      ],
    );
  }

  Widget _buildDownloadingIndicator() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Downloading...',
            style: TextStyle(
                color: Colors.white,
                fontSize: responsiveFontSize(context, 18))),
        const SizedBox(height: 16),
        LinearProgressIndicator(
          value: _downloadService.progress,
          backgroundColor: Colors.white.withAlpha(50),
          color: const Color(0xFFFF7645),
        ),
        const SizedBox(height: 8),
        Text(
            '${(_downloadService.progress * 100).toStringAsFixed(0)}% - ${_downloadService.progressDetails}',
            style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildFailureMessage() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusIndicator(
          icon: const Icon(Icons.error_outline, color: Colors.red, size: 20),
          message: _downloadService.errorMessage,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            _downloadService.resetStatus();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF7645),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          ),
          child: Text('Try Again',
              style: TextStyle(fontSize: responsiveFontSize(context, 16))),
        ),
      ],
    );
  }
}
