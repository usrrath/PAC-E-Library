import 'package:flutter/material.dart';

import 'home_screen.dart';

class ContinueReadingScreen extends StatelessWidget {
  const ContinueReadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final books = allBooks.where((e) => e.isPdf).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Continue Reading"),
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
              subtitle: const Text("Reading progress: 45%"),
              trailing: const Icon(Icons.play_arrow_rounded),
            ),
          );
        },
      ),
    );
  }
}