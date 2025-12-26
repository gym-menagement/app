import 'package:app/config/http.dart';


enum GymtrainerStatus {
  none(0, ''),
  terminated(1, '종료'),
  in_progress(2, '진행중'),
;

  const GymtrainerStatus(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static GymtrainerStatus fromCode(int code) {
    return GymtrainerStatus.values.firstWhere((e) => e.code == code, orElse: () => GymtrainerStatus.none);
  }
}

class Gymtrainer {
  int id;
  int gym;
  int trainer;
  String startdate;
  String enddate;
  GymtrainerStatus status;
  String position;
  String note;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Gymtrainer({
    this.id = 0,
    this.gym = 0,
    this.trainer = 0,
    this.startdate = '',
    this.enddate = '',
    this.status = GymtrainerStatus.none,
    this.position = '',
    this.note = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Gymtrainer.fromJson(Map<String, dynamic> json) {
    return Gymtrainer(
      id: json['id'] as int,
      gym: json['gym'] as int,
      trainer: json['trainer'] as int,
      startdate: json['startdate'] as String,
      enddate: json['enddate'] as String,
      status: GymtrainerStatus.fromCode(json['status'] as int),
      position: json['position'] as String,
      note: json['note'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gym': gym,
    'trainer': trainer,
    'startdate': startdate,
    'enddate': enddate,
    'status': status.code,
    'position': position,
    'note': note,
    'date': date,
  };

  Gymtrainer clone() {
    return Gymtrainer.fromJson(toJson());
  }
}

class GymtrainerManager {
  static const baseUrl = '/api/gymtrainer';

  static Future<List<Gymtrainer>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Gymtrainer>.empty(growable: true);
    }

    return result['items'].map<Gymtrainer>((json) => Gymtrainer.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Gymtrainer> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Gymtrainer();
    }

    return Gymtrainer.fromJson(result['item']);
  }

  static Future<int> insert(Gymtrainer item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Gymtrainer item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Gymtrainer item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
