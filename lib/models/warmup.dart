class WarmUp {
  WarmUp({
    required this.id,
    required this.thumbnail,
    required this.length,
    required this.files,
    required this.title,
    required this.vimeoId,
     this.description,
    required this.equipments,
  });

  String id;
  String title;
  String vimeoId;
  int length;
  String thumbnail;
  List<dynamic> files;
  String? description;
  List<dynamic> equipments = [];
}
