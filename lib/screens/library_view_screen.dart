import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../l10n/app_localizations.dart';
import '../models/library_models.dart';
import '../models/pdf_note_model.dart';
import '../services/pdf_reader_service.dart';
import '../utils/pdf_reader_utils.dart';
import '../widgets/pdf_reader_widgets.dart';


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
  final GlobalKey _pdfContainerKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _jumpController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  late final PdfReaderService _service;

  static const double _pageGap = 4.0;

  final Map<int, Size> _pdfPageSizes = <int, Size>{};
  final List<int> _bookmarks = <int>[];
  final List<PdfNote> _notes = <PdfNote>[];

  PdfTextSearchResult? _searchResult;
  Timer? _progressTimer;
  Timer? _topMessageTimer;
  File? _pdfFile;

  bool _loading = true;
  bool _downloading = false;
  bool _showSearch = false;
  bool _darkReader = false;
  bool _documentLoaded = false;
  bool _showPageNotes = true;
  bool _showSelectionPanel = false;
  bool _noteMode = false;
  bool _enableTextSelection = true;

  String _topMessage = '';

  double _downloadProgress = 0.0;
  double _zoom = 1.0;

  int _page = 1;
  int _totalPages = 0;
  int _selectedPage = 1;

  String _selectedText = '';
  List<PdfRect> _selectedRects = <PdfRect>[];

  FlutterExceptionHandler? _oldFlutterErrorHandler;

  Book get book => widget.book;
  AppLocalizations get tr => AppLocalizations.of(context)!;

  int get _itemId => int.tryParse(book.id.toString()) ?? 0;

  List<PdfNote> get _currentPageNotes {
    return _notes.where((e) => e.page == _page && e.rects.isNotEmpty).toList();
  }

  @override
  void initState() {
    super.initState();

    _service = PdfReaderService(bookId: book.id.toString());
    _pdfController.addListener(_onPdfMoved);

    _oldFlutterErrorHandler = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      final errorText = details.exceptionAsString();
      final stackText = details.stack?.toString() ?? '';

      final isSyncfusionTextSelectionError =
          errorText.contains('RangeError') &&
              stackText.contains('PdfTextExtractor');

      if (isSyncfusionTextSelectionError) {
        if (mounted && _enableTextSelection) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            setState(() {
              _enableTextSelection = false;
              _showSelectionPanel = false;
              _noteMode = false;
            });

            _showSnack(tr.libraryViewTextLayerError);
          });
        }
        return;
      }

      _oldFlutterErrorHandler?.call(details);
    };

    unawaited(_initReader(forceDownload: false));
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _topMessageTimer?.cancel();

    _searchResult?.removeListener(_onSearchResultChanged);
    _searchResult?.clear();

    _searchController.dispose();
    _jumpController.dispose();
    _noteController.dispose();

    _pdfController.removeListener(_onPdfMoved);
    FlutterError.onError = _oldFlutterErrorHandler;

    super.dispose();
  }

  void _debug(String message) {
    if (kDebugMode) debugPrint('PDF_READER_DEBUG: $message');
  }

  void _onPdfMoved() {
    if (!mounted) return;

    final nextZoom = _safeZoom;
    if ((_zoom - nextZoom).abs() > 0.001) {
      _zoom = nextZoom;
    }
  }

  double get _safeZoom {
    final zoom = _pdfController.zoomLevel;
    if (zoom.isNaN || zoom <= 0) return 1.0;
    return zoom.clamp(1.0, 4.0).toDouble();
  }

  Future<void> _initReader({required bool forceDownload}) async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _downloading = false;
      _downloadProgress = 0;
      _documentLoaded = false;
      _pdfFile = null;
      _showSelectionPanel = false;
      _noteMode = false;
    });

    try {
      await _service.initToken();
      await _service.loadPdfUrl();
      await _loadLocalData();

      final cachedFile = forceDownload ? null : await _service.getCachedPdf();

      if (cachedFile != null) {
        _pdfFile = cachedFile;
      } else {
        if (mounted) setState(() => _downloading = true);

        _pdfFile = await _service.downloadPdf(
          onProgress: (value) {
            if (!mounted) return;
            setState(() => _downloadProgress = value.clamp(0.0, 1.0));
          },
        );
      }

      final progressPage = await _service.loadProgress();
      _page = math.max(1, progressPage);

      await _loadRemoteNotesSafely();
      await _saveLocalData();
    } catch (e, s) {
      _debug('INIT ERROR: $e');
      _debug('INIT STACK: $s');
      _showSnack(tr.libraryViewFailedOpenPdf);
    } finally {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _downloading = false;
      });
    }
  }

  Future<void> _loadRemoteNotesSafely() async {
    try {
      final remoteNotes = await _service.loadNotes();
      final unique = <String, PdfNote>{};

      for (final note in remoteNotes) {
        if (!note.isEmpty && note.rects.isNotEmpty) {
          unique[note.id] = note;
        }
      }

      _notes
        ..clear()
        ..addAll(unique.values);

      _debug('REMOTE NOTES LOADED: ${_notes.length}');

      if (mounted) setState(() {});
    } catch (e) {
      _debug('LOAD REMOTE NOTES ERROR: $e');
    }
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();

    _page = prefs.getInt(_service.localPageKey()) ?? 1;
    _darkReader = prefs.getBool('reader_dark_mode') ?? false;

    final bookmarkValues =
        prefs.getStringList(_service.bookmarkKey()) ?? <String>[];

    _bookmarks
      ..clear()
      ..addAll(
        bookmarkValues
            .map((e) => int.tryParse(e) ?? 0)
            .where((e) => e > 0)
            .toSet()
            .toList()
          ..sort(),
      );

    final notesJson = prefs.getString(_service.notesKey());
    if (notesJson == null || notesJson.trim().isEmpty) return;

    try {
      final decoded = jsonDecode(notesJson);

      if (decoded is List) {
        final localNotes = decoded
            .whereType<Map>()
            .map((e) => PdfNote.fromJson(Map<String, dynamic>.from(e)))
            .where((e) => !e.isEmpty && e.rects.isNotEmpty)
            .toList();

        _notes
          ..clear()
          ..addAll(localNotes);
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
    _progressTimer = Timer(
      const Duration(milliseconds: 700),
          () => unawaited(_saveProgress()),
    );
  }

  Future<void> _saveProgress() async {
    await _saveLocalData();

    try {
      await _service.saveProgress(page: _page, totalPages: _totalPages);
    } catch (e) {
      _debug('SAVE PROGRESS ERROR: $e');
    }
  }

  Future<void> _saveMarkup(
      String type,
      String color, {
        String comment = '',
      }) async {
    final selected = _selectedText.trim();
    final rects = _selectedRects.where((e) => e.isValid).toList();

    if (_itemId <= 0 || selected.isEmpty || rects.isEmpty) {
      _showSnack(tr.libraryViewSelectTextFirst);
      return;
    }

    final note = PdfNote(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      itemId: _itemId,
      page: _selectedPage,
      selectedText: selected,
      comment: comment.trim(),
      color: color,
      type: type,
      rects: rects,
    );

    await _saveNoteRecord(note);
    _clearSelection();

    if (mounted) {
      setState(() {
        _showSelectionPanel = false;
        _noteMode = false;
      });
    }

    switch (type) {
      case 'comment':
        _showSnack(tr.libraryViewNoteSaved);
        break;
      case 'underline':
        _showSnack(tr.libraryViewUnderlineSaved);
        break;
      case 'strikethrough':
        _showSnack(tr.libraryViewStrikethroughSaved);
        break;
      case 'squiggly':
        _showSnack(tr.libraryViewSquigglySaved);
        break;
      default:
        _showSnack(tr.libraryViewHighlightSaved);
    }
  }

  Future<void> _saveNoteRecord(PdfNote note) async {
    _notes.removeWhere((e) => e.id == note.id);
    _notes.insert(0, note);

    if (mounted) setState(() {});
    await _saveLocalData();

    try {
      final synced = await _service.saveNote(note);

      if (!synced) {
        _showSnack(tr.libraryViewSavedLocalSyncFailed);
        return;
      }

      await _loadRemoteNotesSafely();
      await _saveLocalData();

      if (mounted) setState(() {});
    } catch (e) {
      _debug('SAVE NOTE ERROR: $e');
      _showSnack(tr.libraryViewSavedLocalSyncFailed);
    }
  }

  Future<void> _deleteNote(PdfNote note) async {
    final index = _notes.indexWhere((e) => e.id == note.id);
    if (index < 0) return;

    final removed = _notes.removeAt(index);

    if (mounted) setState(() {});
    await _saveLocalData();

    final deleted = await _service.deleteNote(note.id);

    if (!deleted) {
      _notes.insert(index, removed);

      if (mounted) setState(() {});
      await _saveLocalData();

      _showSnack(tr.libraryViewFailedDelete);
    }
  }

  void _onDocumentLoaded(PdfDocumentLoadedDetails details) {
    _totalPages = details.document.pages.count;
    _documentLoaded = true;
    _pdfPageSizes.clear();

    for (var i = 0; i < _totalPages; i++) {
      final size = details.document.pages[i].size;
      _pdfPageSizes[i + 1] = Size(size.width, size.height);
    }

    final target = _totalPages <= 0 ? 1 : _page.clamp(1, _totalPages);

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

  void _onTextSelectionChanged(PdfTextSelectionChangedDetails details) {
    final text = details.selectedText?.trim() ?? '';

    if (text.isEmpty) {
      _selectedText = '';
      _selectedPage = _page;
      _selectedRects = <PdfRect>[];

      if (mounted) {
        setState(() {
          _showSelectionPanel = false;
          _noteMode = false;
        });
      }

      return;
    }

    final selection = _rectsFromSelection(details);

    _selectedText = text;
    _selectedPage = selection.page;
    _selectedRects = selection.rects;

    if (!mounted || _selectedRects.isEmpty) return;

    setState(() {
      _showSelectionPanel = true;
      _noteMode = false;
    });
  }

  SelectionRects _rectsFromSelection(PdfTextSelectionChangedDetails details) {
    final region = details.globalSelectedRegion;

    if (region == null || region.width <= 0 || region.height <= 0) {
      return SelectionRects(page: _page, rects: const <PdfRect>[]);
    }

    final box = _pdfContainerKey.currentContext?.findRenderObject() as RenderBox?;

    if (box == null || !box.hasSize) {
      return SelectionRects(page: _page, rects: const <PdfRect>[]);
    }

    final localTopLeft = box.globalToLocal(region.topLeft);

    final localRect = Rect.fromLTWH(
      localTopLeft.dx,
      localTopLeft.dy,
      region.width,
      region.height,
    );

    final selectedPage = _pageForLocalRect(
      localRect: localRect,
      viewerWidth: box.size.width,
    );

    final pageBox = _pageBoxForPage(
      page: selectedPage,
      viewerWidth: box.size.width,
    );

    final x = ((localRect.left - pageBox.left) / pageBox.width)
        .clamp(0.0, 1.0)
        .toDouble();

    final y = ((localRect.top - pageBox.top) / pageBox.height)
        .clamp(0.0, 1.0)
        .toDouble();

    final w = (localRect.width / pageBox.width)
        .clamp(0.0, 1.0 - x)
        .toDouble();

    final h = (localRect.height / pageBox.height)
        .clamp(0.0, 1.0 - y)
        .toDouble();

    final rect = PdfRect(x: x, y: y, w: w, h: h);

    if (!rect.isValid) {
      return SelectionRects(page: selectedPage, rects: const <PdfRect>[]);
    }

    return SelectionRects(page: selectedPage, rects: <PdfRect>[rect]);
  }

  int _pageForLocalRect({
    required Rect localRect,
    required double viewerWidth,
  }) {
    if (_totalPages <= 0) return _page;

    var bestPage = _page.clamp(1, _totalPages);
    var bestOverlap = 0.0;

    for (var page = 1; page <= _totalPages; page++) {
      final pageBox = _pageBoxForPage(page: page, viewerWidth: viewerWidth);
      final overlap = pageBox.intersect(localRect);
      final area = overlap.isEmpty ? 0.0 : overlap.width * overlap.height;

      if (area > bestOverlap) {
        bestOverlap = area;
        bestPage = page;
      }
    }

    return bestPage;
  }

  void _clearSelection() {
    _selectedText = '';
    _selectedPage = _page;
    _selectedRects = <PdfRect>[];
    _noteController.clear();
    _pdfController.clearSelection();
  }

  void _searchPdf(String value) {
    final query = value.trim();
    if (query.isEmpty) return;

    _searchResult?.removeListener(_onSearchResultChanged);
    _searchResult?.clear();

    final result = _pdfController.searchText(query);
    _searchResult = result;
    result.addListener(_onSearchResultChanged);

    setState(() {});
  }

  void _onSearchResultChanged() {
    if (mounted) setState(() {});
  }

  void _closeSearch() {
    _searchResult?.removeListener(_onSearchResultChanged);
    _searchResult?.clear();
    _searchResult = null;
    _searchController.clear();

    setState(() => _showSearch = false);
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
    final current = _pdfController.zoomLevel <= 0 ? 1.0 : _pdfController.zoomLevel;

    _zoom = (current + 0.25).clamp(1.0, 4.0).toDouble();
    _pdfController.zoomLevel = _zoom;

    setState(() {});
  }

  void _zoomOut() {
    final current = _pdfController.zoomLevel <= 0 ? 1.0 : _pdfController.zoomLevel;

    _zoom = (current - 0.25).clamp(1.0, 4.0).toDouble();
    _pdfController.zoomLevel = _zoom;

    setState(() {});
  }

  void _openJumpDialog() {
    if (_totalPages <= 0) return;

    _jumpController.text = _page.toString();

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(tr.libraryViewJumpToPage),
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
            child: Text(tr.libraryViewCancel),
          ),
          FilledButton(
            onPressed: _jumpToPage,
            child: Text(tr.libraryViewGo),
          ),
        ],
      ),
    );
  }

  void _jumpToPage() {
    final page = int.tryParse(_jumpController.text.trim());

    if (page == null || page < 1 || page > _totalPages) {
      _showSnack(tr.libraryViewInvalidPageNumber);
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
          Text(
            tr.libraryViewBookmarks,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (_bookmarks.isEmpty)
            Text(tr.libraryViewNoBookmarks)
          else
            ..._bookmarks.map(
                  (page) => ListTile(
                leading: const Icon(Icons.bookmark),
                title: Text('${tr.libraryViewPage} $page'),
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
      builder: (_) => StatefulBuilder(
        builder: (context, modalSetState) {
          Future<void> reloadNotes() async {
            await _loadRemoteNotesSafely();
            await _saveLocalData();

            if (mounted) setState(() {});
            modalSetState(() {});
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tr.libraryViewNotesHighlights,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: tr.libraryViewReload,
                    onPressed: reloadNotes,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_notes.isEmpty)
                Text(tr.libraryViewNoNotes)
              else
                ..._notes.map(
                      (note) => _buildNoteCard(
                    note,
                    onDelete: () async {
                      await _deleteNote(note);
                      modalSetState(() {});
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted || message.trim().isEmpty) return;

    _topMessageTimer?.cancel();

    setState(() => _topMessage = message);

    _topMessageTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _topMessage = '');
    });
  }

  Widget _buildTopMessage() {
    if (_topMessage.trim().isEmpty) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;

    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: SafeArea(
        bottom: false,
        child: Material(
          elevation: 10,
          borderRadius: BorderRadius.circular(14),
          color: cs.inverseSurface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: cs.onInverseSurface,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _topMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: cs.onInverseSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ColorFilter get _readerFilter {
    if (!_darkReader) {
      return const ColorFilter.mode(Colors.transparent, BlendMode.multiply);
    }

    return const ColorFilter.matrix(<double>[
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
            tooltip: tr.libraryViewPageNotes,
            icon: Icon(
              _showPageNotes
                  ? Icons.sticky_note_2
                  : Icons.sticky_note_2_outlined,
            ),
            onPressed: () => setState(() => _showPageNotes = !_showPageNotes),
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
            onSelected: _onMenuSelected,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'bookmarks',
                child: Text(tr.libraryViewBookmarks),
              ),
              PopupMenuItem(
                value: 'notes',
                child: Text(tr.libraryViewAllNotesHighlights),
              ),
              PopupMenuItem(
                value: 'theme',
                child: Text(
                  _darkReader
                      ? tr.libraryViewLightReader
                      : tr.libraryViewDarkReader,
                ),
              ),
              PopupMenuItem(
                value: 'clear_cache',
                child: Text(tr.libraryViewClearCacheReload),
              ),
            ],
          ),
        ],
      ),
      body: _loading ? _buildOpeningView() : _buildReader(progress),
      bottomNavigationBar: _loading ? null : _buildBottomControls(progress),
    );
  }

  void _onMenuSelected(String value) {
    switch (value) {
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
            Text(
              tr.libraryViewDownloadingPdf,
              style: const TextStyle(fontWeight: FontWeight.w900),
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
        hintText: tr.libraryViewSearchPdf,
        border: InputBorder.none,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_searchResult?.hasResult ?? false)
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_up),
                onPressed: _searchResult?.previousInstance,
              ),
            if (_searchResult?.hasResult ?? false)
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down),
                onPressed: _searchResult?.nextInstance,
              ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _closeSearch,
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
      return Center(child: Text(tr.libraryViewPdfFileNotFound));
    }

    return Column(
      children: [
        LinearProgressIndicator(value: progress),
        Expanded(
          child: Container(
            key: _pdfContainerKey,
            color: _darkReader ? const Color(0xFF111827) : Colors.white,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    ColorFiltered(
                      colorFilter: _readerFilter,
                      child: SfPdfViewer.file(
                        file,
                        controller: _pdfController,
                        canShowScrollHead: true,
                        canShowScrollStatus: true,
                        pageSpacing: _pageGap,
                        enableTextSelection: _enableTextSelection,
                        canShowTextSelectionMenu: false,
                        onTextSelectionChanged: _onTextSelectionChanged,
                        onDocumentLoaded: _onDocumentLoaded,
                        onPageChanged: _onPageChanged,
                        onZoomLevelChanged: (details) {
                          _zoom = details.newZoomLevel <= 0
                              ? 1.0
                              : details.newZoomLevel;

                          if (mounted) setState(() {});
                        },
                        onDocumentLoadFailed: (details) {
                          _debug('PDF LOAD FAILED: ${details.error}');
                          _debug('PDF DESCRIPTION: ${details.description}');
                          _showSnack(tr.libraryViewPdfLoadFailed);
                        },
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: RepaintBoundary(
                          child: AnimatedBuilder(
                            animation: _pdfController,
                            builder: (_, __) => _buildRectsOverlay(
                              viewerWidth: constraints.maxWidth,
                              viewerHeight: constraints.maxHeight,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildPageNotesPanel(),
                    ),
                    _buildSelectionPanel(),
                    _buildTopMessage(),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRectsOverlay({
    required double viewerWidth,
    required double viewerHeight,
  }) {
    if (_notes.isEmpty || !_documentLoaded) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      size: Size(viewerWidth, viewerHeight),
      painter: PdfMarkupPainter(
        notes: _notes,
        pageBoxes: <int, Rect>{
          for (var page = 1; page <= _totalPages; page++)
            page: _pageBoxForPage(page: page, viewerWidth: viewerWidth),
        },
        viewport: Rect.fromLTWH(0, 0, viewerWidth, viewerHeight),
        parseColor: _parseHexColor,
      ),
    );
  }

  Rect _pageBoxForPage({
    required int page,
    required double viewerWidth,
  }) {
    final scroll = _pdfController.scrollOffset;
    final zoom = _safeZoom;

    final pageSize = _pdfPageSizes[page] ?? const Size(595, 842);
    final pageWidth = viewerWidth * zoom;
    final pageHeight = pageWidth * (pageSize.height / pageSize.width);
    final left = ((viewerWidth - pageWidth) / 2) - scroll.dx;

    double top = -scroll.dy;

    for (var i = 1; i < page; i++) {
      final size = _pdfPageSizes[i] ?? const Size(595, 842);
      top += pageWidth * (size.height / size.width) + _pageGap;
    }

    return Rect.fromLTWH(left, top, pageWidth, pageHeight);
  }

  Widget _buildSelectionPanel() {
    if (!_showSelectionPanel || _selectedText.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        elevation: 14,
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 14,
              bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: _noteMode ? _buildNoteInputPanel() : _buildMarkupPanel(),
          ),
        ),
      ),
    );
  }

  Widget _buildMarkupPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _selectedText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _panelButton(Icons.border_color, tr.libraryViewHighlight, () {
              unawaited(_saveMarkup('highlight', '#FFF59D'));
            }),
            _panelButton(Icons.format_underlined, tr.libraryViewUnderline, () {
              unawaited(_saveMarkup('underline', '#4CAF50'));
            }),
            _panelButton(Icons.format_strikethrough, tr.libraryViewStrike, () {
              unawaited(_saveMarkup('strikethrough', '#EF4444'));
            }),
            _panelButton(Icons.gesture, tr.libraryViewSquiggly, () {
              unawaited(_saveMarkup('squiggly', '#8B5CF6'));
            }),
            _panelButton(Icons.note_add, tr.libraryViewNote, () {
              setState(() => _noteMode = true);
            }),
            _panelButton(Icons.close, tr.libraryViewCancel, () {
              _clearSelection();
              setState(() {
                _showSelectionPanel = false;
                _noteMode = false;
              });
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildNoteInputPanel() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _selectedText,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _noteController,
          maxLines: 3,
          autofocus: true,
          decoration: InputDecoration(
            hintText: tr.libraryViewWriteNote,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () {
                  _clearSelection();
                  setState(() {
                    _showSelectionPanel = false;
                    _noteMode = false;
                  });
                },
                child: Text(tr.libraryViewCancel),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  final text = _noteController.text.trim();
                  if (text.isEmpty) return;

                  unawaited(
                    _saveMarkup(
                      'comment',
                      '#9EE7FF',
                      comment: text,
                    ),
                  );
                },
                child: Text(tr.libraryViewSave),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _panelButton(
      IconData icon,
      String label,
      VoidCallback onPressed,
      ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }

  Widget _buildPageNotesPanel() {
    final notes = _currentPageNotes;

    if (!_showPageNotes || notes.isEmpty || _showSelectionPanel) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 155,
          child: Column(
            children: [
              SizedBox(
                height: 46,
                child: ListTile(
                  dense: true,
                  title: Text(
                    '${tr.libraryViewPage} $_page ${tr.libraryViewNotesHighlightsLower}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _showPageNotes = false),
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (_, index) => _buildMiniNoteCard(notes[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniNoteCard(PdfNote note) {
    final hasComment = note.comment.trim().isNotEmpty;

    return Card(
      child: ListTile(
        dense: true,
        leading: Icon(_iconForNote(note)),
        title: Text(
          note.selectedText.trim().isEmpty ? note.type : note.selectedText,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: hasComment
            ? Text(
          note.comment,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        )
            : Text(note.type),
        trailing: IconButton(
          tooltip: tr.libraryViewDelete,
          icon: const Icon(Icons.delete_outline),
          onPressed: () => unawaited(_deleteNote(note)),
        ),
      ),
    );
  }

  Widget _buildNoteCard(
      PdfNote note, {
        required Future<void> Function() onDelete,
      }) {
    final hasComment = note.comment.trim().isNotEmpty;
    final title = note.selectedText.trim().isEmpty
        ? note.type
        : note.selectedText.trim();

    final subtitle = hasComment
        ? '${tr.libraryViewPage} ${note.page}\n${note.comment.trim()}'
        : '${tr.libraryViewPage} ${note.page}\n${note.type}';

    return Card(
      child: ListTile(
        leading: Icon(_iconForNote(note)),
        title: Text(
          title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          subtitle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        onTap: () {
          Navigator.pop(context);
          _pdfController.jumpToPage(note.page);
        },
        trailing: IconButton(
          tooltip: tr.libraryViewDelete,
          icon: const Icon(Icons.delete_outline),
          onPressed: () => unawaited(onDelete()),
        ),
      ),
    );
  }

  IconData _iconForNote(PdfNote note) {
    return PdfReaderUtils.iconForNote(note);
  }

  Color _parseHexColor(String value) {
    return PdfReaderUtils.parseHexColor(value);
  }

  Widget _buildBottomControls(double progress) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        decoration: BoxDecoration(
          color: cs.surface,
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
                    '${tr.libraryViewPage} $_page / $_totalPages • ${(progress * 100).toStringAsFixed(1)}%',
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