import 'package:bbb/models/exercise.dart';

class DayExercise {
  DayExercise({
    required this.id,
    required this.id_,
    required this.typeId,
    required this.name,
    required this.guide,
    required this.sets,
    required this.reps,
    required this.rest,
    required this.weight,
    required this.duration,
    required this.formats,
    required this.extra
  });

  String id;
  String id_;
  int typeId;
  String name;
  String guide;
  int sets;
  int reps;
  int rest;
  int weight;
  String duration;
  List<dynamic> formats = [];
  List<dynamic> extra = [];
  Exercise? execise;
}

class DayExerciseExtraSection {
  int? sets;
  int? reps;
  int? weight;
  int? rest;
  int? load;
  int? type;
  String? sId;
  String name;
  String guide;
  String duration;
  List<dynamic> formats = [];


  DayExerciseExtraSection(
      {
        required this.sets,
        required this.reps,
        required this.weight,
        required this.rest,
        required this.load,
        required this.type,
        required this.sId,
        required this.name,
        required this.guide,
        required this.duration,
        required this.formats,
      });

}


