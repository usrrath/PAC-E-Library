import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  String name = "";
  String email = "";
  String userLevel = "";
  String userId = "";
  String photoUrl = "";

  bool loadingProfile = true;
  bool saving = false;

  late final List<_BookMini> favorites;
  late final List<_BookMini> history;

  @override
  void initState() {
    super.initState();
    _loadDemoBooks();
    _initProfile();
  }

  void _loadDemoBooks() {
    favorites = [
      _BookMini(
        id: "f1",
        title: "Clean Code",
        author: "Robert C. Martin",
        category: "Technology",
        coverUrl: "https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg",
        progress: 0.68,
        lastOpened: DateTime.now().subtract(const Duration(days: 1)),
      ),
      _BookMini(
        id: "f2",
        title: "Design Patterns",
        author: "Erich Gamma",
        category: "Architecture",
        coverUrl: "https://covers.openlibrary.org/b/isbn/9780201633610-L.jpg",
        progress: 0.22,
        lastOpened: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    history = [
      _BookMini(
        id: "h1",
        title: "Clean Architecture",
        author: "Robert C. Martin",
        category: "Technology",
        coverUrl: "https://covers.openlibrary.org/b/isbn/9780134494166-L.jpg",
        progress: 0.40,
        lastOpened: DateTime.now().subtract(const Duration(hours: 10)),
      ),
    ];
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("auth_token") ??
        prefs.getString("token") ??
        prefs.getString("access_token");
  }

  void toast(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst("Exception: ", "")
        .replaceFirst("Verify account error: Exception: ", "")
        .replaceFirst("Profile error: Exception: ", "")
        .replaceFirst("Update profile error: Exception: ", "")
        .replaceFirst("Update name error: Exception: ", "")
        .replaceFirst("Update photo error: Exception: ", "")
        .replaceFirst("Network Error: Exception: ", "");
  }

  String _normalizePhoto(String? value) {
    if (value == null) return "";

    final photo = value.trim();

    if (photo.isEmpty || photo == "null") return "";

    if (photo.startsWith("http://") || photo.startsWith("https://")) {
      return photo;
    }

    final host = _userService.base
        .replaceFirst(RegExp(r"/api/?$"), "")
        .replaceFirst(RegExp(r"/$"), "");

    if (photo.startsWith("/storage/")) return "$host$photo";
    if (photo.startsWith("storage/")) return "$host/$photo";
    if (photo.startsWith("/")) return "$host$photo";

    return "$host/storage/$photo";
  }

  Map<String, dynamic> _toMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  Map<String, dynamic> _extractUser(dynamic response) {
    final map = _toMap(response);
    if (map.isEmpty) return {};

    final possibleUser = map["user"] ??
        map["data"]?["user"] ??
        map["data"] ??
        map["account"] ??
        map["profile"];

    final user = _toMap(possibleUser);

    if (user.isNotEmpty) return user;

    if (map.containsKey("id") ||
        map.containsKey("name") ||
        map.containsKey("email") ||
        map.containsKey("photo")) {
      return map;
    }

    return {};
  }

  void _setUserFromJson(Map<String, dynamic> user) {
    userId = user["id"]?.toString() ?? userId;
    name = user["name"]?.toString() ?? name;
    email = user["email"]?.toString() ?? email;
    userLevel = user["level"]?.toString() ?? user["role"]?.toString() ?? userLevel;

    final rawPhoto =
        user["photo"] ?? user["photo_url"] ?? user["profile_photo"] ?? user["avatar"];

    if (rawPhoto != null) {
      final normalized = _normalizePhoto(rawPhoto.toString());
      if (normalized.isNotEmpty) {
        photoUrl = normalized;
      }
    }
  }

  Future<void> _initProfile() async {
    if (!mounted) return;

    setState(() => loadingProfile = true);

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Token not found. Please login again.");
      }

      final response = await _userService.getVerifyAccount(token);
      final user = _extractUser(response);

      if (!mounted) return;

      if (user.isNotEmpty) {
        setState(() => _setUserFromJson(user));
      } else {
        await _loadProfile(showLoading: false, silent: false);
      }
    } catch (e) {
      toast(_cleanError(e));
    } finally {
      if (mounted) {
        setState(() => loadingProfile = false);
      }
    }
  }

  Future<void> _loadProfile({
    bool showLoading = true,
    bool silent = false,
  }) async {
    if (showLoading && mounted) {
      setState(() => loadingProfile = true);
    }

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Token not found. Please login again.");
      }

      final response = await _userService.getProfile(token);
      final user = _extractUser(response);

      if (user.isEmpty) {
        if (!silent) throw Exception("Invalid profile response.");
        return;
      }

      if (!mounted) return;

      setState(() => _setUserFromJson(user));
    } catch (e) {
      if (!silent) toast(_cleanError(e));
    } finally {
      if (mounted && showLoading) {
        setState(() => loadingProfile = false);
      }
    }
  }

  Future<File?> _pickPhotoFromGallery() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1200,
      maxHeight: 1200,
    );

    if (picked == null) return null;

    return File(picked.path);
  }

  Future<bool> _saveProfile({
    required String inputName,
    required File? inputPhoto,
  }) async {
    final cleanName = inputName.trim();

    final hasNameChanged = cleanName.isNotEmpty && cleanName != name.trim();
    final hasPhotoChanged = inputPhoto != null;

    if (!hasNameChanged && !hasPhotoChanged) {
      toast("No changes to update");
      return false;
    }

    if (!mounted) return false;

    setState(() => saving = true);

    try {
      final token = await _getToken();

      if (token == null || token.isEmpty) {
        throw Exception("Token not found. Please login again.");
      }

      final response = await _userService.updateProfile(
        token: token,
        name: hasNameChanged ? cleanName : null,
        photo: hasPhotoChanged ? inputPhoto : null,
      );

      final user = _extractUser(response);
      final responseMap = _toMap(response);

      if (!mounted) return false;

      setState(() {
        if (user.isNotEmpty) {
          _setUserFromJson(user);
        }

        if (hasNameChanged) {
          name = cleanName;
        }

        final rawPhoto = responseMap["photo"] ??
            responseMap["photo_url"] ??
            responseMap["profile_photo"] ??
            responseMap["avatar"];

        if (rawPhoto != null) {
          final normalized = _normalizePhoto(rawPhoto.toString());
          if (normalized.isNotEmpty) {
            photoUrl = normalized;
          }
        }
      });

      toast("Profile updated");
      return true;
    } catch (e) {
      toast(_cleanError(e));
      return false;
    } finally {
      if (mounted) {
        setState(() => saving = false);
      }
    }
  }

  Future<void> _openEditProfile() async {
    if (saving || loadingProfile) return;

    final result = await showModalBottomSheet<_ProfileEditResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return _EditProfileSheet(
          name: name,
          email: email,
          userLevel: userLevel,
          photoUrl: photoUrl,
          pickPhoto: _pickPhotoFromGallery,
        );
      },
    );

    if (!mounted || result == null) return;

    await _saveProfile(
      inputName: result.name,
      inputPhoto: result.photo,
    );
  }

  @override
  Widget build(BuildContext context) {
    final stats = _ReadingStats.fromData(
      favorites: favorites,
      history: history,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: loadingProfile || saving ? null : _initProfile,
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: "Edit profile",
            onPressed: loadingProfile || saving ? null : _openEditProfile,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _initProfile,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                if (loadingProfile)
                  const Padding(
                    padding: EdgeInsets.only(top: 40, bottom: 30),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  _profileHeader(),

                const SizedBox(height: 18),
                _sectionTitle("Reading statistics"),
                const SizedBox(height: 10),
                _statsRow(stats),

                const SizedBox(height: 18),
                _sectionTitle("Favorites"),
                const SizedBox(height: 10),
                _horizontalBooks(
                  items: favorites,
                  trailingAction: (b) {
                    setState(() {
                      favorites.removeWhere((x) => x.id == b.id);
                    });
                    toast("Removed from favorites");
                  },
                  trailingIcon: Icons.favorite_rounded,
                  trailingColor: Colors.red,
                ),

                const SizedBox(height: 18),
                _sectionTitle("Reading Progress"),
                const SizedBox(height: 10),
                _historyList(),
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

    return _themedCard(
      child: Row(
        children: [
          _ProfileAvatar(
            photoUrl: photoUrl,
            selectedPhoto: null,
            size: 76,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? "No Name" : name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email.isEmpty ? "No Email" : email,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (userId.isNotEmpty) _badge("ID: $userId", Icons.badge_outlined),
                    if (userLevel.isNotEmpty) _badge(userLevel, Icons.verified_user_outlined),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _themedCard({required Widget child}) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _badge(String text, IconData icon) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.primary),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(_ReadingStats s) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            "In progress",
            "${s.inProgress}",
            Icons.auto_stories_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            "Favorites",
            "${s.favorites}",
            Icons.favorite_rounded,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
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
    required void Function(_BookMini) trailingAction,
    required IconData trailingIcon,
    required Color trailingColor,
  }) {
    final cs = Theme.of(context).colorScheme;

    if (items.isEmpty) return _emptyCard("No books.");

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final b = items[i];

          return SizedBox(
            width: 150,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => toast("Open: ${b.title}"),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cs.primary.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 14,
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 10),
                    ),
                  ],
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
                              url: b.coverUrl,
                              width: double.infinity,
                            ),
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: IconButton(
                              onPressed: () => trailingAction(b),
                              icon: Icon(trailingIcon, color: trailingColor),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .cardColor
                                    .withOpacity(0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            b.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _progressRow(b.progress),
                        ],
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

  Widget _historyList() {
    final cs = Theme.of(context).colorScheme;

    if (history.isEmpty) return _emptyCard("No history.");

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final b = history[i];

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => toast("Open: ${b.title}"),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.primary.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 14,
                  color: Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _CachedNetImage(
                    url: b.coverUrl,
                    width: 60,
                    height: 84,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        b.author,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Last opened: ${_timeAgo(b.lastOpened)}",
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _progressRow(b.progress),
                    ],
                  ),
                ),

                Icon(Icons.chevron_right_rounded, color: cs.primary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _progressRow(double progress) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.clamp(0, 1).toDouble(),
              minHeight: 8,
              backgroundColor: cs.primary.withOpacity(0.12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "${(progress * 100).round()}%",
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _emptyCard(String text) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
      ),
      child: Text(text, style: TextStyle(color: cs.onSurfaceVariant)),
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);

    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";

    return "${diff.inDays}d ago";
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

  Future<void> choosePhoto() async {
    final file = await widget.pickPhoto();

    if (!mounted || file == null) return;

    setState(() {
      selectedPhoto = file;
    });
  }

  void save() {
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
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Stack(
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
                      onTap: choosePhoto,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 34,
                        height: 34,
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
            ),

            const SizedBox(height: 18),

            TextField(
              controller: nameCtrl,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              initialValue: widget.email,
              enabled: false,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),

            const SizedBox(height: 12),

            TextFormField(
              initialValue: widget.userLevel,
              enabled: false,
              decoration: const InputDecoration(
                labelText: "User Level",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.verified_user_outlined),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: save,
                    child: const Text("Save"),
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

    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
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
        if (isAvatar) return _AvatarFallback(size: width ?? 76);

        return Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          color: cs.primary.withOpacity(0.10),
          child: Icon(
            Icons.menu_book_rounded,
            color: cs.primary.withOpacity(0.9),
          ),
        );
      },
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
  final DateTime lastOpened;

  const _BookMini({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.coverUrl,
    required this.progress,
    required this.lastOpened,
  });
}

class _ReadingStats {
  final int booksRead;
  final int inProgress;
  final int favorites;
  final double avgProgress;

  const _ReadingStats({
    required this.booksRead,
    required this.inProgress,
    required this.favorites,
    required this.avgProgress,
  });

  static _ReadingStats fromData({
    required List<_BookMini> favorites,
    required List<_BookMini> history,
  }) {
    final all = [...favorites, ...history];

    final inProgress = all.where((b) {
      return b.progress > 0 && b.progress < 1;
    }).length;

    final booksRead = all.where((b) {
      return b.progress >= 1;
    }).length;

    final avg = all.isEmpty
        ? 0.0
        : all.map((b) => b.progress).reduce((a, b) => a + b) / all.length;

    return _ReadingStats(
      booksRead: booksRead,
      inProgress: inProgress,
      favorites: favorites.length,
      avgProgress: avg.clamp(0, 1).toDouble(),
    );
  }
}