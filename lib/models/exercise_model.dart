class Exercise {
  Exercise({
    required this.id,
    required this.title,
    required this.vimeoId,
    required this.thumbnail,
    required this.description,
    required this.guide,
    required this.relatedExercises,
    required this.categories,
    required this.usedEquipments,
    required this.files,
  });

  String id;
  String title;
  String vimeoId;
  String thumbnail;
  String description;
  String guide;
  List<dynamic> relatedExercises = [];
  List<dynamic> categories = [];
  List<dynamic> usedEquipments = [];
  List<dynamic> files = [];
}
