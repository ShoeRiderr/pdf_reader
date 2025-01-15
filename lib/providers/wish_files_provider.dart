import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WishFilesNotifier extends StateNotifier<List<FileSystemEntity>> {
  WishFilesNotifier() : super([]);

  bool toggleWishStatus(FileSystemEntity file) {
    final fileIsInWishList = state.contains(file);

    if (fileIsInWishList) {
      state = state.where((m) => m.path != file.path).toList();
      return false;
    } else {
      state = [...state, file];
      return true;
    }
  }
}

final wishFilesProvider =
StateNotifierProvider<WishFilesNotifier, List<FileSystemEntity>>((ref) {
  return WishFilesNotifier();
});