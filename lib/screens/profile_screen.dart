import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import '../models/user_model.dart';
import '../services/api_users_favorites.dart';
import '../services/api_users_reading.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final ApiUserServiceFavorites _favoritesService = ApiUserServiceFavorites();
  final ApiUserServiceReading _readingService = ApiUserServiceReading();

  UserModel? user;
  bool loading = true;
  bool saving = false;

  final List<_BookMini> favoriteBooks = [];
  final List<_BookMini> readingBooks = [];

  AppLocalizations get t => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ??
        prefs.getString('token') ??
        prefs.getString('access_token');
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() => loading = true);

    try {
      final token = await _getToken();

      if (token == null || token.trim().isEmpty) {
        throw Exception(t.profilesTokenNotFound);
      }

      final responses = await Future.wait([
        _userService.getVerifyAccount(token),
        _favoritesService.getUserFavorites(token),
        _readingService.getUserReadingProgress(token),
      ]);

      final userMap = _JsonHelper.extractUser(responses[0]);

      final readingList = _JsonHelper.extractList(responses[2])
          .map(
            (e) => _BookMini.fromJson(
          _JsonHelper.toMap(e),
          baseUrl: _userService.base,
        ),
      )
          .where((book) => book.id.isNotEmpty)
          .toList()
        ..sort((a, b) => b.progress.compareTo(a.progress));

      final progressMap = <String, double>{
        for (final book in readingList) book.id: book.progress,
      };

      final favoriteList = _JsonHelper.extractList(responses[1])
          .map((e) {
        final book = _BookMini.fromJson(
          _JsonHelper.toMap(e),
          baseUrl: _userService.base,
        );

        return book.copyWith(
          progress: progressMap[book.id] ?? book.progress,
        );
      })
          .where((book) => book.id.isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        if (userMap.isNotEmpty) {
          user = UserModel.fromJson(userMap);
        }

        readingBooks
          ..clear()
          ..addAll(readingList);

        favoriteBooks
          ..clear()
          ..addAll(favoriteList);
      });
    } catch (e) {
      _toast(_cleanError(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<File?> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 454,
      maxHeight: 454,
    );

    if (picked == null) return null;
    return File(picked.path);
  }

  Future<void> _openEditProfile() async {
    if (loading || saving) return;

    final currentUser = user;

    final result = await showModalBottomSheet<_ProfileEditResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return _EditProfileSheet(
          name: currentUser?.name ?? '',
          email: currentUser?.email ?? '',
          userLevel: currentUser?.level ?? '',
          photoUrl: _fullUrl(currentUser?.photo ?? '', _userService.base),
          pickPhoto: _pickPhoto,
        );
      },
    );

    if (!mounted || result == null) return;

    await _saveProfile(
      inputName: result.name,
      inputPhoto: result.photo,
    );
  }

  Future<void> _saveProfile({
    required String inputName,
    required File? inputPhoto,
  }) async {
    final cleanName = inputName.trim();
    final oldName = user?.name.trim() ?? '';

    final hasNameChanged = cleanName.isNotEmpty && cleanName != oldName;
    final hasPhotoChanged = inputPhoto != null;

    if (!hasNameChanged && !hasPhotoChanged) {
      _toast(t.profilesNoChangesToUpdate);
      return;
    }

    setState(() => saving = true);

    try {
      final token = await _getToken();

      if (token == null || token.trim().isEmpty) {
        throw Exception(t.profilesTokenNotFound);
      }

      final response = await _userService.updateProfile(
        token: token,
        name: hasNameChanged ? cleanName : null,
        photo: hasPhotoChanged ? inputPhoto : null,
      );

      final userMap = _JsonHelper.extractUser(response);

      if (!mounted) return;

      setState(() {
        if (userMap.isNotEmpty) {
          user = UserModel.fromJson(userMap);
        } else if (hasNameChanged && user != null) {
          user = UserModel(
            id: user!.id,
            name: cleanName,
            email: user!.email,
            level: user!.level,
            photo: user!.photo,
          );
        }
      });

      _toast(t.profilesProfileUpdatedSuccessfully);
    } catch (e) {
      _toast(_cleanError(e));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _debugBook(_BookMini book) {
    debugPrint('========== CLICKED BOOK ==========');
    debugPrint('ID: ${book.id}');
    debugPrint('TITLE: ${book.title}');
    debugPrint('AUTHOR: ${book.author}');
    debugPrint('CATEGORY: ${book.category}');
    debugPrint('COVER URL: ${book.coverUrl}');
    debugPrint('PROGRESS: ${book.progress}');
    debugPrint('==================================');

    _toast(t.profilesClickedBook(book.title));
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _toast(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _ReadingStats.fromData(
      favorites: favoriteBooks,
      history: readingBooks,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          t.profilesProfile,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: t.profilesRefresh,
            onPressed: loading || saving ? null : _loadProfile,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: t.profilesEditProfile,
            onPressed: loading || saving ? null : _openEditProfile,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadProfile,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (loading)
                  const Padding(
                    padding: EdgeInsets.only(top: 60),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  _profileHeader(),
                const SizedBox(height: 20),
                _sectionTitle(t.profilesReadingStatistics),
                const SizedBox(height: 10),
                _statsRow(stats),
                const SizedBox(height: 20),
                _sectionTitle(t.profilesFavoriteBooks),
                const SizedBox(height: 10),
                _horizontalBooks(
                  items: favoriteBooks,
                  emptyText: t.profilesNoFavoriteBooks,
                  icon: Icons.favorite_rounded,
                  iconColor: Colors.red,
                ),
                const SizedBox(height: 20),
                _sectionTitle(t.profilesReadingProgress),
                const SizedBox(height: 10),
                _readingList(),
              ],
            ),
          ),
          if (saving)
            Container(
              color: Colors.black.withOpacity(0.08),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _profileHeader() {
    final cs = Theme.of(context).colorScheme;
    final currentUser = user;

    return _card(
      child: Row(
        children: [
          _ProfileAvatar(
            photoUrl: _fullUrl(currentUser?.photo ?? '', _userService.base),
            selectedPhoto: null,
            size: 76,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser?.name.isNotEmpty == true
                      ? currentUser!.name
                      : t.profilesNoName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?.email.isNotEmpty == true
                      ? currentUser!.email
                      : t.profilesNoEmail,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (currentUser?.id.isNotEmpty == true)
                      _badge(t.profilesUserId(currentUser!.id)),
                    if (currentUser?.level.isNotEmpty == true)
                      _badge(currentUser!.level),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(_ReadingStats stats) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: t.profilesInProgress,
            value: stats.inProgress.toString(),
            icon: Icons.auto_stories_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            title: t.favorites,
            value: stats.favorites.toString(),
            icon: Icons.favorite_rounded,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    final cs = Theme.of(context).colorScheme;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _horizontalBooks({
    required List<_BookMini> items,
    required String emptyText,
    required IconData icon,
    required Color iconColor,
  }) {
    final cs = Theme.of(context).colorScheme;

    if (items.isEmpty) return _emptyCard(emptyText);

    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final book = items[index];

          return InkWell(
            onTap: () => _debugBook(book),
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: 120,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cs.primary.withOpacity(0.12)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18),
                            ),
                            child: _CachedNetImage(
                              url: book.coverUrl,
                              width: 120,
                              height: 140,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(icon, color: iconColor),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: _bookInfo(
                        book,
                        showProgress: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _readingList() {
    final cs = Theme.of(context).colorScheme;

    if (readingBooks.isEmpty) {
      return _emptyCard(t.profilesNoReadingProgress);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: readingBooks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final book = readingBooks[index];

        return InkWell(
          onTap: () => _debugBook(book),
          borderRadius: BorderRadius.circular(18),
          child: _card(
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _CachedNetImage(
                    url: book.coverUrl,
                    width: 60,
                    height: 84,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _bookInfo(book)),
                Icon(Icons.chevron_right_rounded, color: cs.primary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bookInfo(
      _BookMini book, {
        bool showProgress = true,
      }) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          book.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          book.author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        if (showProgress) ...[
          const SizedBox(height: 8),
          _progressRow(book.progress),
        ],
      ],
    );
  }

  Widget _progressRow(double progress) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();
    final percent = safeProgress * 100;

    // final percentText = '${percent.toStringAsFixed(1)}%';
    final percentText = percent < 0
        ? '0%'
        : '${percent.toStringAsFixed(1)}%';

    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: safeProgress,
            minHeight: 7,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          percentText,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _badge(String text) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: cs.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _emptyCard(String text) {
    final cs = Theme.of(context).colorScheme;

    return _card(
      child: Text(
        text,
        style: TextStyle(color: cs.onSurfaceVariant),
      ),
    );
  }
}

class _ProfileEditResult {
  final String name;
  final File? photo;

  const _ProfileEditResult({
    required this.name,
    required this.photo,
  });
}

class _EditProfileSheet extends StatefulWidget {
  final String name;
  final String email;
  final String userLevel;
  final String photoUrl;
  final Future<File?> Function() pickPhoto;

  const _EditProfileSheet({
    required this.name,
    required this.email,
    required this.userLevel,
    required this.photoUrl,
    required this.pickPhoto,
  });

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController nameCtrl;
  File? selectedPhoto;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    final file = await widget.pickPhoto();

    if (!mounted || file == null) return;

    setState(() => selectedPhoto = file);
  }

  void _save() {
    final cleanName = nameCtrl.text.trim();

    if (cleanName.isEmpty) return;

    Navigator.of(context).pop(
      _ProfileEditResult(
        name: cleanName,
        photo: selectedPhoto,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              t.profilesEditProfile,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                _ProfileAvatar(
                  photoUrl: widget.photoUrl,
                  selectedPhoto: selectedPhoto,
                  size: 96,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: _choosePhoto,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).cardColor,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: t.profilesName,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: widget.email,
              enabled: false,
              decoration: InputDecoration(
                labelText: t.profilesEmail,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: widget.userLevel,
              enabled: false,
              decoration: InputDecoration(
                labelText: t.profilesUserLevel,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.verified_user_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(t.profilesCancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: Text(t.profilesSave),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String photoUrl;
  final File? selectedPhoto;
  final double size;

  const _ProfileAvatar({
    required this.photoUrl,
    required this.selectedPhoto,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedPhoto != null) {
      return ClipOval(
        child: Image.file(
          selectedPhoto!,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    if (photoUrl.trim().isEmpty) {
      return _AvatarFallback(size: size);
    }

    return ClipOval(
      child: _CachedNetImage(
        url: photoUrl,
        width: size,
        height: size,
        isAvatar: true,
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  final double size;
  final bool loading;

  const _AvatarFallback({
    required this.size,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.primary.withOpacity(0.10),
      ),
      child: loading
          ? SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: cs.primary,
        ),
      )
          : Icon(
        Icons.person_rounded,
        color: cs.primary,
        size: size * 0.48,
      ),
    );
  }
}

class _CachedNetImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final bool isAvatar;

  const _CachedNetImage({
    required this.url,
    this.width,
    this.height,
    this.isAvatar = false,
  });

  int? get _cacheWidth {
    final w = width;
    if (w == null || !w.isFinite || w <= 0) return null;
    return (w * 2).round();
  }

  int? get _cacheHeight {
    final h = height;
    if (h == null || !h.isFinite || h <= 0) return null;
    return (h * 2).round();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (url.trim().isEmpty) {
      return _fallback(cs);
    }

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      memCacheWidth: _cacheWidth,
      memCacheHeight: _cacheHeight,
      placeholder: (_, __) {
        if (isAvatar) {
          return _AvatarFallback(
            size: width ?? 76,
            loading: true,
          );
        }

        return Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          color: cs.primary.withOpacity(0.10),
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: cs.primary,
            ),
          ),
        );
      },
      errorWidget: (_, __, ___) {
        if (isAvatar) {
          return _AvatarFallback(size: width ?? 76);
        }

        return _fallback(cs);
      },
    );
  }

  Widget _fallback(ColorScheme cs) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: cs.primary.withOpacity(0.10),
      child: Icon(
        isAvatar ? Icons.person_rounded : Icons.menu_book_rounded,
        color: cs.primary,
      ),
    );
  }
}

class _BookMini {
  final String id;
  final String title;
  final String author;
  final String category;
  final String coverUrl;
  final double progress;

  const _BookMini({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.coverUrl,
    required this.progress,
  });

  factory _BookMini.fromJson(
      Map<String, dynamic> json, {
        required String baseUrl,
      }) {
    final book = _map(
      json['book'] ??
          json['item'] ??
          json['items'] ??
          json['favorite_book'] ??
          json['progress_book'] ??
          json['book_data'] ??
          json,
    );

    final bookId = _firstText([
      book['id'],
      book['item_id'],
      book['book_id'],
      json['item_id'],
      json['book_id'],
      json['id'],
    ]);

    final cover = _firstText([
      book['cover_url'],
      book['coverUrl'],
      book['cover'],
      book['thumbnail'],
      book['image'],
      book['photo'],
      json['cover_url'],
      json['coverUrl'],
      json['cover'],
      json['thumbnail'],
      json['image'],
    ]);

    return _BookMini(
      id: bookId,
      title: _firstText([
        book['title'],
        json['title'],
        'Book #$bookId',
      ]),
      author: _authorName(book),
      category: _categoryName(book),
      coverUrl: _fullUrl(cover, baseUrl),
      progress: _progressValue(json, book),
    );
  }

  _BookMini copyWith({
    String? id,
    String? title,
    String? author,
    String? category,
    String? coverUrl,
    double? progress,
  }) {
    return _BookMini(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      coverUrl: coverUrl ?? this.coverUrl,
      progress: progress ?? this.progress,
    );
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  static String _text(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty || text == 'null') {
      return fallback;
    }

    return text;
  }

  static String _firstText(List<dynamic> values) {
    for (final value in values) {
      final text = _text(value);

      if (text.isNotEmpty) {
        return text;
      }
    }

    return '';
  }

  static String _authorName(Map<String, dynamic> book) {
    final author = _map(book['author'] ?? book['user']);

    return _text(
      author['name'] ?? book['author_name'] ?? book['author'],
      fallback: 'Unknown author',
    );
  }

  static String _categoryName(Map<String, dynamic> book) {
    final category = _map(book['category']);

    return _text(
      category['name'] ?? book['category_name'],
      fallback: 'Uncategorized',
    );
  }

  static double _progressValue(
      Map<String, dynamic> json,
      Map<String, dynamic> book,
      ) {
    final direct = _firstProgress([
      json['percent'],
      json['progress'],
      json['progress_value'],
      json['percent_read'],
      json['reading_percentage'],
      book['percent'],
      book['progress'],
      book['reading_percentage'],
    ]);

    if (direct > 0) {
      return direct;
    }

    final lastPage = _toDouble(
      json['last_page'] ??
          json['current_page'] ??
          json['page'] ??
          book['last_page'] ??
          book['current_page'],
    );

    final totalPages = _toDouble(
      json['total_pages'] ??
          json['pages'] ??
          book['total_pages'] ??
          book['pages'],
    );

    if (lastPage > 0 && totalPages > 0) {
      return (lastPage / totalPages).clamp(0.0, 1.0).toDouble();
    }

    return 0.0;
  }

  static double _firstProgress(List<dynamic> values) {
    for (final value in values) {
      final progress = _progress(value);

      if (progress > 0) {
        return progress;
      }
    }

    return 0.0;
  }

  static double _progress(dynamic value) {
    if (value == null) return 0.0;

    String text = value.toString().trim();

    if (text.isEmpty || text == 'null') {
      return 0.0;
    }

    text = text.replaceAll('%', '').replaceAll(',', '');

    final number = double.tryParse(text) ?? 0.0;

    if (number <= 0) {
      return 0.0;
    }

    if (number > 0) {
      return (number / 100).clamp(0.0, 1.0).toDouble();
    }

    return number.clamp(0.0, 1.0).toDouble();
  }

  static double _toDouble(dynamic value) {
    if (value == null) {
      return 0.0;
    }

    final text = value.toString().trim().replaceAll(',', '');

    if (text.isEmpty || text == 'null') {
      return 0.0;
    }

    return double.tryParse(text) ?? 0.0;
  }
}

class _ReadingStats {
  final int inProgress;
  final int favorites;

  const _ReadingStats({
    required this.inProgress,
    required this.favorites,
  });

  factory _ReadingStats.fromData({
    required List<_BookMini> favorites,
    required List<_BookMini> history,
  }) {
    return _ReadingStats(
      inProgress: history.where((e) => e.progress > 0 && e.progress < 1).length,
      favorites: favorites.length,
    );
  }
}

class _JsonHelper {
  static Map<String, dynamic> extractUser(dynamic response) {
    final map = toMap(response);

    final user = map['user'] ??
        map['data']?['user'] ??
        map['data'] ??
        map['account'] ??
        map['profile'];

    final userMap = toMap(user);

    if (userMap.isNotEmpty) return userMap;

    if (map.containsKey('id') ||
        map.containsKey('name') ||
        map.containsKey('email')) {
      return map;
    }

    return {};
  }

  static List<dynamic> extractList(dynamic response) {
    if (response is List) return response;

    final map = toMap(response);

    final data = map['data'] ??
        map['items'] ??
        map['books'] ??
        map['favorites'] ??
        map['favorite_books'] ??
        map['progress'] ??
        map['reading_progress'];

    if (data is List) return data;

    return [];
  }

  static Map<String, dynamic> toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }
}

String _fullUrl(String value, String baseUrl) {
  final url = value.trim();

  if (url.isEmpty || url == 'null') return '';

  if (url.startsWith('http://') || url.startsWith('https://')) {
    return url;
  }

  final host = baseUrl
      .replaceFirst(RegExp(r'/api/?$'), '')
      .replaceFirst(RegExp(r'/$'), '');

  if (url.startsWith('/storage/')) return '$host$url';
  if (url.startsWith('storage/')) return '$host/$url';
  if (url.startsWith('/')) return '$host$url';

  return '$host/storage/$url';
}