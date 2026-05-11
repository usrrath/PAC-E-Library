import 'package:flutter/material.dart';

import '../models/library_detail_model.dart';
import '../services/library_detail_service.dart';
import 'library_screen.dart';
import 'library_view_screen.dart';

class LibraryDetailScreen extends StatefulWidget {
  final Book book;
  final List<Book> allBooks;

  const LibraryDetailScreen({
    super.key,
    required this.book,
    required this.allBooks,
  });

  @override
  State<LibraryDetailScreen> createState() => _LibraryDetailScreenState();
}

class _LibraryDetailScreenState extends State<LibraryDetailScreen> {
  final LibraryDetailService _service = LibraryDetailService();

  late Book _book;
  LibraryDetailModel? _detail;

  bool _loading = true;
  bool _favoriteLoading = false;
  bool _similarLoading = false;
  bool _isFavorite = false;

  String? _error;
  List<LibraryDetailModel> _similarBooks = const [];

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _loadData();
  }

  Future<void> _loadData() async {
    if (_book.id.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Book ID not found.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _service.getBookDetail(_book.id),
        _service.checkFavorite(_book.id),
        _service.getSimilarTitles(_book.id),
      ]);

      if (!mounted) return;

      final detail = results[0] as LibraryDetailModel;
      final favorite = results[1] as bool;
      final similar = results[2] as List<LibraryDetailModel>;

      setState(() {
        _detail = detail;
        _book = _toBook(detail);
        _isFavorite = favorite;
        _similarBooks = similar;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_favoriteLoading || _book.id.trim().isEmpty) return;

    setState(() => _favoriteLoading = true);

    try {
      final value = await _service.toggleFavorite(
        id: _book.id,
        isFavorite: _isFavorite,
      );

      if (!mounted) return;
      setState(() => _isFavorite = value);
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _favoriteLoading = false);
    }
  }

  Book _toBook(LibraryDetailModel item) {
    return Book(
      id: item.id.trim(),
      title: item.title.trim().isNotEmpty ? item.title.trim() : 'Untitled',
      author: item.author.trim().isNotEmpty
          ? item.author.trim()
          : 'Unknown Author',
      publisher: '',
      rating: 0,
      categories: item.categories,
      tags: item.tags,
      description: item.description.trim().isNotEmpty
          ? item.description.trim()
          : 'No description available.',
      coverUrl: _service.fullUrl(item.coverUrl),
      reviews: const [],
    );
  }

  bool get _canRead => _book.id.trim().isNotEmpty;

  String get _year {
    final value = _detail?.year.trim() ?? '';
    return value.isEmpty ? 'Unknown' : value;
  }

  void _openReader() {
    if (!_canRead) {
      _showSnack('Book not found.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LibraryViewScreen(book: _book),
      ),
    );
  }

  void _openSimilarBook(LibraryDetailModel item) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LibraryDetailScreen(
          book: _toBook(item),
          allBooks: widget.allBooks,
        ),
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted || message.trim().isEmpty) return;

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading ? _loadingView() : _contentView(),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text(
        'Book Details',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      actions: [
        IconButton(
          tooltip: _isFavorite ? 'Remove favorite' : 'Add to favorites',
          onPressed: _favoriteLoading ? null : _toggleFavorite,
          color: _isFavorite ? Colors.red : null,
          icon: _favoriteLoading
              ? const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : Icon(
            _isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
          ),
        ),
      ],
    );
  }

  Widget _loadingView() {
    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 160),
        Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _contentView() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        if (_error != null) ...[
          _ErrorBox(message: _error!),
          const SizedBox(height: 12),
        ],
        _Header(
          book: _book,
          canRead: _canRead,
          onRead: _openReader,
        ),
        const SizedBox(height: 18),
        InfoChips(title: 'Category', items: _book.categories),
        const SizedBox(height: 10),
        InfoChips(title: 'Tags', items: _book.tags),
        const SizedBox(height: 18),
        _YearBox(year: _year),
        const SizedBox(height: 18),
        _Description(text: _book.description),
        const SizedBox(height: 18),
        _SimilarSection(
          loading: _similarLoading,
          items: _similarBooks,
          toBook: _toBook,
          onTap: _openSimilarBook,
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final Book book;
  final bool canRead;
  final VoidCallback onRead;

  const _Header({
    required this.book,
    required this.canRead,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CachedNetImage(
            url: book.coverUrl,
            width: 120,
            height: 170,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                book.author,
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.65),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canRead ? onRead : null,
                  icon: const Icon(Icons.menu_book_rounded),
                  label: const Text(
                    'Read',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: cs.primary,
                    foregroundColor: cs.onPrimary,
                    disabledBackgroundColor: cs.surfaceContainerHighest,
                    disabledForegroundColor: cs.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class InfoChips extends StatelessWidget {
  final String title;
  final List<String> items;

  const InfoChips({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Text(
        '$title: Unknown',
        style: TextStyle(
          color: cs.onSurface.withOpacity(0.65),
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: items.map((item) => _ChipLabel(text: item)).toList(),
        ),
      ],
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final String text;

  const _ChipLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.18)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _YearBox extends StatelessWidget {
  final String year;

  const _YearBox({required this.year});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month_rounded, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            'Year: $year',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _Description extends StatelessWidget {
  final String text;

  const _Description({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final value = text.trim().isEmpty ? 'No description available.' : text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          value.length > 300 ? '${value.substring(0, 300).trim()}...' : value,
          style: TextStyle(
            color: cs.onSurface.withOpacity(0.75),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _SimilarSection extends StatelessWidget {
  final bool loading;
  final List<LibraryDetailModel> items;
  final Book Function(LibraryDetailModel item) toBook;
  final void Function(LibraryDetailModel item) onTap;

  const _SimilarSection({
    required this.loading,
    required this.items,
    required this.toBook,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Similar titles',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        if (loading)
          const SizedBox(
            height: 210,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (items.isEmpty)
          Text(
            'No recommendations found.',
            style: TextStyle(color: cs.onSurface.withOpacity(0.65)),
          )
        else
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final item = items[index];

                return SizedBox(
                  width: 140,
                  child: MiniBookCard(
                    book: toBook(item),
                    onTap: () => onTap(item),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class MiniBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const MiniBookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outline.withOpacity(0.10)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetImage(
                url: book.coverUrl,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                book.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;

  const _ErrorBox({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: cs.onErrorContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}