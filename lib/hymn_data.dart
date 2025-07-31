import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

// --- Data Models ---

// Base class for any line in a hymn section
abstract class LyricContent {}

// Represents a standard line of text, with an optional vocal part
class LyricText extends LyricContent {
  final String text;
  final String? part;

  LyricText({required this.text, this.part});

  factory LyricText.fromJson(Map<String, dynamic> json) {
    return LyricText(
      text: json['text'],
      part: json['part'],
    );
  }
}

// Represents a musical directive
class LyricDirective extends LyricContent {
  final String directive;

  LyricDirective(this.directive);

  factory LyricDirective.fromJson(Map<String, dynamic> json) {
    return LyricDirective(json['directive']);
  }
}

// Represents a distinct section of a hymn (verse, chorus, etc.)
class HymnSection {
  final String type;
  final int? number;
  final List<LyricContent> content;

  HymnSection({required this.type, this.number, required this.content});

  factory HymnSection.fromJson(Map<String, dynamic> json) {
    var contentList = json['content'] as List;
    List<LyricContent> content = contentList.map((item) {
      if (item.containsKey('directive')) {
        return LyricDirective.fromJson(item);
      }
      return LyricText.fromJson(item);
    }).toList();

    return HymnSection(
      type: json['type'],
      number: json['number'],
      content: content,
    );
  }
}

// The main data model for a single hymn
class Hymn {
  final String hymnId;
  final int hymnNumber;
  final String number;
  final String title;
  final String time;
  final List<HymnSection> sections;
  final bool hasAmen;
  final String audioAsset;
  final String imageAsset;

  const Hymn({
    required this.hymnId,
    required this.hymnNumber,
    required this.number,
    required this.title,
    required this.time,
    required this.sections,
    required this.hasAmen,
    required this.audioAsset,
    required this.imageAsset,
  });

  factory Hymn.fromJson(Map<String, dynamic> json) {
    var sectionsList = json['sections'] as List;
    List<HymnSection> sections =
        sectionsList.map((i) => HymnSection.fromJson(i)).toList();

    return Hymn(
      hymnId: 'fth_${json['number'].toString().padLeft(4, '0')}',
      hymnNumber: int.parse(json['number']),
      number: 'FTH ${json['number']}',
      title: json['title'],
      time: json['timeSignature'] ?? '',
      sections: sections,
      hasAmen: json['amen'] ?? false,
      audioAsset: 'audio/fth_${json['number']}.mp3',
      imageAsset: 'images/fth_${json['number']}.jpg',
    );
  }

  String get firstLine {
    for (var section in sections) {
      for (var line in section.content) {
        if (line is LyricText) {
          return line.text;
        }
      }
    }
    return '';
  }
}

// This list will be populated by loading the JSON
List<Hymn> allHymns = [];

// Function to load and parse the hymns from the JSON file
Future<void> loadHymns() async {
  try {
    final String response = await rootBundle.loadString('assets/fth.json');
    final data = await json.decode(response) as List;
    allHymns = data.map((json) => Hymn.fromJson(json)).toList();
  } catch (e) {
    // In a production app, you might want to handle this error more gracefully
  }
}
