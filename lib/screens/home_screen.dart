//update code app font size
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../l10n/app_localizations.dart';

import '/screens/library_screen.dart';
import '/screens/notify_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/search_screen.dart';
import '/screens/setting_screen.dart';

/// ===============================
/// RUN APP (ThemeMode Global)
/// ===============================
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// ✅ SettingScreen should update this:
  /// MyApp.themeMode.value = ThemeMode.dark/light/system
  static final ValueNotifier<ThemeMode> themeMode =
  ValueNotifier<ThemeMode>(ThemeMode.system);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: MyApp.themeMode,
      builder: (_, mode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "PAC E-Library",
          themeMode: mode,

          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,

          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            scaffoldBackgroundColor: const Color(0xFFF7F9FC),
          ),

          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),

          home: const MainShell(),
        );

      },
    );
  }
}

/// ===============================
/// Bottom Navigation Shell
/// ===============================
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    LibraryScreen(),
    SearchScreen(),
    ProfileScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: _pages[_index],

      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        height: 70,

        onDestinationSelected: (i) {
          setState(() => _index = i);
        },

        indicatorColor: cs.primary.withOpacity(0.16),

        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: t.menuHome,
          ),

          NavigationDestination(
            icon: const Icon(Icons.local_library_outlined),
            selectedIcon: const Icon(Icons.local_library),
            label: t.menuLibrary,
          ),

          NavigationDestination(
            icon: const Icon(Icons.search_outlined),
            selectedIcon: const Icon(Icons.search),
            label: t.menuSearch,
          ),

          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: t.menuProfile,
          ),

          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: t.menuSettings,
          ),
        ],
      ),
    );
  }


}

/// ===============================
/// Safe Online Image Widget (Theme-aware)
/// ===============================
class SafeNetImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  const SafeNetImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radius = 0,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget img = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        alignment: Alignment.center,
        color: cs.primary.withOpacity(0.10),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        alignment: Alignment.center,
        color: cs.primary.withOpacity(0.10),
        child: Icon(Icons.menu_book_rounded, color: cs.primary),
      ),
    );

    if (radius > 0) {
      img = ClipRRect(borderRadius: BorderRadius.circular(radius), child: img);
    }
    return img;
  }
}

/// ===============================
/// DATA
/// ===============================
class BookViewItem {
  final String title;
  final String author;
  final String imageUrl;
  final String category;
  final bool isNew;
  final bool isFree;
  final bool isTrending;
  final bool isPdf;

  BookViewItem({
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.category,
    this.isNew = false,
    this.isFree = false,
    this.isTrending = false,
    this.isPdf = false,
  });
}

final List<BookViewItem> allBooks = [
  BookViewItem(
    title: "Clean Code",
    author: "Robert C. Martin",
    category: "Technology",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg",
    isNew: true,
    isTrending: true,
    isPdf: true,
  ),
  BookViewItem(
    title: "Clean Architecture",
    author: "Robert C. Martin",
    category: "Technology",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9780134494166-M.jpg",
    isTrending: true,
    isPdf: true,
  ),
  BookViewItem(
    title: "The Pragmatic Programmer",
    author: "Andrew Hunt",
    category: "Technology",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9780201616224-L.jpg",
    isNew: true,
    isPdf: true,
  ),
  BookViewItem(
    title: "The Lean Startup",
    author: "Eric Ries",
    category: "Business",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9780307887894-L.jpg",
    isTrending: true,
    isFree: true,
    isPdf: true,
  ),
  BookViewItem(
    title: "Atomic Habits",
    author: "James Clear",
    category: "Business",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg",
    isNew: true,
    isTrending: true,
  ),
  BookViewItem(
    title: "Rich Dad Poor Dad",
    author: "Robert Kiyosaki",
    category: "Business",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9781612680194-L.jpg",
    isFree: true,
  ),
  BookViewItem(
    title: "1984",
    author: "George Orwell",
    category: "Novel",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg",
    isTrending: true,
  ),
  BookViewItem(
    title: "The Alchemist",
    author: "Paulo Coelho",
    category: "Novel",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9780061122415-L.jpg",
    isFree: true,
  ),
  BookViewItem(
    title: "Harry Potter",
    author: "J.K. Rowling",
    category: "Novel",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9780747532699-L.jpg",
    isNew: true,
  ),
  BookViewItem(
    title: "You Don’t Know JS",
    author: "Kyle Simpson",
    category: "Technology",
    imageUrl:
    "https://books.google.com/books/content?id=ISBN:9781491904244&printsec=frontcover&img=1&zoom=1",
    isPdf: true,
  ),
];

