import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/continue_reading_book.dart';
import '../services/continue_reading_service.dart';
import '../widgets/continue_reading_widgets.dart';
import 'library_view_screen.dart';

class ContinueReadingScreen extends StatefulWidget {
  const ContinueReadingScreen({super.key});

  @override
  State<ContinueReadingScreen> createState() => _ContinueReadingScreenState();
}

class _ContinueReadingScreenState extends State<ContinueReadingScreen> {
  final ContinueReadingService _service = ContinueReadingService();

  bool _loading = true;
  String? _error;
  List<ContinueReadingBook> _books = [];

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress({bool refresh = false}) async {
    if (!mounted) return;

    setState(() {
      _loading = _books.isEmpty;
      _error = null;
    });

    try {
      final books = await _service.getContinueReadingBooks(refresh: refresh);

      if (!mounted) return;

      setState(() {
        _books = books;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _openReader(ContinueReadingBook book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LibraryViewScreen(
          book: book.toBook(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Text(
          t.continueReading,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadProgress(refresh: true),
        child: _buildBody(cs, t),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs, AppLocalizations t) {
    if (_loading) return const ContinueReadingLoadingList();

    if (_error != null) {
      return ContinueReadingErrorView(
        message: _error!,
        onRetry: () => _loadProgress(refresh: true),
      );
    }

    if (_books.isEmpty) {
      return ContinueReadingEmptyView(colorScheme: cs);
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final book = _books[i];

        return ContinueReadingCard(
          book: book,
          continueReadingActionText: t.continueReadingAction,
          onTap: () => _openReader(book),
        );
      },
    );
  }
}