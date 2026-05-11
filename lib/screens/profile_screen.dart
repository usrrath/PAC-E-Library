import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';
import '../models/library_detail_model.dart';
import '../models/profile_models.dart';
import '../models/user_model.dart';
import '../services/api_users_favorites.dart';
import '../services/api_users_reading.dart';
import '../services/library_detail_service.dart';
import '../services/profile_service.dart';
import '../services/user_service.dart';
import 'library_detail_screen.dart';
import 'library_screen.dart';
import 'library_view_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  final ApiUserServiceFavorites _favoritesService = ApiUserServiceFavorites();
  final ApiUserServiceReading _readingService = ApiUserServiceReading();
  final LibraryDetailService _detailService = LibraryDetailService();

  UserModel? user;

  bool loading = true;
  bool saving = false;
  bool openingBook = false;

  final List<BookMini> favoriteBooks = [];
  final List<BookMini> readingBooks = [];

  AppLocalizations get t => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() => loading = true);

    try {
      final token = await ProfileService.getToken();

      if (token == null || token.trim().isEmpty) {
        throw Exception(t.profilesTokenNotFound);
      }

      final responses = await Future.wait([
        _userService.getVerifyAccount(token),
        _favoritesService.getUserFavorites(token),
        _readingService.getUserReadingProgress(token),
      ]);

      final userMap = ProfileService.extractUser(responses[0]);

      final readingList = ProfileService.extractList(responses[2])
          .map(
            (e) => ProfileService.bookFromJson(
          ProfileService.toMap(e),
          baseUrl: _userService.base,
        ),
      )
          .where((book) => book.id.trim().isNotEmpty)
          .toList()
        ..sort((a, b) => b.normalizedProgress.compareTo(a.normalizedProgress));

      final progressMap = {
        for (final book in readingList) book.id.trim(): book,
      };

      final favoriteList = ProfileService.extractList(responses[1])
          .map((e) {
        final book = ProfileService.bookFromJson(
          ProfileService.toMap(e),
          baseUrl: _userService.base,
        );

        final progressBook = progressMap[book.id.trim()];

        return progressBook == null
            ? book
            : book.copyWith(
          progress: progressBook.progress,
          lastPage: progressBook.lastPage,
          totalPages: progressBook.totalPages,
        );
      })
          .where((book) => book.id.trim().isNotEmpty)
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
      _toast(ProfileService.cleanError(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Book _miniToBook(BookMini book) {
    final category = book.category.trim();

    return Book(
      id: book.id.trim(),
      title: book.title.trim().isNotEmpty ? book.title.trim() : 'Untitled',
      author: book.author.trim().isNotEmpty
          ? book.author.trim()
          : 'Unknown Author',
      publisher: '',
      rating: 0,
      categories: category.isEmpty ? const [] : [category],
      tags: const [],
      description: book.description.trim().isNotEmpty
          ? book.description.trim()
          : 'No description available.',
      coverUrl: book.coverUrl.trim(),
      reviews: const [],
    );
  }

  Book _detailToBook(LibraryDetailModel item) {
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
      coverUrl: _detailService.fullUrl(item.coverUrl),
      reviews: const [],
    );
  }

  Future<Book?> _fetchBookById(String id) async {
    final cleanId = id.trim();

    if (cleanId.isEmpty) {
      _toast('Book ID not found.');
      return null;
    }

    try {
      final detail = await _detailService.getBookDetail(cleanId);
      return _detailToBook(detail);
    } catch (e) {
      _toast(ProfileService.cleanError(e));
      return null;
    }
  }

  Future<void> _openFavoriteDetails(BookMini mini) async {
    if (openingBook) return;

    setState(() => openingBook = true);

    try {
      final book = await _fetchBookById(mini.id);

      if (!mounted || book == null) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LibraryDetailScreen(
            book: book,
            allBooks: const [],
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => openingBook = false);
    }
  }

  Future<void> _openReadingView(BookMini mini) async {
    if (openingBook) return;

    final cleanId = mini.id.trim();

    if (cleanId.isEmpty) {
      _toast('Book ID not found.');
      return;
    }

    setState(() => openingBook = true);

    try {
      Book book;

      try {
        final detail = await _detailService.getBookDetail(cleanId);
        book = _detailToBook(detail);
      } catch (_) {
        book = _miniToBook(mini);
      }

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => LibraryViewScreen(book: book),
        ),
      );
    } catch (e) {
      _toast(ProfileService.cleanError(e));
    } finally {
      if (mounted) setState(() => openingBook = false);
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

    final result = await showModalBottomSheet<ProfileEditResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return _EditProfileSheet(
          name: currentUser?.name ?? '',
          email: currentUser?.email ?? '',
          userLevel: currentUser?.level ?? '',
          photoUrl: ProfileService.fullUrl(
            currentUser?.photo ?? '',
            _userService.base,
          ),
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
      final token = await ProfileService.getToken();

      if (token == null || token.trim().isEmpty) {
        throw Exception(t.profilesTokenNotFound);
      }

      final response = await _userService.updateProfile(
        token: token,
        name: hasNameChanged ? cleanName : null,
        photo: hasPhotoChanged ? inputPhoto : null,
      );

      final userMap = ProfileService.extractUser(response);

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
      _toast(ProfileService.cleanError(e));
    } finally {
      if (mounted) setState(() => saving = false);
    }
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
    final stats = ReadingStats.fromData(
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
                _horizontalBooks(),
                const SizedBox(height: 20),
                _sectionTitle(t.profilesReadingProgress),
                const SizedBox(height: 10),
                _readingList(),
              ],
            ),
          ),
          if (saving || openingBook)
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
            photoUrl: ProfileService.fullUrl(
              currentUser?.photo ?? '',
              _userService.base,
            ),
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

  Widget _statsRow(ReadingStats stats) {
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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          Text(
            title,
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _horizontalBooks() {
    final cs = Theme.of(context).colorScheme;

    if (favoriteBooks.isEmpty) {
      return _emptyCard(t.profilesNoFavoriteBooks);
    }

    return SizedBox(
      height: 205,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favoriteBooks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final book = favoriteBooks[index];

          return InkWell(
            onTap: () => _openFavoriteDetails(book),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 120,
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
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: Icon(
                            Icons.favorite_rounded,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: _bookInfo(book, showProgress: false),
                  ),
                ],
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
          onTap: () => _openReadingView(book),
          borderRadius: BorderRadius.circular(18),
          child: _card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Icon(Icons.play_arrow_rounded, color: cs.primary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bookInfo(BookMini book, {bool showProgress = true}) {
    final cs = Theme.of(context).colorScheme;
    final title = book.title.trim().isNotEmpty ? book.title.trim() : 'Untitled';
    final author = book.author.trim().isNotEmpty
        ? book.author.trim()
        : 'Unknown Author';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
        ),
        if (showProgress) ...[
          const SizedBox(height: 6),
          Text(
            book.safeTotalPages > 0
                ? 'Page ${book.safeLastPage} / ${book.safeTotalPages}'
                : 'Page ${book.safeLastPage}',
            style: TextStyle(
              color: cs.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          _progressRow(book.normalizedProgress),
        ],
      ],
    );
  }

  Widget _progressRow(double progress) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();
    final percent = safeProgress * 100;

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
          '${percent.toStringAsFixed(2)}%',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
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
      ProfileEditResult(
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final safeUrl = url.trim();

    if (safeUrl.isEmpty) return _fallback(cs);

    return CachedNetworkImage(
      imageUrl: safeUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      memCacheWidth: width == null ? null : (width! * 2).round(),
      memCacheHeight: height == null ? null : (height! * 2).round(),
      placeholder: (_, __) {
        if (isAvatar) {
          return _AvatarFallback(size: width ?? 76, loading: true);
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
        if (isAvatar) return _AvatarFallback(size: width ?? 76);
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