import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentlyReadFilesProvider extends StateNotifier<List<FileSystemEntity>> {
  CurrentlyReadFilesProvider() : super([]);

  bool toggleFileCurrentlyReadStatus(FileSystemEntity file) {
    final fileIsCurrentlyRead = state.contains(file);

    if (fileIsCurrentlyRead) {
      state = state.where((m) => m.path != file.path).toList();
      return false;
    } else {
      state = [...state, file];
      return true;
    }
  }
}

final currentlyReadFilesProvider =
StateNotifierProvider<CurrentlyReadFilesProvider, List<FileSystemEntity>>((ref) {
  return CurrentlyReadFilesProvider();
});