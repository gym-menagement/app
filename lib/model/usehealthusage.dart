import 'package:common_control/common_control.dart';

enum UsehealthusageType {
  none(0, ''),
  entry(1, '입장'),
  pt(2, 'PT수업'),
  group(3, '그룹수업');

  const UsehealthusageType(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static UsehealthusageType fromCode(int code) {
    return UsehealthusageType.values.firstWhere(
      (e) => e.code == code,
      orElse: () => UsehealthusageType.none,
    );
  }
}

class Usehealthusage {
  int id;
  int gym;
  int usehealth;
  int membership;
  int user;
  int attendance;
  UsehealthusageType type;
  int usedcount;
  int remainingcount;
  String checkintime;
  String checkouttime;
  int duration;
  String note;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Usehealthusage({
    this.id = 0,
    this.gym = 0,
    this.usehealth = 0,
    this.membership = 0,
    this.user = 0,
    this.attendance = 0,
    this.type = UsehealthusageType.none,
    this.usedcount = 0,
    this.remainingcount = 0,
    this.checkintime = '',
    this.checkouttime = '',
    this.duration = 0,
    this.note = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Usehealthusage.fromJson(Map<String, dynamic> json) {
    return Usehealthusage(
      id: json['id'] as int,
      gym: json['gym'] as int,
      usehealth: json['usehealth'] as int,
      membership: json['membership'] as int,
      user: json['user'] as int,
      attendance: json['attendance'] as int,
      type: UsehealthusageType.fromCode(json['type'] as int),
      usedcount: json['usedcount'] as int,
      remainingcount: json['remainingcount'] as int,
      checkintime: json['checkintime'] as String,
      checkouttime: json['checkouttime'] as String,
      duration: json['duration'] as int,
      note: json['note'] as String,
      date: json['date'] as String,
      extra:
          json['extra'] == null
              ? <String, dynamic>{}
              : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gym': gym,
    'usehealth': usehealth,
    'membership': membership,
    'user': user,
    'attendance': attendance,
    'type': type.code,
    'usedcount': usedcount,
    'remainingcount': remainingcount,
    'checkintime': checkintime,
    'checkouttime': checkouttime,
    'duration': duration,
    'note': note,
    'date': date,
  };

  Usehealthusage clone() {
    return Usehealthusage.fromJson(toJson());
  }
}

class UsehealthusageManager {
  static const baseUrl = '/api/usehealthusage';

  static Future<List<Usehealthusage>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Usehealthusage>.empty(growable: true);
    }

    return result['items']
        .map<Usehealthusage>((json) => Usehealthusage.fromJson(json))
        .toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Usehealthusage> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Usehealthusage();
    }

    return Usehealthusage.fromJson(result['item']);
  }

  static Future<int> insert(Usehealthusage item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Usehealthusage item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Usehealthusage item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
