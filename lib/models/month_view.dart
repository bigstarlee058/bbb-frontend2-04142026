class MonthViewModule {
  String? sId;
  int? index;
  String? title;
  String? description;
  String? vimeoId;
  dynamic? thumbnail;
  String? startDate;
  String? endDate;
  List<Weeks>? weeks;
  int? iV;

  MonthViewModule(
      {this.sId,
      this.index,
      this.title,
      this.description,
      this.vimeoId,
      this.thumbnail,
      this.startDate,
      this.endDate,
      this.weeks,
      this.iV});

  MonthViewModule.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    index = json['index'];
    title = json['title'];
    description = json['description'];
    vimeoId = json['vimeoId'];
    thumbnail = json['thumbnail'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    if (json['weeks'] != null) {
      weeks = <Weeks>[];
      json['weeks'].forEach((v) {
        weeks!.add(new Weeks.fromJson(v));
      });
    }
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['index'] = this.index;
    data['title'] = this.title;
    data['description'] = this.description;
    data['vimeoId'] = this.vimeoId;
    data['thumbnail'] = this.thumbnail;
    data['startDate'] = this.startDate;
    data['endDate'] = this.endDate;
    if (this.weeks != null) {
      data['weeks'] = this.weeks!.map((v) => v.toJson()).toList();
    }
    data['__v'] = this.iV;
    return data;
  }
}

class Weeks {
  int? index;
  String? title;
  String? description;
  String? vimeoId;
  String? thumbnail;
  String? restdayId;
  List<Days>? days;
  List<String>? pumpDayIds;
  String? sId;

  Weeks(
      {this.index,
      this.title,
      this.description,
      this.vimeoId,
      this.thumbnail,
      this.restdayId,
      this.pumpDayIds,
      this.days,
      this.sId});

  Weeks.fromJson(Map<String, dynamic> json) {
    index = json['index'];
    title = json['title'];
    description = json['description'];
    vimeoId = json['vimeoId'];
    thumbnail = json['thumbnail'];
    restdayId = json['restdayId'];
    pumpDayIds = json['pumpDayIds'];
    if (json['days'] != null) {
      days = <Days>[];
      json['days'].forEach((v) {
        days!.add(new Days.fromJson(v));
      });
    }
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['index'] = this.index;
    data['title'] = this.title;
    data['description'] = this.description;
    data['vimeoId'] = this.vimeoId;
    data['thumbnail'] = this.thumbnail;
    data['restdayId'] = this.restdayId;
    data['pumpDayIds'] = this.pumpDayIds;
    if (this.days != null) {
      data['days'] = this.days!.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.sId;
    return data;
  }
}

class Days {
  int? typeId;
  String? title;
  String? description;
  String? vimeoId;
  dynamic? thumbnail;
  List<String>? formats;
  List<Warmups>? warmups;
  List<Exercises>? exercises;
  String? sId;

  Days(
      {this.typeId,
      this.title,
      this.description,
      this.vimeoId,
      this.thumbnail,
      this.formats,
      this.warmups,
      this.exercises,
      this.sId});

  Days.fromJson(Map<String, dynamic> json) {
    typeId = json['typeId'];
    title = json['title'];
    description = json['description'];
    vimeoId = json['vimeoId'];
    thumbnail = json['thumbnail'];
    formats = json['formats'].cast<String>();
    if (json['warmups'] != null) {
      warmups = <Warmups>[];
      json['warmups'].forEach((v) {
        warmups!.add(new Warmups.fromJson(v));
      });
    }
    if (json['exercises'] != null) {
      exercises = <Exercises>[];
      json['exercises'].forEach((v) {
        exercises!.add(new Exercises.fromJson(v));
      });
    }
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['typeId'] = this.typeId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['vimeoId'] = this.vimeoId;
    data['thumbnail'] = this.thumbnail;
    data['formats'] = this.formats;
    if (this.warmups != null) {
      data['warmups'] = this.warmups!.map((v) => v.toJson()).toList();
    }
    if (this.exercises != null) {
      data['exercises'] = this.exercises!.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.sId;
    return data;
  }
}

class Warmups {
  int? typeId;
  String? warmupId;
  String? title;
  String? guide;
  List<String>? formats;
  String? sId;

  Warmups({this.typeId, this.warmupId, this.title, this.guide, this.formats, this.sId});

  Warmups.fromJson(Map<String, dynamic> json) {
    typeId = json['typeId'];
    warmupId = json['warmupId'];
    title = json['title'];
    guide = json['guide'];
    formats = json['formats'].cast<String>();
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['typeId'] = this.typeId;
    data['warmupId'] = this.warmupId;
    data['title'] = this.title;
    data['guide'] = this.guide;
    data['formats'] = this.formats;
    data['_id'] = this.sId;
    return data;
  }
}

class Exercises {
  int? typeId;
  String? exerciseId;
  String? name;
  String? guide;
  int? sets;
  int? reps;
  int? weight;
  int? rest;
  List<String>? formats;
  String? sId;

  Exercises(
      {this.typeId,
      this.exerciseId,
      this.name,
      this.guide,
      this.sets,
      this.reps,
      this.weight,
      this.rest,
      this.formats,
      this.sId});

  Exercises.fromJson(Map<String, dynamic> json) {
    typeId = json['typeId'];
    exerciseId = json['exerciseId'];
    name = json['name'];
    guide = json['guide'];
    sets = json['sets'];
    reps = json['reps'];
    weight = json['weight'];
    rest = json['rest'];
    formats = json['formats'].cast<String>();
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['typeId'] = this.typeId;
    data['exerciseId'] = this.exerciseId;
    data['name'] = this.name;
    data['guide'] = this.guide;
    data['sets'] = this.sets;
    data['reps'] = this.reps;
    data['weight'] = this.weight;
    data['rest'] = this.rest;
    data['formats'] = this.formats;
    data['_id'] = this.sId;
    return data;
  }
}
