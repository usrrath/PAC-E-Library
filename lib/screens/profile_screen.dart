//update code app font size
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Demo user
  String name = "Ung Sereyrath";
  String email = "usrrath0168@gmail.com";
  final String userId = "PAC-26-9999";
  String photoUrl = "https://i.pravatar.cc/200?img=12";

  late List<_BookMini> favorites;
  late List<_BookMini> history;
  late List<_DocItem> recentDocs;

  @override
  void initState() {
    super.initState();

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
      _BookMini(
        id: "f3",
        title: "The Little Prince",
        author: "Antoine de Saint-Exupéry",
        category: "Novel",
        coverUrl: "https://covers.openlibrary.org/b/isbn/9780156013987-L.jpg",
        progress: 0.95,
        lastOpened: DateTime.now().subtract(const Duration(days: 6)),
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
      _BookMini(
        id: "h2",
        title: "Domain-Driven Design",
        author: "Eric Evans",
        category: "Business",
        coverUrl: "https://covers.openlibrary.org/b/isbn/9780321125217-L.jpg",
        progress: 0.15,
        lastOpened: DateTime.now().subtract(const Duration(days: 2)),
      ),
      _BookMini(
        id: "h3",
        title: "Head First Design Patterns",
        author: "Eric Freeman",
        category: "Technology",
        coverUrl: "https://covers.openlibrary.org/b/isbn/9780596007126-L.jpg",
        progress: 0.58,
        lastOpened: DateTime.now().subtract(const Duration(days: 4)),
      ),
    ];

    recentDocs = [
      _DocItem(title: "Clean Code - Chapter 3.pdf", type: "PDF", size: "3.2 MB", openedAt: DateTime.now().subtract(const Duration(minutes: 45))),
      _DocItem(title: "Design Patterns - Notes.epub", type: "EPUB", size: "1.1 MB", openedAt: DateTime.now().subtract(const Duration(hours: 5))),
      _DocItem(title: "DDD - Summary.pdf", type: "PDF", size: "2.6 MB", openedAt: DateTime.now().subtract(const Duration(days: 1))),
    ];
  }

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final stats = _ReadingStats.fromData(favorites: favorites, history: history);
    final favCategoryCounts = _categoryCount(favorites);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: "Edit profile",
            onPressed: _openEditProfile,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          _profileHeader(cs),
          const SizedBox(height: 14),

          _sectionTitle("Reading statistics"),
          const SizedBox(height: 10),
          _statsRow(stats),
          // const SizedBox(height: 14),
          // _progressCard(stats),

          const SizedBox(height: 18),
          _sectionTitle("Favorites"),

          // const SizedBox(height: 10),
          // _favoritesHeader(favCategoryCounts),

          const SizedBox(height: 10),
          _horizontalBooks(
            items: favorites,
            trailingAction: (b) {
              setState(() => favorites.removeWhere((x) => x.id == b.id));
              toast("Removed from favorites");
            },
            trailingIcon: Icons.favorite_rounded,
            trailingColor: Colors.red,
          ),

          const SizedBox(height: 18),
          _sectionTitle("Reading Progress"),
          const SizedBox(height: 10),
          _historyList(),

          // const SizedBox(height: 18),
          // _sectionTitle("Recently opened documents"),
          // const SizedBox(height: 10),
          // ...recentDocs.map(_docTile).toList(),
        ],
      ),
    );
  }

  /// ============================
  /// Edit Profile bottom sheet
  /// ============================
  void _openEditProfile() {
    final nameCtrl = TextEditingController(text: name);
    final emailCtrl = TextEditingController(text: email);
    final photoCtrl = TextEditingController(text: photoUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Edit Profile", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Name", border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(
                controller: photoCtrl,
                decoration: const InputDecoration(labelText: "Photo URL", border: OutlineInputBorder(), hintText: "https://..."),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final newName = nameCtrl.text.trim();
                        final newEmail = emailCtrl.text.trim();
                        final newPhoto = photoCtrl.text.trim();

                        setState(() {
                          if (newName.isNotEmpty) name = newName;
                          if (newEmail.isNotEmpty) email = newEmail;
                          if (newPhoto.isNotEmpty) photoUrl = newPhoto;
                        });

                        Navigator.pop(context);
                        WidgetsBinding.instance.addPostFrameCallback((_) => toast("Profile updated"));
                      },
                      child: const Text("Save"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// ----------------------------
  /// Themed card builder
  /// ----------------------------
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
          )
        ],
      ),
      child: child,
    );
  }

  /// ----------------------------
  /// Profile header card
  /// ----------------------------
  Widget _profileHeader(ColorScheme cs) {
    return _themedCard(
      child: Row(
        children: [
          ClipOval(
            child: _CachedNetImage(url: photoUrl, width: 76, height: 76),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: cs.primary.withOpacity(0.18)),
                  ),
                  child: Text(
                    "ID: $userId",
                    style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ----------------------------
  /// Stats
  /// ----------------------------
  Widget _statsRow(_ReadingStats s) {
    return Row(
      children: [
        // Expanded(child: _statCard("Books read", "${s.booksRead}", Icons.done_all_rounded)),
        // const SizedBox(width: 12),
        Expanded(child: _statCard("In progress", "${s.inProgress}", Icons.auto_stories_rounded)),
        const SizedBox(width: 12),
        Expanded(child: _statCard("Favorites", "${s.favorites}", Icons.favorite_rounded)),
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
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _progressCard(_ReadingStats s) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Reading progress tracker", style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: s.avgProgress,
                    minHeight: 10,
                    backgroundColor: cs.primary.withOpacity(0.12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text("${(s.avgProgress * 100).round()}%", style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          Text("Average progress across your reading list.", style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  /// ----------------------------
  /// Favorites
  /// ----------------------------
  Widget _favoritesHeader(Map<String, int> catCounts) {
    final cs = Theme.of(context).colorScheme;
    final topCats = catCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final display = topCats.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Favorite categories", style: TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          if (display.isEmpty)
            Text("No favorites yet.", style: TextStyle(color: cs.onSurfaceVariant))
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: display.map((e) => _pill("${e.key} • ${e.value}")).toList(),
            ),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.18)),
      ),
      child: Text(text, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800)),
    );
  }

  Widget _horizontalBooks({
    required List<_BookMini> items,
    required void Function(_BookMini) trailingAction,
    required IconData trailingIcon,
    required Color trailingColor,
  }) {
    final cs = Theme.of(context).colorScheme;

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.primary.withOpacity(0.12)),
        ),
        child: Text("No books.", style: TextStyle(color: cs.onSurfaceVariant)),
      );
    }

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
                    BoxShadow(blurRadius: 14, color: Colors.black.withOpacity(0.05), offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                            child: _CachedNetImage(url: b.coverUrl, width: double.infinity),
                          ),
                          Positioned(
                            right: 6,
                            top: 6,
                            child: IconButton(
                              onPressed: () => trailingAction(b),
                              icon: Icon(trailingIcon, color: trailingColor),
                              style: IconButton.styleFrom(
                                backgroundColor: Theme.of(context).cardColor.withOpacity(0.85),
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
                          Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                          const SizedBox(height: 3),
                          Text(b.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
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

  Widget _progressRow(double progress) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: cs.primary.withOpacity(0.12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text("${(progress * 100).round()}%", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
      ],
    );
  }

  /// ----------------------------
  /// History list
  /// ----------------------------
  Widget _historyList() {
    final cs = Theme.of(context).colorScheme;

    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.primary.withOpacity(0.12)),
        ),
        child: Text("No history.", style: TextStyle(color: cs.onSurfaceVariant)),
      );
    }

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
              boxShadow: [BoxShadow(blurRadius: 14, color: Colors.black.withOpacity(0.05), offset: const Offset(0, 10))],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _CachedNetImage(url: b.coverUrl, width: 60, height: 84),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(b.author, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 6),
                      Text("Last opened: ${_timeAgo(b.lastOpened)}", style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
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

  /// ----------------------------
  /// Recent documents tiles
  /// ----------------------------
  Widget _docTile(_DocItem d) {
    final cs = Theme.of(context).colorScheme;
    final icon = d.type.toUpperCase() == "PDF" ? Icons.picture_as_pdf_rounded : Icons.book_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.primary.withOpacity(0.18)),
            ),
            child: Icon(icon, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(d.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text("${d.type} • ${d.size} • ${_timeAgo(d.openedAt)}",
                    style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            tooltip: "Open (demo)",
            onPressed: () => toast("Open document: ${d.title}"),
            icon: const Icon(Icons.open_in_new_rounded),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900));

  Map<String, int> _categoryCount(List<_BookMini> items) {
    final map = <String, int>{};
    for (final b in items) {
      map[b.category] = (map[b.category] ?? 0) + 1;
    }
    return map;
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }
}

/// ===============================
/// Cached image widget
/// ===============================
class _CachedNetImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;

  const _CachedNetImage({
    required this.url,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      placeholder: (_, __) => Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        color: cs.primary.withOpacity(0.10),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        color: cs.primary.withOpacity(0.10),
        child: Icon(Icons.menu_book_rounded, color: cs.primary.withOpacity(0.9)),
      ),
    );
  }
}

/// ===============================
/// Models
/// ===============================
class _BookMini {
  final String id;
  final String title;
  final String author;
  final String category;
  final String coverUrl;
  final double progress;
  final DateTime lastOpened;

  _BookMini({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.coverUrl,
    required this.progress,
    required this.lastOpened,
  });
}

class _DocItem {
  final String title;
  final String type; // PDF/EPUB
  final String size;
  final DateTime openedAt;

  _DocItem({
    required this.title,
    required this.type,
    required this.size,
    required this.openedAt,
  });
}

class _ReadingStats {
  final int booksRead;
  final int inProgress;
  final int favorites;
  final double avgProgress;

  _ReadingStats({
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
    final inProgress = all.where((b) => b.progress > 0 && b.progress < 1).length;
    final booksRead = all.where((b) => b.progress >= 1).length;
    final avg = all.isEmpty ? 0.0 : (all.map((b) => b.progress).reduce((a, b) => a + b) / all.length);
    return _ReadingStats(
      booksRead: booksRead,
      inProgress: inProgress,
      favorites: favorites.length,
      avgProgress: avg.clamp(0, 1),
    );
  }
}