/// ===============================
/// HOME SCREEN (Theme-aware)
/// ===============================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String userName = "Ung Sereyrath";
  final String profileUrl = "https://i.pravatar.cc/150?img=12";

  String selectedCategory = "All";
  String quickFilter = "All";

  List<BookViewItem> get filteredBooks {
    List<BookViewItem> list = allBooks;

    if (selectedCategory != "All") {
      list = list.where((b) => b.category == selectedCategory).toList();
    }

    switch (quickFilter) {
      case "Trending":
        list = list.where((b) => b.isTrending).toList();
        break;
      case "New":
        list = list.where((b) => b.isNew).toList();
        break;
      case "Free":
        list = list.where((b) => b.isFree).toList();
        break;
      case "PDF":
        list = list.where((b) => b.isPdf).toList();
        break;
    }

    return list.take(10).toList();
  }

  late final List<Map<String, String>> quickAccess;
  late final List<Map<String, String>> bannerItems;

  final List<String> coverUrls = const [
    "https://covers.openlibrary.org/b/isbn/9780131103627-L.jpg",
    "https://covers.openlibrary.org/b/isbn/9780321125217-L.jpg",
    "https://covers.openlibrary.org/b/isbn/9780201633610-L.jpg",
  ];

  @override
  void initState() {
    super.initState();

    quickAccess = [
      {"title": "Continue Reading", "subtitle": "Resume your last book", "img": allBooks[0].imageUrl},
      // {"title": "Recent Downloads", "subtitle": "Offline ready", "img": allBooks[1].imageUrl},
      {"title": "Favorites", "subtitle": "Saved books", "img": allBooks[2].imageUrl},
    ];

    bannerItems = [
      {"title": "Recommended", "img": coverUrls[0]},
      {"title": "Popular Books", "img": coverUrls[1]},
      {"title": "New Releases", "img": coverUrls[2]},
    ];
  }

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final categories = const ["All", "Technology", "Business", "Novel"];
    final filters = const ["All", "Trending", "New", "Free", "PDF"];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text("PAC E-Library", style: TextStyle(fontWeight: FontWeight.w800)),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const NotifyScreen(),
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            // _buildGreetingCard(cs),
            // const SizedBox(height: 14),

            _sectionHeader("Quick Access", cs, onViewAll: () => toast("View all: Quick Access")),
            const SizedBox(height: 10),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: quickAccess.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => toast("Open: ${quickAccess[i]["title"]}"),
                  child: _QuickAccessCard(
                    title: quickAccess[i]["title"] ?? "",
                    subtitle: quickAccess[i]["subtitle"] ?? "",
                    imageUrl: quickAccess[i]["img"] ?? "",
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),
            _sectionHeader("Highlights", cs, onViewAll: () => toast("View all: Highlights")),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: PageView.builder(
                itemCount: bannerItems.length,
                controller: PageController(viewportFraction: 0.92),
                itemBuilder: (_, i) => _BannerCard(
                  title: bannerItems[i]["title"] ?? "",
                  imageUrl: bannerItems[i]["img"] ?? "",
                  onTap: () => toast("Explore: ${bannerItems[i]["title"]}"),
                ),
              ),
            ),



            const SizedBox(height: 18),
            _sectionHeader("Books ($selectedCategory • $quickFilter)", cs, onViewAll: () => toast("View all: Books")),
            const SizedBox(height: 10),

            GridView.builder(
              itemCount: filteredBooks.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (_, i) {
                final book = filteredBooks[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => toast("Open ${book.title}"),
                  child: _BookCard(
                    title: book.title,
                    author: book.author,
                    imageUrl: book.imageUrl,
                    badge: book.isNew ? "NEW" : (book.isFree ? "FREE" : null),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildGreetingCard(ColorScheme cs) {
  //   return Container(
  //     padding: const EdgeInsets.all(14),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).cardColor,
  //       borderRadius: BorderRadius.circular(18),
  //       border: Border.all(color: cs.primary.withOpacity(0.12)),
  //       boxShadow: [
  //         BoxShadow(
  //           blurRadius: 16,
  //           color: Colors.black.withOpacity(0.06),
  //           offset: const Offset(0, 10),
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         ClipOval(child: SafeNetImage(url: profileUrl, width: 48, height: 48)),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text("Hello, $userName 👋",
  //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cs.onSurface)),
  //               const SizedBox(height: 4),
  //               Text(
  //                 "Let’s continue your reading journey today.",
  //                 style: TextStyle(color: cs.onSurfaceVariant),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _sectionHeader(String title, ColorScheme cs, {required VoidCallback onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: cs.onSurface)),
        TextButton(
          onPressed: onViewAll,
          child: Text("View all", style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

/// ===============================
/// Cards (Theme-aware)
/// ===============================
class _QuickAccessCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imageUrl;

  const _QuickAccessCard({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(blurRadius: 14, color: Colors.black.withOpacity(0.05), offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          SafeNetImage(url: imageUrl, width: 54, height: 72, radius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: cs.primary),
        ],
      ),
    );
  }
}

class _BannerCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final VoidCallback onTap;

  const _BannerCard({
    required this.title,
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                cs.primary.withOpacity(0.18),
                cs.primary.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: cs.primary.withOpacity(0.18)),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 2,
                bottom: 2,
                child: SafeNetImage(url: imageUrl, height: 190, radius: 18),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.primary.withOpacity(0.14)),
                      ),
                      child: Text(
                        "Featured",
                        style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary),
                      ),
                    ),
                    const Spacer(),
                    Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: cs.onSurface)),
                    const SizedBox(height: 6),

                    Text(
                      _limitText("Discover curated books for you.", 22),
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),


                    const SizedBox(height: 6),
                    ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text("Explore"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _limitText(String text, int maxChars) {
  if (text.length <= maxChars) return text;
  return '${text.substring(0, maxChars)}...';
}


class _BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;
  final String? badge;

  const _BookCard({
    required this.title,
    required this.author,
    required this.imageUrl,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
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
                  child: SafeNetImage(url: imageUrl, width: double.infinity, fit: BoxFit.cover),
                ),
                if (badge != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(14)),
                      child: Text(
                        badge!,
                        style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.w900, color: cs.onSurface)),
                const SizedBox(height: 4),
                Text(author, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: cs.onSurfaceVariant)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text("4.6", style: TextStyle(fontWeight: FontWeight.w800, color: cs.onSurface)),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.favorite_border_rounded, color: cs.primary),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
