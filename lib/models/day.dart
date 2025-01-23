class Day {
  Day({
    required this.id,
    required this.typeId,
    required this.title,
    required this.description,
    required this.vimeoId,
    required this.thumbnail,
    required this.formats,
    required this.warmups,
    required this.exercises,
  });

  String id;
  int typeId;
  String title;
  String description;
  String vimeoId;
  String? thumbnail;
  List<String> formats = [];
  List<dynamic> warmups = [];
  List<dynamic> exercises = [];
}
