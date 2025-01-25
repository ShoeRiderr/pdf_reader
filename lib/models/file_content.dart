class FileContentModel {
  const FileContentModel({required this.path, required this.content});

  final String path;
  final String content;

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'content': content,
    };
  }
}