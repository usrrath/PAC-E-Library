import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/library_models.dart';
import '../services/favorites_service.dart';
import '../widgets/favorite_widgets.dart';
import 'library_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _service = FavoritesService();

  bool _loading = true;
  String? _error;

  List<Book> _books = [];
  Map<String, List<String>> _bookCategories = {};
  Map<String, List<String>> _bookTags = {};

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll({bool refresh = false}) async {
    if (!mounted) return;

    setState(() {
      _loading = _books.isEmpty;
      _error = null;
    });

    try {
      final result = await _service.loadFavorites(refresh: refresh);

      if (!mounted) return;

      setState(() {
        _books = result.books;
        _bookCategories = result.categories;
        _bookTags = result.tags;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      final t = AppLocalizations.of(context)!;

      setState(() {
        _loading = false;
        _error = t.favoritesScreenUnableLoadData;
      });
    }
  }

  void _openBook(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LibraryDetailScreen(
          book: book,
          allBooks: _books,
        ),
      ),
    );
  }

  Future<void> _removeFavorite(Book book) async {
    final t = AppLocalizations.of(context)!;

    try {
      await _service.removeFavorite(book.id);

      if (!mounted) return;

      setState(() {
        _books.removeWhere((e) => e.id == book.id);
        _bookCategories.remove(book.id);
        _bookTags.remove(book.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${book.title} ${t.favoritesScreenRemoved}')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.favoritesScreenUnableLoadData)),
      );
    }
  }

  Future<void> _confirmRemove(Book book) async {
    final t = AppLocalizations.of(context)!;

    final remove = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final cs = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_rounded, color: cs.error, size: 42),
              const SizedBox(height: 10),
              Text(
                t.favoritesScreenRemoveFromFavorites,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                book.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(t.favoritesScreenCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(t.favoritesScreenRemove),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (remove == true) {
      await _removeFavorite(book);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.favoritesScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadAll(refresh: true),
        child: _buildBody(cs, t),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs, AppLocalizations t) {
    if (_loading) return const FavoriteLoadingList();

    if (_error != null) {
      return FavoriteErrorView(
        message: _error!,
        onRetry: () => _loadAll(refresh: true),
      );
    }

    if (_books.isEmpty) return FavoriteEmptyView(colorScheme: cs);

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      itemCount: _books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final book = _books[index];

        return FavoriteBookCard(
          book: book,
          categories: _bookCategories[book.id] ?? const [],
          tags: _bookTags[book.id] ?? const [],
          onTap: () => _openBook(book),
          onLongPress: () => _confirmRemove(book),
        );
      },
    );
  }
}