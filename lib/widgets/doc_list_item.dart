import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_reader/providers/currently_read_files_provider.dart';
import 'package:pdf_reader/providers/favorite_files.dart';
import 'package:pdf_reader/providers/read_files_provider.dart';
import 'package:pdf_reader/providers/wish_files_provider.dart';

class DocListItem extends ConsumerWidget {
  const DocListItem({super.key, required this.file, required this.onSelectDoc});

  final FileSystemEntity file;
  final void Function() onSelectDoc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteFiles = ref.watch(favoriteFilesProvider);
    final wishFiles = ref.watch(wishFilesProvider);
    final readFiles = ref.watch(readFilesProvider);
    final currentlyReadFiles = ref.watch(currentlyReadFilesProvider);

    final isFavorite = favoriteFiles.contains(file.path);
    final isWish = wishFiles.contains(file.path);
    final isRead = readFiles.contains(file.path);
    final isCurrentlyRead = currentlyReadFiles.contains(file.path);

    return ListTile(
      title: Text(file.uri.pathSegments.last),
      subtitle: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                final wasAdded = ref
                    .read(favoriteFilesProvider.notifier)
                    .toggleStatus(file.path);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        wasAdded ? 'File added as a favorite.' : 'File removed from favourites.'),
                  ),
                );
              },
              icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            ),
            IconButton(
              onPressed: () {
                final wasAdded = ref
                    .read(wishFilesProvider.notifier)
                    .toggleStatus(file.path);
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        wasAdded ? 'File added to wishlist.' : 'File removed from the wishlist.'),
                  ),
                );
              },
              icon: Icon(isWish ? Icons.access_time_filled_outlined : Icons.access_time_outlined),
            ),
            IconButton(
              onPressed: () {
                final wasAdded = ref
                    .read(readFilesProvider.notifier)
                    .toggleStatus(file.path);

                // check if file is currently read
                if (wasAdded && isCurrentlyRead) {
                  ref.read(currentlyReadFilesProvider.notifier).toggleStatus(file.path);
                }

                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        wasAdded ? 'File added to read.' : 'File removed from the read.'),
                  ),
                );
              },
              icon: Icon(isRead ? Icons.check_circle : Icons.check_circle_outline),
            ),
          ],
        ),
      ),
      leading: Icon(Icons.insert_drive_file),
      onTap: onSelectDoc,
    );
  }

}