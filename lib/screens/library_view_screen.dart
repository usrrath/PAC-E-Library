import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../models/pdf_note_model.dart';
import '../services/pdf_reader_service.dart';
import 'library_screen.dart';

class LibraryViewScreen extends StatefulWidget {
  final Book book;

  const LibraryViewScreen({
    super.key,
    required this.book,
  });

  @override
  State<LibraryViewScreen> createState() => _LibraryViewScreenState();
}

class _LibraryViewScreenState extends State<LibraryViewScreen> {
  final PdfViewerController _pdfController = PdfViewerController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _jumpController = TextEditingController();

  late final PdfReaderService _service;

  PdfTextSearchResult _searchResult = PdfTextSearchResult();
  Timer? _progressTimer;
  File? _pdfFile;

  bool _loading = true;
  bool _downloading = false;
  bool _showSearch = false;
  bool _darkReader = false;
  bool _noteDialogOpen = false;
  bool _documentLoaded = false;

  double _downloadProgress = 0.0;
  double _zoom = 1.0;

  int _page = 1;
  int _totalPages = 0;

  String _selectedText = '';

  final List<int> _bookmarks = [];
  final List<PdfNote> _notes = [];

  Book get book => widget.book;

  @override
  void initState() {
    super.initState();
    _service = PdfReaderService(bookId: book.id.toString());
    unawaited(_initReader(forceDownload: false));
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _searchController.dispose();
    _jumpController.dispose();
    _searchResult.clear();
    super.dispose();
  }

  void _debug(String message) {
    if (kDebugMode) debugPrint('PDF_READER_DEBUG: $message');
  }

