//
// // ✅ Demo books with cover images (replace with your API data)
// final List<_Book> continueReading = const [
//   _Book("1Atomic Habits", "James Clear", "https://picsum.photos/seed/atomic/300/450"),
//   _Book("The Silent Patient", "Alex Michaelides", "https://picsum.photos/seed/silent/300/450"),
//   _Book("Deep Work", "Cal Newport", "https://picsum.photos/seed/deepwork/300/450"),
// ];
//
// final List<_Book> recentDownloads = const [
//   _Book("2Clean Code", "Robert C. Martin", "https://picsum.photos/seed/cleancode/300/450"),
//   _Book("Start With Why", "Simon Sinek", "https://picsum.photos/seed/startwhy/300/450"),
//   _Book("Psychology of Money", "Morgan Housel", "https://picsum.photos/seed/money/300/450"),
// ];
//
// final List<_Book> recentFavorites = const [
//   _Book("3The Lean Startup", "Eric Ries", "https://picsum.photos/seed/lean/300/450"),
//   _Book("Sapiens", "Yuval Noah Harari", "https://picsum.photos/seed/sapiens/300/450"),
//   _Book("Ikigai", "Héctor García", "https://picsum.photos/seed/ikigai/300/450"),
// ];
//
// // ✅ Banners with images
// final List<_BannerItem> banners = const [
//   _BannerItem(
//     title: "New Releases",
//     subtitle: "Fresh books added this week",
//     imageUrl: "https://picsum.photos/seed/newreleases/900/600",
//   ),
//   _BannerItem(
//     title: "Popular Books",
//     subtitle: "Most read by the community",
//     imageUrl: "https://picsum.photos/seed/popular/900/600",
//   ),
//   _BannerItem(
//     title: "Recommended for You",
//     subtitle: "Based on your reading",
//     imageUrl: "https://picsum.photos/seed/recommended/900/600",
//   ),
// ];
// // ------------------------ Models ------------------------
//
// class _Book {
//   final String title;
//   final String author;
//   final String coverUrl;
//   const _Book(this.title, this.author, this.coverUrl);
// }
//
// class _BannerItem {
//   final String title;
//   final String subtitle;
//   final String imageUrl;
//   const _BannerItem({
//     required this.title,
//     required this.subtitle,
//     required this.imageUrl,
//   });
// }

final List<_Book> continueReading = const [
  _Book(
    "Atomic Habits",
    "James Clear",
    "https://picsum.photos/seed/atomic/300/450",
    "storage/books/atomic-habits.pdf",
    "2018",
  ),
  _Book(
    "The Silent Patient",
    "Alex Michaelides",
    "https://picsum.photos/seed/silent/300/450",
    "storage/books/the-silent-patient.pdf",
    "2019",
  ),
  _Book(
    "Deep Work",
    "Cal Newport",
    "https://picsum.photos/seed/deepwork/300/450",
    "storage/books/deep-work.pdf",
    "2016",
  ),
];

final List<_Book> recentDownloads = const [
  _Book(
    "Clean Code",
    "Robert C. Martin",
    "https://picsum.photos/seed/cleancode/300/450",
    "storage/books/clean-code.pdf",
    "2008",
  ),
  _Book(
    "Start With Why",
    "Simon Sinek",
    "https://picsum.photos/seed/startwhy/300/450",
    "storage/books/start-with-why.pdf",
    "2009",
  ),
  _Book(
    "Psychology of Money",
    "Morgan Housel",
    "https://picsum.photos/seed/money/300/450",
    "storage/books/psychology-of-money.pdf",
    "2020",
  ),
];

final List<_Book> recentFavorites = const [
  _Book(
    "The Lean Startup",
    "Eric Ries",
    "https://picsum.photos/seed/lean/300/450",
    "storage/books/the-lean-startup.pdf",
    "2011",
  ),
  _Book(
    "Sapiens",
    "Yuval Noah Harari",
    "https://picsum.photos/seed/sapiens/300/450",
    "storage/books/sapiens.pdf",
    "2011",
  ),
  _Book(
    "Ikigai",
    "Héctor García",
    "https://picsum.photos/seed/ikigai/300/450",
    "storage/books/ikigai.pdf",
    "2016",
  ),
];

final List<_BannerItem> banners = const [
  _BannerItem(
    title: "New Releases",
    subtitle: "Fresh books added this week",
    imageUrl: "https://picsum.photos/seed/newreleases/900/600",
    fileUrl: "storage/books/new-releases.pdf",
    publishYear: "2025",
  ),
  _BannerItem(
    title: "Popular Books",
    subtitle: "Most read by the community",
    imageUrl: "https://picsum.photos/seed/popular/900/600",
    fileUrl: "storage/books/popular-books.pdf",
    publishYear: "2025",
  ),
  _BannerItem(
    title: "Recommended for You",
    subtitle: "Based on your reading",
    imageUrl: "https://picsum.photos/seed/recommended/900/600",
    fileUrl: "storage/books/recommended.pdf",
    publishYear: "2025",
  ),
];

class _Book {
  final String title;
  final String author;
  final String coverUrl;
  final String fileUrl;
  final String publishYear;

  const _Book(
      this.title,
      this.author,
      this.coverUrl,
      this.fileUrl,
      this.publishYear,
      );
}

class _BannerItem {
  final String title;
  final String subtitle;
  final String imageUrl;
  final String fileUrl;
  final String publishYear;

  const _BannerItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.fileUrl,
    required this.publishYear,
  });
}