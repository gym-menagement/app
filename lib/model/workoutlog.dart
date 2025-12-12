import 'package:common_control/common_control.dart';


class Workoutlog {
  int id;
  int gym;
  int user;
  int attendance;
  int health;
  String exercisename;
  int sets;
  int reps;
  int weight;
  int duration;
  int calories;
  String note;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Workoutlog({
    this.id = 0,
    this.gym = 0,
    this.user = 0,
    this.attendance = 0,
    this.health = 0,
    this.exercisename = '',
    this.sets = 0,
    this.reps = 0,
    this.weight = 0,
    this.duration = 0,
    this.calories = 0,
    this.note = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Workoutlog.fromJson(Map<String, dynamic> json) {
    return Workoutlog(
      id: json['id'] as int,
      gym: json['gym'] as int,
      user: json['user'] as int,
      attendance: json['attendance'] as int,
      health: json['health'] as int,
      exercisename: json['exercisename'] as String,
      sets: json['sets'] as int,
      reps: json['reps'] as int,
      weight: json['weight'] as int,
      duration: json['duration'] as int,
      calories: json['calories'] as int,
      note: json['note'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gym': gym,
    'user': user,
    'attendance': attendance,
    'health': health,
    'exercisename': exercisename,
    'sets': sets,
    'reps': reps,
    'weight': weight,
    'duration': duration,
    'calories': calories,
    'note': note,
    'date': date,
  };

  Workoutlog clone() {
    return Workoutlog.fromJson(toJson());
  }
}

class WorkoutlogManager {
  static const baseUrl = '/api/workoutlog';

  static Future<List<Workoutlog>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Workoutlog>.empty(growable: true);
    }

    return result['items'].map<Workoutlog>((json) => Workoutlog.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Workoutlog> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Workoutlog();
    }

    return Workoutlog.fromJson(result['item']);
  }

  static Future<int> insert(Workoutlog item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Workoutlog item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Workoutlog item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
