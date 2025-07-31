import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'music_screen.dart';
import 'favorites_screen.dart';
import 'favorites_service.dart';
import 'hymn_data.dart';
import 'audio_player_service.dart';
import 'index_screen.dart';
import 'download_service.dart';
import 'bible_screen.dart';

// A simple helper function to calculate responsive font size.
double responsiveFontSize(BuildContext context, double baseFontSize,
    {double minFontSize = 12.0, double maxFontSize = 40.0}) {
  final screenWidth = MediaQuery.of(context).size.width;
  const double baseScreenWidth = 375.0; // A common phone width
  final scaleFactor = screenWidth / baseScreenWidth;
  final scaledFontSize = baseFontSize * scaleFactor;
  return scaledFontSize.clamp(minFontSize, maxFontSize);
}

// main is now async to allow for loading hymns before the app runs
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for async main
  await loadHymns(); // Load hymns from fth.json
  AudioPlayerService.instance.init();
  DownloadService.instance;
  runApp(const HymnApp());
}

class HymnApp extends StatelessWidget {
  const HymnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hymn App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090723),
        fontFamily: 'DMSans',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 20.0),
          bodyMedium: TextStyle(color: Colors.white, fontSize: 16.0),
          headlineSmall: TextStyle(
              color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 1;

  static final List<Widget> _widgetOptions = <Widget>[
    const Center(
        child: Text('Home Screen', style: TextStyle(color: Colors.white))),
    HymnScreen(hymn: allHymns.isNotEmpty ? allHymns[0] : null),
    const BibleScreen(),
    const Center(
        child: Text('Notes Screen', style: TextStyle(color: Colors.white))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Hymn'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Bible'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note), label: 'Notes'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF130F31),
        selectedItemColor: const Color(0xFFFF7645),
        unselectedItemColor: const Color(0xFF595773),
        showUnselectedLabels: true,
      ),
    );
  }
}

class HymnScreen extends StatefulWidget {
  final Hymn? hymn;
  const HymnScreen({super.key, required this.hymn});

  @override
  State<HymnScreen> createState() => _HymnScreenState();
}

class _HymnScreenState extends State<HymnScreen> {
  late PageController _pageController;
  late int _currentIndex;

  final FavoritesService _favoritesService = FavoritesService.instance;
  final AudioPlayerService _audioPlayerService = AudioPlayerService.instance;
  late bool _isLiked;

  @override
  void initState() {
    super.initState();
    if (widget.hymn == null || allHymns.isEmpty) {
      _currentIndex = 0;
      _isLiked = false;
    } else {
      _currentIndex =
          allHymns.indexWhere((h) => h.number == widget.hymn!.number);
      if (_currentIndex == -1) _currentIndex = 0;
      _isLiked = _favoritesService.isFavorite(allHymns[_currentIndex].number);
    }

    _pageController = PageController(initialPage: _currentIndex);
    _favoritesService.addListener(_onFavoritesChanged);
    _audioPlayerService.addListener(_onPlayerStateChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _favoritesService.removeListener(_onFavoritesChanged);
    _audioPlayerService.removeListener(_onPlayerStateChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (allHymns.isEmpty) return;
    final isCurrentlyFavorite =
        _favoritesService.isFavorite(allHymns[_currentIndex].number);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isLiked != isCurrentlyFavorite) {
        setState(() {
          _isLiked = isCurrentlyFavorite;
        });
      }
    });
  }

  void _onPlayerStateChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _toggleFavorite() {
    if (allHymns.isEmpty) return;
    final currentHymn = allHymns[_currentIndex];
    final hymnToFavorite =
        FavoriteHymn(number: currentHymn.number, title: currentHymn.title);

    if (_isLiked) {
      _favoritesService.removeFavorite(hymnToFavorite.number);
    } else {
      _favoritesService.addFavorite(hymnToFavorite);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (allHymns.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF090723),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bool isMusicPlaying =
        _audioPlayerService.playerState == PlayerState.playing;
    final Hymn currentHymn = allHymns[_currentIndex];

    return Scaffold(
      appBar: _buildAppBar(currentHymn),
      body: PageView.builder(
        controller: _pageController,
        itemCount: allHymns.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _isLiked = _favoritesService.isFavorite(allHymns[index].number);
          });
        },
        itemBuilder: (context, index) {
          return _HymnPageContent(hymn: allHymns[index]);
        },
      ),
      floatingActionButton: isMusicPlaying ? null : _buildFab(),
    );
  }

  PreferredSizeWidget _buildAppBar(Hymn currentHymn) {
    return AppBar(
      backgroundColor: const Color(0xFF040022),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        currentHymn.number,
        style: TextStyle(
            fontSize: responsiveFontSize(context, 24, minFontSize: 20),
            fontWeight: FontWeight.bold),
      ),
      actions: [
        GestureDetector(
          onLongPress: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FavoritesScreen()));
          },
          child: _buildAppBarButton(
            onPressed: _toggleFavorite,
            icon: Icons.favorite,
            color: _isLiked ? const Color(0xFFFF7645) : const Color(0xFF595773),
            bgColor: const Color(0xFF130F31),
          ),
        ),
        const SizedBox(width: 8),
        _buildAppBarButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => MusicScreen(hymn: currentHymn)),
            );
          },
          icon: Icons.music_note,
          color: Colors.white,
          bgColor: const Color(0xFF130F31),
        ),
        const SizedBox(width: 8),
        Container(
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF130F31), width: 2),
          ),
          child: TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const LanguageSelectionModal(),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('English', style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildAppBarButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildFab() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF090723),
          isScrollControlled: true,
          builder: (context) => const DialPadSheet(),
        );
      },
      backgroundColor: const Color(0xFFFF7645),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: const Icon(Icons.dialpad, color: Colors.white, size: 24),
    );
  }
}

