import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/library_detail_model.dart';
import '../models/library_models.dart';
import '../services/library_detail_service.dart';
import '../utils/library_detail_utils.dart';
import '../widgets/library_detail_widgets.dart';
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
  List<LibraryDetailModel> _similarBooks = const [];

  bool _loading = true;
  bool _favoriteLoading = false;
  bool _isFavorite = false;

  String? _error;

  AppLocalizations get tr => AppLocalizations.of(context)!;

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
        _error = tr.libraryDetailBookIdNotFound;
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
        _error = LibraryDetailUtils.cleanError(
          error: e,
          fallback: tr.libraryDetailFailedLoad,
        );
      });
    } finally {
      if (mounted) setState(() => _loading = false);
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
      _showSnack(
        LibraryDetailUtils.cleanError(
          error: e,
          fallback: tr.libraryDetailFailedFavorite,
        ),
      );
    } finally {
      if (mounted) setState(() => _favoriteLoading = false);
    }
  }

  Book _toBook(LibraryDetailModel item) {
    return LibraryDetailUtils.toBook(
      item: item,
      service: _service,
      untitled: tr.libraryDetailUntitled,
      unknownAuthor: tr.libraryDetailUnknownAuthor,
      noDescription: tr.libraryDetailNoDescription,
    );
  }

  bool get _canRead => _book.id.trim().isNotEmpty;

  String get _year {
    return LibraryDetailUtils.cleanYear(
      _detail?.year,
      unknown: tr.libraryDetailUnknown,
    );
  }

  void _openReader() {
    if (!_canRead) {
      _showSnack(tr.libraryDetailBookNotFound);
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
      title: Text(
        tr.libraryDetailTitle,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      actions: [
        IconButton(
          tooltip: _isFavorite
              ? tr.libraryDetailRemoveFavorite
              : tr.libraryDetailAddFavorite,
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
          LibraryErrorBox(message: _error!),
          const SizedBox(height: 12),
        ],
        LibraryDetailHeader(
          book: _book,
          canRead: _canRead,
          readLabel: tr.libraryDetailRead,
          onRead: _openReader,
        ),
        const SizedBox(height: 18),
        LibraryInfoChips(
          title: tr.libraryDetailCategory,
          unknownLabel: tr.libraryDetailUnknown,
          items: _book.categories,
        ),
        const SizedBox(height: 10),
        LibraryInfoChips(
          title: tr.libraryDetailTags,
          unknownLabel: tr.libraryDetailUnknown,
          items: _book.tags,
        ),
        const SizedBox(height: 18),
        LibraryYearBox(
          year: _year,
          yearLabel: tr.libraryDetailYear,
        ),
        const SizedBox(height: 18),
        LibraryDescription(
          title: tr.libraryDetailDescription,
          text: _book.description,
          emptyLabel: tr.libraryDetailNoDescription,
        ),
        const SizedBox(height: 18),
        SimilarBooksSection(
          title: tr.libraryDetailSimilarTitles,
          emptyLabel: tr.libraryDetailNoRecommendations,
          items: _similarBooks,
          toBook: _toBook,
          onTap: _openSimilarBook,
        ),
      ],
    );
  }
}