  Future<void> _initReader({required bool forceDownload}) async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _downloading = false;
      _downloadProgress = 0;
      _documentLoaded = false;
      _pdfFile = null;
    });

    try {
      await _service.initToken();
      await _service.loadPdfUrl();
      await _loadLocalData();

      final cacheFile = await _service.getCacheFile();

      if (!forceDownload && await _service.isValidPdf(cacheFile)) {
        _pdfFile = cacheFile;
      } else {
        setState(() => _downloading = true);

        _pdfFile = await _service.downloadPdf(
          onProgress: (value) {
            if (!mounted) return;
            setState(() => _downloadProgress = value);
          },
        );
      }

      _page = await _service.loadProgress();
      final notes = await _service.loadNotes();

      _notes
        ..clear()
        ..addAll(notes);

      await _saveLocalData();
    } catch (e) {
      _debug('INIT ERROR: $e');
      _showSnack('Failed to open PDF.');
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _downloading = false;
      });
    }
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    _page = prefs.getInt(_service.localPageKey()) ?? 1;
    _darkReader = prefs.getBool('reader_dark_mode') ?? false;

    _bookmarks
      ..clear()
      ..addAll(
        (prefs.getStringList(_service.bookmarkKey()) ?? [])
            .map((e) => int.tryParse(e) ?? 0)
            .where((e) => e > 0)
            .toSet()
            .toList()
          ..sort(),
      );

    final notesJson = prefs.getString(_service.notesKey());
    if (notesJson == null || notesJson.isEmpty) return;

    try {
      final decoded = jsonDecode(notesJson);
      if (decoded is List) {
        _notes
          ..clear()
          ..addAll(
            decoded.whereType<Map>().map(
                  (e) => PdfNote.fromJson(Map<String, dynamic>.from(e)),
            ),
          );
      }
    } catch (e) {
      _debug('LOCAL NOTES ERROR: $e');
    }
  }

  Future<void> _saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_service.localPageKey(), _page);
    await prefs.setBool('reader_dark_mode', _darkReader);
    await prefs.setStringList(
      _service.bookmarkKey(),
      _bookmarks.map((e) => e.toString()).toList(),
    );
    await prefs.setString(
      _service.notesKey(),
      jsonEncode(_notes.map((e) => e.toJson()).toList()),
    );
  }

  void _scheduleSaveProgress() {
    _progressTimer?.cancel();
    _progressTimer = Timer(const Duration(milliseconds: 700), () {
      unawaited(_saveProgress());
    });
  }

  Future<void> _saveProgress() async {
    await _saveLocalData();

    try {
      await _service.saveProgress(
        page: _page,
        totalPages: _totalPages,
      );
    } catch (e) {
      _debug('SAVE PROGRESS ERROR: $e');
    }
  }

  Future<void> _saveNote(String comment) async {
    final selected = _selectedText.trim();
    final text = comment.trim();

    if (selected.isEmpty || text.isEmpty) return;

    final note = PdfNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      page: _page,
      selectedText: selected,
      comment: text,
      color: '#FFF59D',
    );

    setState(() => _notes.insert(0, note));
    await _saveLocalData();

    try {
      await _service.saveNote(note);
    } catch (e) {
      _debug('SAVE NOTE ERROR: $e');
    }
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    _totalPages = details.document.pages.count;
    _documentLoaded = true;

    final target = _page.clamp(1, _totalPages);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pdfController.jumpToPage(target);
    });

    if (mounted) setState(() {});
  }

  void _onPageChanged(PdfPageChangedDetails details) {
    if (!_documentLoaded) return;

    setState(() => _page = details.newPageNumber);
    _scheduleSaveProgress();
  }

  void _searchPdf(String value) {
    final query = value.trim();
    if (query.isEmpty) return;

    _searchResult.clear();
    _searchResult = _pdfController.searchText(query);
    _searchResult.addListener(() {
      if (mounted) setState(() {});
    });

    setState(() {});
  }

  void _toggleBookmark() {
    setState(() {
      if (_bookmarks.contains(_page)) {
        _bookmarks.remove(_page);
      } else {
        _bookmarks.add(_page);
        _bookmarks.sort();
      }
    });

    unawaited(_saveLocalData());
  }

  void _zoomIn() {
    setState(() {
      _zoom = (_zoom + 0.25).clamp(1.0, 4.0).toDouble();
      _pdfController.zoomLevel = _zoom;
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom = (_zoom - 0.25).clamp(1.0, 4.0).toDouble();
      _pdfController.zoomLevel = _zoom;
    });
  }

  void _openJumpDialog() {
    if (_totalPages <= 0) return;

    _jumpController.text = _page.toString();

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Jump to page'),
        content: TextField(
          controller: _jumpController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '1 - $_totalPages',
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => _jumpToPage(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: _jumpToPage,
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  void _jumpToPage() {
    final page = int.tryParse(_jumpController.text.trim());

    if (page == null || page < 1 || page > _totalPages) {
      _showSnack('Invalid page number');
      return;
    }

    Navigator.pop(context);
    _pdfController.jumpToPage(page);
  }

  void _openBookmarks() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Bookmarks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (_bookmarks.isEmpty)
            const Text('No bookmarks yet.')
          else
            ..._bookmarks.map(
                  (page) => ListTile(
                leading: const Icon(Icons.bookmark),
                title: Text('Page $page'),
                onTap: () {
                  Navigator.pop(context);
                  _pdfController.jumpToPage(page);
                },
              ),
            ),
        ],
      ),
    );
  }

  void _openNotes() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Notes / Highlights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (_notes.isEmpty)
            const Text('No notes yet. Select text in PDF to add note.')
          else
            ..._notes.map(
                  (note) => Card(
                child: ListTile(
                  leading: const Icon(Icons.note_alt_outlined),
                  title: Text(
                    note.selectedText,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text('Page ${note.page}\n${note.comment}'),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.pop(context);
                    _pdfController.jumpToPage(note.page);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _openNoteDialog() async {
    if (_noteDialogOpen || _selectedText.trim().isEmpty) return;

    _noteDialogOpen = true;
    final controller = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _selectedText,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Write note...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _pdfController.clearSelection();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _saveNote(controller.text);
              _pdfController.clearSelection();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    controller.dispose();
    _noteDialogOpen = false;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  ColorFilter get _readerFilter {
    if (!_darkReader) {
      return const ColorFilter.mode(Colors.transparent, BlendMode.multiply);
    }

    return const ColorFilter.matrix([
      -1, 0, 0, 0, 255,
      0, -1, 0, 0, 255,
      0, 0, -1, 0, 255,
      0, 0, 0, 1, 0,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalPages <= 0
        ? 0.0
        : (_page / _totalPages).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _showSearch ? _buildSearchField() : _buildTitle(),
        actions: [
          if (!_showSearch)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => setState(() => _showSearch = true),
            ),
          IconButton(
            icon: Icon(
              _bookmarks.contains(_page)
                  ? Icons.bookmark
                  : Icons.bookmark_border,
            ),
            onPressed: _toggleBookmark,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  unawaited(_initReader(forceDownload: true));
                  break;
                case 'clear_cache':
                  unawaited(() async {
                    await _service.deleteCachedPdf();
                    await _initReader(forceDownload: true);
                  }());
                  break;
                case 'bookmarks':
                  _openBookmarks();
                  break;
                case 'notes':
                  _openNotes();
                  break;
                case 'theme':
                  setState(() => _darkReader = !_darkReader);
                  unawaited(_saveLocalData());
                  break;
              }
            },
            itemBuilder: (_) => [
              // const PopupMenuItem(
              //   value: 'refresh',
              //   child: Text('Refresh PDF from server'),
              // ),
              // const PopupMenuItem(
              //   value: 'clear_cache',
              //   child: Text('Clear cache and reload'),
              // ),
              const PopupMenuItem(
                value: 'bookmarks',
                child: Text('Bookmarks'),
              ),
              const PopupMenuItem(
                value: 'notes',
                child: Text('Notes / highlights'),
              ),
              PopupMenuItem(
                value: 'theme',
                child: Text(_darkReader ? 'Light reader' : 'Dark reader'),
              ),
            ],
          ),
        ],
      ),
      body: _loading ? _buildOpeningView() : _buildReader(progress),
      bottomNavigationBar: _loading ? null : _buildBottomControls(progress),
    );
  }

  Widget _buildTitle() {
    return Text(
      book.title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontWeight: FontWeight.w900),
    );
  }

  Widget _buildOpeningView() {
    if (!_downloading) {
      return const Center(child: CircularProgressIndicator());
    }

    final percent = (_downloadProgress * 100).clamp(0, 100).toStringAsFixed(0);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 86,
                  height: 86,
                  child: CircularProgressIndicator(
                    value: _downloadProgress <= 0 ? null : _downloadProgress,
                    strokeWidth: 7,
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Downloading PDF...',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _downloadProgress <= 0 ? null : _downloadProgress,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search in PDF...',
        border: InputBorder.none,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_searchResult.hasResult)
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up),
                onPressed: _searchResult.previousInstance,
              ),
            if (_searchResult.hasResult)
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed: _searchResult.nextInstance,
              ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchResult.clear();
                _searchController.clear();
                setState(() => _showSearch = false);
              },
            ),
          ],
        ),
      ),
      onSubmitted: _searchPdf,
    );
  }

  Widget _buildReader(double progress) {
    final file = _pdfFile;

    if (file == null) {
      return const Center(child: Text('PDF file not found.'));
    }

    return Column(
      children: [
        LinearProgressIndicator(value: progress),
        Expanded(
          child: Container(
            color: _darkReader ? const Color(0xFF111827) : Colors.white,
            child: ColorFiltered(
              colorFilter: _readerFilter,
              child: SfPdfViewer.file(
                file,
                controller: _pdfController,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                enableTextSelection: true,
                onDocumentLoaded: _onDocumentLoaded,
                onPageChanged: _onPageChanged,
                onDocumentLoadFailed: (details) {
                  _debug('PDF LOAD FAILED: ${details.error}');
                  _debug('PDF DESCRIPTION: ${details.description}');
                  _showSnack('PDF load failed.');
                },
                onTextSelectionChanged: (details) {
                  final text = details.selectedText?.trim() ?? '';
                  if (text.isEmpty) return;

                  _selectedText = text;
                  unawaited(_openNoteDialog());
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(double progress) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.25),
            ),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _page > 1 ? _pdfController.previousPage : null,
            ),
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _openJumpDialog,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Page $_page / $_totalPages • ${(progress * 100).toStringAsFixed(1)}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _page < _totalPages ? _pdfController.nextPage : null,
            ),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: _zoomOut,
            ),
            Text(
              '${(_zoom * 100).toStringAsFixed(0)}%',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _zoomIn,
            ),
          ],
        ),
      ),
    );
  }
}