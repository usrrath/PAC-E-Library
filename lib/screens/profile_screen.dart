import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../l10n/app_localizations.dart';
import '../models/book_mini_model.dart';
import '../models/library_detail_model.dart';
import '../models/library_models.dart';
import '../models/profile_edit_result.dart';
import '../models/reading_stats_model.dart';
import '../models/user_model.dart';
import '../services/api_users_favorites.dart';
import '../services/api_users_reading.dart';
import '../services/library_detail_service.dart';
import '../services/profile_service.dart';
import '../services/user_service.dart';
import '../utils/profile_cards.dart';
import '../widgets/edit_profile_sheet.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_book_widgets.dart';
import 'library_detail_screen.dart';
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
  final ImagePicker _picker = ImagePicker();

  UserModel? user;

  bool loading = true;
  bool saving = false;
  bool openingBook = false;

  String? errorMessage;

  final List<BookMini> favoriteBooks = [];
  final List<BookMini> readingBooks = [];

  AppLocalizations get t => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  bool _isInternetError(Object error) {
    final msg = error.toString().toLowerCase();

    return msg.contains('socketexception') ||
        msg.contains('clientexception') ||
        msg.contains('network is unreachable') ||
        msg.contains('connection failed') ||
        msg.contains('failed host lookup') ||
        msg.contains('no address associated with hostname') ||
        msg.contains('connection refused') ||
        msg.contains('timed out') ||
        msg.contains('timeout');
  }

  String _friendlyError(Object error) {
    if (_isInternetError(error)) return 'Error Internet';

    final msg = error.toString().replaceFirst('Exception: ', '').trim();

    return msg.isEmpty ? 'Something went wrong' : msg;
  }

  Future<File> _processProfilePhoto(
      File file, {
        bool frontCamera = false,
        int rotateDegrees = 0,
      }) async {
    try {
      final bytes = await file.readAsBytes();
      final decoded = img.decodeImage(bytes);

      if (decoded == null) return file;

      img.Image fixed = img.bakeOrientation(decoded);

      if (frontCamera) {
        fixed = img.flipHorizontal(fixed);
      }

      if (rotateDegrees == 90) {
        fixed = img.copyRotate(fixed, 90);
      } else if (rotateDegrees == -90) {
        fixed = img.copyRotate(fixed, -90);
      } else if (rotateDegrees == 180) {
        fixed = img.copyRotate(fixed, 180);
      }

      final square = img.copyResizeCropSquare(
        fixed,
        854,
      );

      final jpgBytes = img.encodeJpg(
        square,
        quality: 92,
      );

      final output = File(
        '${Directory.systemTemp.path}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await output.writeAsBytes(jpgBytes, flush: true);

      return output;
    } catch (e) {
      debugPrint('Profile photo process error: $e');
      return file;
    }
  }

  Future<File?> _showPhotoPreview({
    required File originalFile,
    required bool frontCamera,
  }) async {
    int rotateDegrees = 0;

    File previewFile = await _processProfilePhoto(
      originalFile,
      frontCamera: frontCamera,
      rotateDegrees: rotateDegrees,
    );

    if (!mounted) return previewFile;

    return showDialog<File?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> refreshPreview() async {
              final newFile = await _processProfilePhoto(
                originalFile,
                frontCamera: frontCamera,
                rotateDegrees: rotateDegrees,
              );

              setDialogState(() {
                previewFile = newFile;
              });
            }

            return AlertDialog(
              title: const Text(
                'Preview Photo',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: Image.file(
                      previewFile,
                      key: ValueKey(previewFile.path),
                      width: 380,
                      height: 380,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Rotate left',
                        onPressed: () async {
                          rotateDegrees -= 90;
                          await refreshPreview();
                        },
                        icon: const Icon(Icons.rotate_left_rounded),
                      ),
                      const SizedBox(width: 14),
                      IconButton.filledTonal(
                        tooltip: 'Rotate right',
                        onPressed: () async {
                          rotateDegrees += 90;
                          await refreshPreview();
                        },
                        icon: const Icon(Icons.rotate_right_rounded),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, null);
                  },
                  child: const Text('Retake'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, previewFile);
                  },
                  child: const Text('Use Photo'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<File?> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Upload Photo'),
                  subtitle: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text('Take Photo'),
                  subtitle: const Text('Use front camera'),
                  onTap: () {
                    Navigator.pop(context, ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return null;

    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 100,
        preferredCameraDevice: CameraDevice.front,
      );

      if (picked == null) return null;

      final originalFile = File(picked.path);
      final isCamera = source == ImageSource.camera;

      final previewFile = await _showPhotoPreview(
        originalFile: originalFile,
        frontCamera: isCamera,
      );

      return previewFile;
    } catch (e) {
      _toast(_friendlyError(e));
      return null;
    }
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final token = await ProfileService.getToken();

      if (token == null || token.trim().isEmpty) {
        throw Exception(t.profilesTokenNotFound);
      }

      final responses = await Future.wait([
        _userService.getVerifyAccount(token).timeout(
          const Duration(seconds: 20),
        ),
        _favoritesService.getUserFavorites(token).timeout(
          const Duration(seconds: 20),
        ),
        _readingService.getUserReadingProgress(token).timeout(
          const Duration(seconds: 20),
        ),
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
        ..sort(
              (a, b) => b.normalizedProgress.compareTo(a.normalizedProgress),
        );

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

        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = _friendlyError(e);
        favoriteBooks.clear();
        readingBooks.clear();
      });
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
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
      categories: category.isEmpty ? const [] : [category],
      tags: const [],
      description: book.description.trim().isNotEmpty
          ? book.description.trim()
          : 'No description available.',
      coverUrl: book.coverUrl.trim(),
    );
  }

  Book _detailToBook(LibraryDetailModel item) {
    return Book(
      id: item.id.trim(),
      title: item.title.trim().isNotEmpty ? item.title.trim() : 'Untitled',
      author: item.author.trim().isNotEmpty
          ? item.author.trim()
          : 'Unknown Author',
      categories: item.categories,
      tags: item.tags,
      description: item.description.trim().isNotEmpty
          ? item.description.trim()
          : 'No description available.',
      coverUrl: _detailService.fullUrl(item.coverUrl),
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
      _toast(_friendlyError(e));
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
      if (mounted) {
        setState(() => openingBook = false);
      }
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
      _toast(_friendlyError(e));
    } finally {
      if (mounted) {
        setState(() => openingBook = false);
      }
    }
  }

  Future<void> _openEditProfile() async {
    if (loading || saving) return;

    final currentUser = user;

    final result = await showModalBottomSheet<ProfileEditResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return EditProfileSheet(
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

      // final response = await _userService.updateProfile(
      //   token: token,
      //   name: hasNameChanged ? cleanName : null,
      //   photo: hasPhotoChanged ? inputPhoto : null,
      // );
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

      await _loadProfile();

      _toast(t.profilesProfileUpdatedSuccessfully);
    } catch (e) {
      _toast(_friendlyError(e));
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
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
      appBar: errorMessage != null
          ? null
          : AppBar(
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
          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (errorMessage != null)
            _internetErrorView(errorMessage!)
          else
            RefreshIndicator(
              onRefresh: _loadProfile,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
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

  Widget _internetErrorView(String message) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 34),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.22),
          Icon(
            Icons.wifi_off_rounded,
            size: 72,
            color: isDark
                ? const Color(0xFFD89A91)
                : cs.error.withOpacity(0.75),
          ),
          const SizedBox(height: 28),
          Text(
            'Unable to load profile',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 26,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.72),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 72,
            child: FilledButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh_rounded, size: 28),
              label: const Text(
                'Try again',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF9DCAFA)
                    : cs.primaryContainer,
                foregroundColor: isDark
                    ? const Color(0xFF073A58)
                    : cs.onPrimaryContainer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileHeader() {
    final cs = Theme.of(context).colorScheme;
    final currentUser = user;

    return ProfileCard(
      child: Row(
        children: [
          ProfileAvatar(
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
                      ProfileBadge(
                        text: t.profilesUserId(currentUser!.id),
                      ),
                    if (currentUser?.level.isNotEmpty == true)
                      ProfileBadge(text: currentUser!.level),
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
          child: ProfileStatCard(
            title: t.profilesInProgress,
            value: stats.inProgress.toString(),
            icon: Icons.auto_stories_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ProfileStatCard(
            title: t.favorites,
            value: stats.favorites.toString(),
            icon: Icons.favorite_rounded,
          ),
        ),
      ],
    );
  }

  Widget _horizontalBooks() {
    if (favoriteBooks.isEmpty) {
      return EmptyProfileCard(text: t.profilesNoFavoriteBooks);
    }

    return SizedBox(
      height: 205,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favoriteBooks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final book = favoriteBooks[index];

          return FavoriteBookCard(
            book: book,
            onTap: () => _openFavoriteDetails(book),
          );
        },
      ),
    );
  }

  Widget _readingList() {
    if (readingBooks.isEmpty) {
      return EmptyProfileCard(text: t.profilesNoReadingProgress);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: readingBooks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final book = readingBooks[index];

        return ReadingBookTile(
          book: book,
          onTap: () => _openReadingView(book),
        );
      },
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
}