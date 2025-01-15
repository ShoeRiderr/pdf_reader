import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadFilesNotifier extends StateNotifier<List<FileSystemEntity>> {
  ReadFilesNotifier() : super([]);

  bool toggleReadStatus(FileSystemEntity file) {
    final fileIsRead = state.contains(file);

    if (fileIsRead) {
      state = state.where((m) => m.path != file.path).toList();
      return false;
    } else {
      state = [...state, file];
      return true;
    }
  }
}

final readFilesProvider =
StateNotifierProvider<ReadFilesNotifier, List<FileSystemEntity>>((ref) {
  return ReadFilesNotifier();
});