class _HymnPageContent extends StatelessWidget {
  final Hymn hymn;
  const _HymnPageContent({required this.hymn});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 150.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  hymn.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize:
                          responsiveFontSize(context, 24, minFontSize: 20),
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              _buildTimeSignature(context, hymn),
            ],
          ),
          const SizedBox(height: 24),
          _buildHymnLyrics(context),
          if (hymn.hasAmen)
            Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Amen.',
                  style: TextStyle(
                    fontSize: responsiveFontSize(context, 20, minFontSize: 16),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimeSignature(BuildContext context, Hymn hymn) {
    final style = TextStyle(
        fontSize: responsiveFontSize(context, 16, minFontSize: 14),
        color: Colors.white70,
        height: 1.0);
    if (hymn.time.contains('/')) {
      final parts = hymn.time.split('/');
      return Column(
        children: [
          Text(parts[0], style: style),
          Text(parts[1], style: style),
        ],
      );
    } else if (hymn.time.length == 2) {
      return Column(
        children: [
          Text(hymn.time[0], style: style),
          Row(
            children: [
              const SizedBox(width: 20), //Gemini i ADDED a sized box here
              Text(hymn.time[1], style: style)
            ],
          ),
        ],
      );
    }
    return Text(hymn.time, style: style);
  }

  Widget _buildHymnLyrics(BuildContext context) {
    final textStyle = TextStyle(
        fontSize:
            responsiveFontSize(context, 18, minFontSize: 14, maxFontSize: 22),
        height: 1.5,
        fontWeight: FontWeight.w500);
    final boldStyle = textStyle.copyWith(fontWeight: FontWeight.bold);

    List<Widget> sectionWidgets = [];
    for (var section in hymn.sections) {
      sectionWidgets.add(Padding(
        padding: const EdgeInsets.only(bottom: 18.0),
        child: _buildSectionWidget(section, textStyle, boldStyle),
      ));
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: sectionWidgets);
  }

  Widget _buildSectionWidget(
      HymnSection section, TextStyle style, TextStyle boldStyle) {
    List<Widget> children = [];

    String sectionTitle = '';
    bool isHeaderOnOwnLine = false;

    if (section.type != 'verse') {
      sectionTitle =
          '${section.type[0].toUpperCase()}${section.type.substring(1)}:';
      if (sectionTitle.length >= 6) {
        isHeaderOnOwnLine = true;
      }
    }

    if (isHeaderOnOwnLine) {
      children.add(Text(sectionTitle, style: boldStyle));
      children.add(const SizedBox(height: 4.0));
    }

    List<Widget> contentLines = [];
    for (int i = 0; i < section.content.length; i++) {
      final contentItem = section.content[i];

      List<Widget> prefixWidgets = [];
      String lineText = '';

      if (contentItem is LyricDirective) {
        prefixWidgets.add(Text(contentItem.directive,
            style: style.copyWith(
                fontStyle: FontStyle.italic, color: Colors.white70)));
      } else if (contentItem is LyricText) {
        lineText = contentItem.text;
        if (contentItem.part != null) {
          prefixWidgets.add(Text(contentItem.part!, style: boldStyle));
        }
      }

      if (i == 0) {
        if (section.type == 'verse' && section.number != null) {
          prefixWidgets.insert(0, Text('${section.number}.', style: boldStyle));
        } else if (!isHeaderOnOwnLine && sectionTitle.isNotEmpty) {
          prefixWidgets.insert(0, Text(sectionTitle, style: boldStyle));
        }
      }

      contentLines.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 55,
            child: Row(
              children: prefixWidgets
                  .map((w) => Padding(
                      padding: const EdgeInsets.only(right: 2.0), child: w))
                  .toList(),
            ),
          ),
          Expanded(child: Text(lineText, style: style)),
        ],
      ));
    }

    if (isHeaderOnOwnLine) {
      children.add(Padding(
        padding: const EdgeInsets.only(left: 1.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: contentLines),
      ));
    } else {
      children.addAll(contentLines);
    }

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }
}

