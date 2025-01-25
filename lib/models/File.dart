class FileModel {
  const FileModel({
    required this.name,
    required this.path,
    this.sentenceIndex = 0,
    this.page = 0,
  });

  final String name;
  final String path;
  final int sentenceIndex;
  final int page;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'path': path,
      'sentenceIndex': sentenceIndex,
      'page': page,
    };
  }
}