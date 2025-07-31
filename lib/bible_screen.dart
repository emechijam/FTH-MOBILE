import 'package:flutter/material.dart';
import 'bible_data.dart';
import 'main.dart'; // For responsiveFontSize and MusicPlayerControls

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  BibleVersion _selectedVersion = bibleVersions[0];
  String _selectedBook = 'John';
  int _selectedChapter = 3;

  void _showSearch() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BibleSearchSheet(),
    );
  }

  void _showVersions() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const VersionsScreen()),
    );
  }

  void _showAudioPlayer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF040022),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => AudioBiblePlayer(
          book: _selectedBook,
          chapter: _selectedChapter,
          version: _selectedVersion),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090723),
      appBar: AppBar(
        backgroundColor: const Color(0xFF040022),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          '$_selectedBook $_selectedChapter',
          style: TextStyle(
              fontSize: responsiveFontSize(context, 24, minFontSize: 20),
              fontWeight: FontWeight.bold),
        ),
        actions: [
          _buildVersionSelector(),
          _buildAudioButton(),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildVerseList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSearch,
        backgroundColor: const Color(0xFFFF7645),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.apps, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildVersionSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF130F31),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BibleVersion>(
          value: _selectedVersion,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
          dropdownColor: const Color(0xFF130F31),
          style: const TextStyle(color: Colors.white, fontFamily: 'DMSans'),
          onChanged: (BibleVersion? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedVersion = newValue;
              });
            }
          },
          items: bibleVersions
              .map<DropdownMenuItem<BibleVersion>>((BibleVersion version) {
            return DropdownMenuItem<BibleVersion>(
              value: version,
              child: Text(version.abbreviation),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAudioButton() {
    return IconButton(
      onPressed: _showAudioPlayer,
      icon: const Icon(Icons.volume_up_outlined, color: Colors.white, size: 28),
    );
  }

  Widget _buildVerseList() {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: johnChapter3.length,
      itemBuilder: (context, index) {
        final verse = johnChapter3[index];
        final isHighlighted = verse.verseNumber == 3;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'DMSans',
                fontSize: responsiveFontSize(context, 20, minFontSize: 18),
                color: Colors.white,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: '${verse.verseNumber}. ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: verse.text,
                  style: TextStyle(
                      color: isHighlighted ? Colors.red : Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// --- Bible Search Sheet ---
class BibleSearchSheet extends StatefulWidget {
  const BibleSearchSheet({super.key});

  @override
  State<BibleSearchSheet> createState() => _BibleSearchSheetState();
}

class _BibleSearchSheetState extends State<BibleSearchSheet>
    with TickerProviderStateMixin {
  late TabController _testamentTabController;
  late TabController _selectionTabController;

  @override
  void initState() {
    super.initState();
    _testamentTabController = TabController(length: 2, vsync: this);
    _selectionTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _testamentTabController.dispose();
    _selectionTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Color(0xFF090723),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text('Search',
                style: TextStyle(fontWeight: FontWeight.bold)),
            bottom: TabBar(
              controller: _testamentTabController,
              indicatorColor: const Color(0xFFFF7645),
              tabs: const [
                Tab(text: 'Old Testament'),
                Tab(text: 'New Testament'),
              ],
            ),
          ),
          // ... The rest of the search UI will go here
        ],
      ),
    );
  }
}

// --- Versions Screen ---
class VersionsScreen extends StatelessWidget {
  const VersionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090723),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Versions',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        itemCount: bibleVersions.length,
        itemBuilder: (context, index) {
          final version = bibleVersions[index];
          return ListTile(
            title: Text(version.abbreviation,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(version.fullName,
                style: const TextStyle(color: Colors.white70)),
            onTap: () {
              // TODO: Implement version selection logic
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}

// --- Audio Bible Player ---
class AudioBiblePlayer extends StatelessWidget {
  final String book;
  final int chapter;
  final BibleVersion version;

  const AudioBiblePlayer(
      {super.key,
      required this.book,
      required this.chapter,
      required this.version});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$book $chapter',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: responsiveFontSize(context, 24),
                  fontWeight: FontWeight.bold)),
          Text("The Listener's Bible: ${version.abbreviation} Edition",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          // Placeholder for the actual audio player controls
          const MusicPlayerControls(),
        ],
      ),
    );
  }
}
