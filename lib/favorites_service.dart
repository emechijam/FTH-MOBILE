import 'package:flutter/material.dart';

// A simple data class for a favorite hymn item.
class FavoriteHymn {
  final String number;
  final String title;

  const FavoriteHymn({required this.number, required this.title});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteHymn &&
          runtimeType == other.runtimeType &&
          number == other.number;

  @override
  int get hashCode => number.hashCode;
}

// This service manages the state of favorite hymns across the entire app.
class FavoritesService extends ChangeNotifier {
  FavoritesService._privateConstructor();
  static final FavoritesService _instance =
      FavoritesService._privateConstructor();
  static FavoritesService get instance => _instance;

  // **FIX**: The list of favorites now starts empty by default.
  // This ensures the app starts with no favorites selected.
  final List<FavoriteHymn> _favorites = [];

  List<FavoriteHymn> get favorites => _favorites;

  bool isFavorite(String hymnNumber) {
    return _favorites.any((hymn) => hymn.number == hymnNumber);
  }

  void addFavorite(FavoriteHymn hymn) {
    if (!isFavorite(hymn.number)) {
      _favorites.add(hymn);
      notifyListeners();
    }
  }

  void removeFavorite(String hymnNumber) {
    _favorites.removeWhere((hymn) => hymn.number == hymnNumber);
    notifyListeners();
  }
}
