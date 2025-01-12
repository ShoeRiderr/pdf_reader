import 'dart:io';
import 'package:flutter/material.dart';

class DocListItem extends StatelessWidget {
  const DocListItem({super.key, required this.file, required this.onSelectDoc});

  final FileSystemEntity file;
  final void Function() onSelectDoc;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(file.uri.pathSegments.last),
      subtitle: Text(file.path),
      leading: Icon(Icons.insert_drive_file),
      onTap: onSelectDoc,
    );
  }

}