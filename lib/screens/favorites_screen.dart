import 'package:flutter/material.dart';

import 'home_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final books = allBooks.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final book = books[i];

          return Card(
            child: ListTile(
              leading: SafeNetImage(
                url: book.imageUrl,
                width: 46,
                height: 64,
                radius: 10,
              ),
              title: Text(
                book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(book.author),
              trailing: const Icon(Icons.favorite_rounded, color: Colors.red),
            ),
          );
        },
      ),
    );
  }
}