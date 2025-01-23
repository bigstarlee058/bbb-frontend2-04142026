import 'package:bbb/models/warmup.dart';

class DayWarmup {
  DayWarmup({
    required this.id,
    required this.typeId,
    required this.name,
    required this.guide,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.duration,
    required this.formats,
     this.warmupId,

  });

  String id;
  int typeId;
  String name;
  String guide;
  int sets;
  int reps;
  String weight;
  String duration;
  List<dynamic> formats = [];
  WarmUp? warmup;
  String ? warmupId;
}
