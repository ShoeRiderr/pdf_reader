import 'dart:io';
import 'package:flutter/material.dart';

class DocListItem extends StatelessWidget {
  const DocListItem({super.key, required this.file});

  final FileSystemEntity file;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(file.uri.pathSegments.last),
      subtitle: Text(file.path),
      leading: Icon(Icons.insert_drive_file),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: ${file.uri.pathSegments.last}')),
        );
      },
    );
  }

}