class PersistentPlayer extends StatelessWidget {
  const PersistentPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final audioPlayerService = AudioPlayerService.instance;
        if (audioPlayerService.currentHymn != null) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  MusicScreen(hymn: audioPlayerService.currentHymn!),
            ),
          );
        }
      },
      child: const Material(
        color: Color(0xFF040022),
        child: MusicPlayerControls(isPersistentPlayer: true),
      ),
    );
  }
}

class MusicPlayerControls extends StatefulWidget {
  final bool isPersistentPlayer;
  const MusicPlayerControls({super.key, this.isPersistentPlayer = false});

  @override
  State<MusicPlayerControls> createState() => _MusicPlayerControlsState();
}

class _MusicPlayerControlsState extends State<MusicPlayerControls> {
  final AudioPlayerService _audioPlayerService = AudioPlayerService.instance;

  @override
  void initState() {
    super.initState();
    _audioPlayerService.addListener(_onPlayerStateChanged);
  }

  @override
  void dispose() {
    _audioPlayerService.removeListener(_onPlayerStateChanged);
    super.dispose();
  }

  void _onPlayerStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final hymn = _audioPlayerService.currentHymn;
    if (hymn == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hymn.title,
            style: TextStyle(
                fontSize: responsiveFontSize(context, 24, minFontSize: 20),
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            hymn.number,
            style: TextStyle(
                fontSize: responsiveFontSize(context, 16, minFontSize: 14),
                color: Colors.white.withAlpha(178)),
          ),
          const SizedBox(height: 16),
          _buildCustomSlider(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAmenButton(),
              _buildSeekButton(false),
              _buildPlayPauseButton(hymn),
              _buildSeekButton(true),
              _buildRepeatButton(),
            ],
          ),
          if (widget.isPersistentPlayer)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _audioPlayerService.stop(),
                  child: Text(
                    'Close',
                    style: TextStyle(
                        fontSize:
                            responsiveFontSize(context, 14, minFontSize: 12),
                        color: Colors.white.withAlpha(178)),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCustomSlider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                30,
                (index) => Container(
                  height: 2,
                  width: (constraints.maxWidth - 60) / 30,
                  color: Colors.white.withAlpha(77),
                ),
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: const Color(0xFFFF7645),
                inactiveTrackColor: Colors.transparent,
                thumbColor: Colors.white,
              ),
              child: Slider(
                min: 0,
                max: _audioPlayerService.duration.inSeconds.toDouble(),
                value: _audioPlayerService.position.inSeconds.toDouble().clamp(
                    0.0, _audioPlayerService.duration.inSeconds.toDouble()),
                onChanged: (value) {
                  _audioPlayerService.seek(Duration(seconds: value.toInt()));
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAmenButton() {
    return SizedBox(
      width: 70,
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text('Amen',
            style: TextStyle(
                color: Colors.white,
                fontSize: responsiveFontSize(context, 16, minFontSize: 14))),
      ),
    );
  }

  Widget _buildSeekButton(bool isForward) {
    return IconButton(
      icon: Icon(isForward ? Icons.fast_forward : Icons.fast_rewind,
          color: Colors.white, size: 32),
      onPressed: () {
        final newPosition = isForward
            ? _audioPlayerService.position + const Duration(seconds: 10)
            : _audioPlayerService.position - const Duration(seconds: 10);
        _audioPlayerService.seek(newPosition);
      },
    );
  }

  Widget _buildPlayPauseButton(Hymn hymn) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFFF7645),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFFFF7645).withAlpha(100),
              blurRadius: 10,
              spreadRadius: 2)
        ],
      ),
      child: IconButton(
        icon: Icon(
          _audioPlayerService.playerState == PlayerState.playing
              ? Icons.pause
              : Icons.play_arrow,
          color: Colors.white,
          size: 40,
        ),
        onPressed: () {
          if (_audioPlayerService.playerState == PlayerState.playing) {
            _audioPlayerService.pause();
          } else {
            _audioPlayerService.play(hymn);
          }
        },
        padding: const EdgeInsets.all(12),
      ),
    );
  }

  Widget _buildRepeatButton() {
    return SizedBox(
      width: 70,
      child: IconButton(
        icon: Icon(
          Icons.repeat,
          color: _audioPlayerService.isLooping
              ? const Color(0xFFFF7645)
              : Colors.white,
          size: 28,
        ),
        onPressed: _audioPlayerService.toggleLooping,
      ),
    );
  }
}

