class FileModel {
  const FileModel({
    required this.path,
    required this.yCoor,
    required this.xCoor,
    required this.page,
  });

  final String path;
  final int yCoor; // last Y coordinates
  final int xCoor; // last X coordinates
  final int page;

}