class RestDay {
  RestDay({
    required this.id,
    required this.title,
    required this.description,
    required this.vimeoId,
    required this.equipments,
  });

  String id;
  String title;
  String description;
  String vimeoId;
  List<dynamic> equipments = [];
}