class LanguageSelectionModal extends StatelessWidget {
  const LanguageSelectionModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF130F31),
      title: Text('Select Version',
          style: TextStyle(
              color: Colors.white,
              fontSize: responsiveFontSize(context, 20, minFontSize: 18))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('English', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.check, color: Color(0xFFFF7645)),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const Text('Igbo', style: TextStyle(color: Colors.white70)),
            onTap: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Igbo Version will be available soon.',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Color(0xFF130F31),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DialPadSheet extends StatefulWidget {
  const DialPadSheet({super.key});

  @override
  State<DialPadSheet> createState() => _DialPadSheetState();
}

class _DialPadSheetState extends State<DialPadSheet> {
  String _enteredNumber = '';
  String _errorMessage = '';

  void _onNumberPressed(String number) {
    if (_errorMessage.isNotEmpty) {
      setState(() {
        _errorMessage = '';
      });
    }

    final potentialNumber = int.tryParse(_enteredNumber + number) ?? 0;
    if (potentialNumber <= 1000) {
      setState(() {
        _enteredNumber += number;
      });
    }
  }

  void _onBackspacePressed() {
    setState(() {
      if (_enteredNumber.isNotEmpty) {
        _enteredNumber = _enteredNumber.substring(0, _enteredNumber.length - 1);
      }
    });
  }

  void _openHymn() {
    if (_enteredNumber.isEmpty) return;

    final int number = int.tryParse(_enteredNumber) ?? 0;
    if (number < 1 || number > 1000) {
      _showHymnNotFound();
      return;
    }

    try {
      final hymnToOpen = allHymns.firstWhere((h) => h.hymnNumber == number);
      Navigator.pop(context); // Close the modal
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => HymnScreen(hymn: hymnToOpen)));
    } catch (e) {
      _showHymnNotFound();
    }
  }

  void _showHymnNotFound() {
    setState(() {
      _errorMessage = 'Hymn not found.';
      _enteredNumber = '';
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _errorMessage = '';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(100),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Number search',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              responsiveFontSize(context, 24, minFontSize: 20),
                          fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the modal
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const IndexScreen()));
                    },
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Colors.white.withAlpha(100)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    child: Text('A-Z',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: responsiveFontSize(context, 16,
                                minFontSize: 14))),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 60,
                  width: 250,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF130F31),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _errorMessage.isNotEmpty
                            ? Colors.red
                            : Colors.transparent),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _errorMessage.isNotEmpty
                          ? Row(
                              key: const ValueKey('error'),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  _errorMessage,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize: responsiveFontSize(context, 16,
                                          minFontSize: 14)),
                                ),
                              ],
                            )
                          : Text(
                              key: const ValueKey('number'),
                              _enteredNumber,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: responsiveFontSize(context, 32,
                                      minFontSize: 28),
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Table(
                children: [
                  TableRow(children: [
                    _buildNumberButton('1'),
                    _buildNumberButton('2'),
                    _buildNumberButton('3')
                  ]),
                  TableRow(children: [
                    _buildNumberButton('4'),
                    _buildNumberButton('5'),
                    _buildNumberButton('6')
                  ]),
                  TableRow(children: [
                    _buildNumberButton('7'),
                    _buildNumberButton('8'),
                    _buildNumberButton('9')
                  ]),
                  TableRow(children: [
                    _buildOpenButton(),
                    _buildNumberButton('0'),
                    _buildBackspaceButton()
                  ]),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: InkWell(
        onTap: () => _onNumberPressed(number),
        borderRadius: BorderRadius.circular(40),
        child: Center(
          child: Text(number,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: responsiveFontSize(context, 36, minFontSize: 30))),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
        onPressed: _onBackspacePressed,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF130F31),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        child: const Icon(Icons.backspace_outlined, color: Colors.white),
      ),
    );
  }

  Widget _buildOpenButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextButton(
        onPressed: _openHymn,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFFF7645),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        child: Text('Open',
            style: TextStyle(
                color: Colors.white,
                fontSize: responsiveFontSize(context, 18, minFontSize: 16))),
      ),
    );
  }
}
