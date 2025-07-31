// --- Data Models for Bible ---

class BibleVersion {
  final String abbreviation;
  final String fullName;

  const BibleVersion({required this.abbreviation, required this.fullName});
}

class BibleBook {
  final String name;
  final int chapters;

  const BibleBook({required this.name, required this.chapters});
}

class BibleVerse {
  final int verseNumber;
  final String text;

  const BibleVerse({required this.verseNumber, required this.text});
}

// --- Mock Data ---

final List<BibleVersion> bibleVersions = [
  const BibleVersion(abbreviation: 'KJV', fullName: 'King James Version'),
  const BibleVersion(abbreviation: 'RSV', fullName: 'Revised Standard Version'),
  const BibleVersion(abbreviation: 'IGBOB', fullName: 'Bible Nso'),
  const BibleVersion(
      abbreviation: 'PCM', fullName: 'Holy Bible Nigerian Pidgin English'),
  const BibleVersion(abbreviation: 'ENA', fullName: 'Edisana nwed Abasi Ibom'),
  const BibleVersion(abbreviation: 'BM', fullName: 'Bibeli Mimo'),
  const BibleVersion(abbreviation: 'SRK', fullName: 'Sabon Rai Don Kowa 2020'),
];

final List<BibleBook> oldTestamentBooks = [
  // Add all Old Testament books here
  const BibleBook(name: 'Genesis', chapters: 50),
  const BibleBook(name: 'Exodus', chapters: 40),
];

final List<BibleBook> newTestamentBooks = [
  const BibleBook(name: 'Matthew', chapters: 28),
  const BibleBook(name: 'Mark', chapters: 16),
  const BibleBook(name: 'Luke', chapters: 24),
  const BibleBook(name: 'John', chapters: 21),
  const BibleBook(name: 'Acts', chapters: 28),
  const BibleBook(name: 'Romans', chapters: 16),
  const BibleBook(name: '1 Corinthians', chapters: 16),
  const BibleBook(name: '2 Corinthians', chapters: 13),
  const BibleBook(name: 'Galatians', chapters: 6),
  const BibleBook(name: 'Ephesians', chapters: 6),
  const BibleBook(name: 'Philippians', chapters: 4),
  const BibleBook(name: 'Colossians', chapters: 4),
  const BibleBook(name: '1 Thessalonians', chapters: 5),
  const BibleBook(name: '2 Thessalonians', chapters: 3),
  const BibleBook(name: '1 Timothy', chapters: 6),
  const BibleBook(name: '2 Timothy', chapters: 4),
  const BibleBook(name: 'Titus', chapters: 3),
  const BibleBook(name: 'Philemon', chapters: 1),
  const BibleBook(name: 'Hebrews', chapters: 13),
  const BibleBook(name: 'James', chapters: 5),
  const BibleBook(name: '1 Peter', chapters: 5),
  const BibleBook(name: '2 Peter', chapters: 3),
  const BibleBook(name: '1 John', chapters: 5),
  const BibleBook(name: '2 John', chapters: 1),
  const BibleBook(name: '3 John', chapters: 1),
  const BibleBook(name: 'Jude', chapters: 1),
  const BibleBook(name: 'Revelation', chapters: 22),
];

// Mock content for John 3
final List<BibleVerse> johnChapter3 = [
  const BibleVerse(
      verseNumber: 1,
      text:
          'There was a man of the Pharisees, named Nicodemus, a ruler of the Jews:'),
  const BibleVerse(
      verseNumber: 2,
      text:
          'The same came to Jesus by night, and said unto him, Rabbi, we know that thou art a teacher come from God: for no man can do these miracles that thou doest, except God be with him.'),
  const BibleVerse(
      verseNumber: 3,
      text:
          'Jesus answered and said unto him, Verily, verily, a say unto thee, Expect a man be born again, he cannot see the the kingdom of God.'),
  const BibleVerse(
      verseNumber: 4,
      text:
          'Nicodemus saith unto him, How can a man be born when he is old? can he enter the second time into his mother\'s womb, and be born?'),
  // ... add all verses for John 3
];
