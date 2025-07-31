import 'package:flutter/material.dart';
import 'hymn_data.dart';
import 'main.dart'; // For HymnScreen and responsiveFontSize

// --- Data Model for Topical Categories ---
class TopicalCategory {
  final String name;
  final int start;
  final int end;

  const TopicalCategory(
      {required this.name, required this.start, required this.end});
}

// --- List of Topical Categories ---
final List<TopicalCategory> topicalCategories = [
  const TopicalCategory(name: 'Praise/Opening', start: 1, end: 96),
  const TopicalCategory(name: 'Prayer & Fasting', start: 97, end: 153),
  const TopicalCategory(name: 'Holy Spirit', start: 154, end: 186),
  const TopicalCategory(name: 'Gospel/Invitation', start: 187, end: 222),
  const TopicalCategory(name: 'Gospel/The Word', start: 223, end: 289),
  const TopicalCategory(name: 'Gospel/Redemption', start: 290, end: 321),
  const TopicalCategory(name: 'Gospel/Warning', start: 322, end: 339),
  const TopicalCategory(name: 'Gospel/Entreaty', start: 340, end: 374),
  const TopicalCategory(
      name: 'Faith, Assurance & Victory', start: 375, end: 452),
  const TopicalCategory(
      name: 'Testimony & God\'s Promises', start: 453, end: 528),
  const TopicalCategory(name: 'Repentance/Response', start: 529, end: 620),
  const TopicalCategory(name: 'Christian Life & Service', start: 621, end: 687),
  const TopicalCategory(name: 'Comfort in Sorrow', start: 688, end: 727),
  const TopicalCategory(name: 'Divine Healing', start: 728, end: 734),
  const TopicalCategory(
      name: 'Divine Guidance & Protection', start: 735, end: 781),
  const TopicalCategory(
      name: 'The Birth & Coming of Christ', start: 782, end: 815),
  const TopicalCategory(name: 'Heaven/God\'s Kingdom', start: 816, end: 902),
  const TopicalCategory(name: 'Special Occasions', start: 903, end: 917),
  const TopicalCategory(name: 'Children', start: 918, end: 948),
  const TopicalCategory(name: 'Choruses', start: 949, end: 985),
  const TopicalCategory(name: 'Closing', start: 986, end: 1000),
];

class IndexScreen extends StatefulWidget {
  const IndexScreen({super.key});

  @override
  State<IndexScreen> createState() => _IndexScreenState();
}

class _IndexScreenState extends State<IndexScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090723),
      appBar: AppBar(
        backgroundColor: const Color(0xFF040022),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Index",
          style: TextStyle(
              fontSize: responsiveFontSize(context, 24, minFontSize: 20),
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFF7645),
          indicatorWeight: 3,
          labelColor: const Color(0xFFFF7645),
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(
              fontSize: responsiveFontSize(context, 16, minFontSize: 14),
              fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(
              fontSize: responsiveFontSize(context, 16, minFontSize: 14)),
          tabs: const [
            Tab(text: 'Alphabetical'),
            Tab(text: 'Topical'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AlphabeticalIndex(),
          TopicalIndex(),
        ],
      ),
    );
  }
}

// --- Alphabetical Index Widget ---
class AlphabeticalIndex extends StatefulWidget {
  const AlphabeticalIndex({super.key});

  @override
  State<AlphabeticalIndex> createState() => _AlphabeticalIndexState();
}

class _AlphabeticalIndexState extends State<AlphabeticalIndex> {
  String _selectedLetter = 'A';
  final List<String> _alphabet = List.generate(
      26, (index) => String.fromCharCode('A'.codeUnitAt(0) + index));

  late final Map<String, List<Hymn>> _alphabeticalHymns;

  @override
  void initState() {
    super.initState();
    _alphabeticalHymns = _groupHymnsByFirstLetter(allHymns);
  }

  Map<String, List<Hymn>> _groupHymnsByFirstLetter(List<Hymn> hymns) {
    final Map<String, List<Hymn>> grouped = {};
    for (var hymn in hymns) {
      if (hymn.firstLine.isNotEmpty) {
        final firstLetter = hymn.firstLine[0].toUpperCase();
        if (grouped.containsKey(firstLetter)) {
          grouped[firstLetter]!.add(hymn);
        } else {
          grouped[firstLetter] = [hymn];
        }
      }
    }
    grouped.forEach((key, value) {
      value.sort((a, b) => a.firstLine.compareTo(b.firstLine));
    });
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final hymnsForSelectedLetter = _alphabeticalHymns[_selectedLetter] ?? [];

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _alphabet.length,
            itemBuilder: (context, index) {
              final letter = _alphabet[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedLetter = letter;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _selectedLetter == letter
                            ? const Color(0xFFFF7645)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: _selectedLetter == letter
                          ? const Color(0xFFFF7645)
                          : Colors.white70,
                      fontSize: responsiveFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hymnsForSelectedLetter.length,
            itemBuilder: (context, index) {
              final hymn = hymnsForSelectedLetter[index];
              return _buildHymnListItem(context, hymn, useFirstLine: true);
            },
          ),
        ),
      ],
    );
  }
}

// --- Topical Index Widget ---
class TopicalIndex extends StatefulWidget {
  const TopicalIndex({super.key});

  @override
  State<TopicalIndex> createState() => _TopicalIndexState();
}

class _TopicalIndexState extends State<TopicalIndex> {
  late TopicalCategory _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory = topicalCategories[0];
  }

  List<Hymn> _getHymnsForCategory(TopicalCategory category) {
    return allHymns.where((hymn) {
      final hymnNumber = int.tryParse(hymn.number.split(' ').last) ?? 0;
      return hymnNumber >= category.start && hymnNumber <= category.end;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hymnsForSelectedCategory = _getHymnsForCategory(_selectedCategory);

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: topicalCategories.length,
            itemBuilder: (context, index) {
              final category = topicalCategories[index];
              final isSelected = category.name == _selectedCategory.name;
              final categoryDisplayName =
                  '${category.name} (${category.start}-${category.end})';

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? const Color(0xFFFF7645)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    categoryDisplayName,
                    style: TextStyle(
                      color:
                          isSelected ? const Color(0xFFFF7645) : Colors.white70,
                      fontSize: responsiveFontSize(context, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hymnsForSelectedCategory.length,
            itemBuilder: (context, index) {
              final hymn = hymnsForSelectedCategory[index];
              return _buildHymnListItem(context, hymn);
            },
          ),
        ),
      ],
    );
  }
}

// --- Reusable Hymn List Item ---
Widget _buildHymnListItem(BuildContext context, Hymn hymn,
    {bool useFirstLine = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HymnScreen(hymn: hymn)),
        );
      },
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xFF130F31),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            useFirstLine ? hymn.firstLine : hymn.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: responsiveFontSize(context, 18, minFontSize: 16),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hymn.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: responsiveFontSize(context, 16, minFontSize: 14),
            ),
          ),
        ],
      ),
    ),
  );
}
