import 'package:app/config/http.dart';


enum TrainermemberStatus {
  none(0, ''),
  terminated(1, '종료'),
  in_progress(2, '진행중'),
;

  const TrainermemberStatus(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static TrainermemberStatus fromCode(int code) {
    return TrainermemberStatus.values.firstWhere((e) => e.code == code, orElse: () => TrainermemberStatus.none);
  }
}

class Trainermember {
  int id;
  int trainer;
  int member;
  int gym;
  String startdate;
  String enddate;
  TrainermemberStatus status;
  String note;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Trainermember({
    this.id = 0,
    this.trainer = 0,
    this.member = 0,
    this.gym = 0,
    this.startdate = '',
    this.enddate = '',
    this.status = TrainermemberStatus.none,
    this.note = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Trainermember.fromJson(Map<String, dynamic> json) {
    return Trainermember(
      id: json['id'] as int,
      trainer: json['trainer'] as int,
      member: json['member'] as int,
      gym: json['gym'] as int,
      startdate: json['startdate'] as String,
      enddate: json['enddate'] as String,
      status: TrainermemberStatus.fromCode(json['status'] as int),
      note: json['note'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trainer': trainer,
    'member': member,
    'gym': gym,
    'startdate': startdate,
    'enddate': enddate,
    'status': status.code,
    'note': note,
    'date': date,
  };

  Trainermember clone() {
    return Trainermember.fromJson(toJson());
  }
}

class TrainermemberManager {
  static const baseUrl = '/api/trainermember';

  static Future<List<Trainermember>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['content'] == null) {
      return List<Trainermember>.empty(growable: true);
    }

    return result['content'].map<Trainermember>((json) => Trainermember.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Trainermember> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Trainermember();
    }

    return Trainermember.fromJson(result);
  }

  static Future<int> insert(Trainermember item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Trainermember item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Trainermember item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
