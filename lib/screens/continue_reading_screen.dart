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

  Future<void> _loadProgress() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final books = await _service.getContinueReadingBooks();

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
        onRefresh: _loadProgress,
        child: _buildBody(cs, t),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs, AppLocalizations t) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ContinueReadingErrorView(
        message: _error!,
        onRetry: _loadProgress,
      );
    }

    if (_books.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.auto_stories_outlined,
            size: 64,
            color: cs.primary,
          ),
          const SizedBox(height: 14),
          Text(
            'No reading progress',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Books you start reading will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ],
      );
    }

    return ListView.separated(
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