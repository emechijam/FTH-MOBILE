import 'package:flutter/material.dart';
import 'favorites_service.dart'; // Import the service
import 'main.dart'; // Import for HymnScreen
import 'hymn_data.dart'; // Import the mock database

// The Favorites Screen widget
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService.instance;

  @override
  void initState() {
    super.initState();
    _favoritesService.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    _favoritesService.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  // Function to show confirmation dialog and remove hymn
  Future<void> _confirmAndRemoveFavorite(FavoriteHymn hymn) async {
    bool? confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF130F31),
          title: const Text("Confirm", style: TextStyle(color: Colors.white)),
          content: const Text(
              "Are you sure you wish to remove this hymn from favourites?",
              style: TextStyle(color: Colors.white70)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child:
                  const Text("CANCEL", style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("REMOVE",
                  style: TextStyle(color: Color(0xFFFF7645))),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _favoritesService.removeFavorite(hymn.number);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = _favoritesService.favorites;

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
          "Favourites",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? _buildEmptyState()
          : _buildFavoritesList(favorites),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.favorite,
                color: Color(0xFFFF7645),
                size: 80,
              ),
              Positioned(
                right: -4,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFF090723),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_circle,
                    color: Color(0xFFFF7645),
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Your favourite hymns will appear\nhere',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withAlpha(178),
              fontSize: 18,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<FavoriteHymn> favorites) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final favHymn = favorites[index];
        return Dismissible(
          key: Key(favHymn.number),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (direction) async {
            await _confirmAndRemoveFavorite(favHymn);
            return _favoritesService.isFavorite(favHymn.number) == false;
          },
          onDismissed: (direction) {
            // This is now handled by the confirmation dialog logic.
          },
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            title: Text(
              favHymn.number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              favHymn.title,
              style: TextStyle(
                color: Colors.white.withAlpha(204),
                fontSize: 16,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Color(0xFFFF7645),
              ),
              onPressed: () => _confirmAndRemoveFavorite(favHymn),
            ),
            onTap: () {
              final hymnToOpen = allHymns.firstWhere(
                (h) => h.number == favHymn.number,
                orElse: () => allHymns[0],
              );
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HymnScreen(hymn: hymnToOpen),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
