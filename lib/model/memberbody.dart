import 'package:app/config/http.dart';


class Memberbody {
  int id;
  int gym;
  int user;
  int height;
  int weight;
  int bodyfat;
  int musclemass;
  int bmi;
  int skeletalmuscle;
  int bodywater;
  int chest;
  int waist;
  int hip;
  int arm;
  int thigh;
  String note;
  String measureddate;
  int measuredby;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Memberbody({
    this.id = 0,
    this.gym = 0,
    this.user = 0,
    this.height = 0,
    this.weight = 0,
    this.bodyfat = 0,
    this.musclemass = 0,
    this.bmi = 0,
    this.skeletalmuscle = 0,
    this.bodywater = 0,
    this.chest = 0,
    this.waist = 0,
    this.hip = 0,
    this.arm = 0,
    this.thigh = 0,
    this.note = '',
    this.measureddate = '',
    this.measuredby = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Memberbody.fromJson(Map<String, dynamic> json) {
    return Memberbody(
      id: json['id'] as int,
      gym: json['gym'] as int,
      user: json['user'] as int,
      height: json['height'] as int,
      weight: json['weight'] as int,
      bodyfat: json['bodyfat'] as int,
      musclemass: json['musclemass'] as int,
      bmi: json['bmi'] as int,
      skeletalmuscle: json['skeletalmuscle'] as int,
      bodywater: json['bodywater'] as int,
      chest: json['chest'] as int,
      waist: json['waist'] as int,
      hip: json['hip'] as int,
      arm: json['arm'] as int,
      thigh: json['thigh'] as int,
      note: json['note'] as String,
      measureddate: json['measureddate'] as String,
      measuredby: json['measuredby'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gym': gym,
    'user': user,
    'height': height,
    'weight': weight,
    'bodyfat': bodyfat,
    'musclemass': musclemass,
    'bmi': bmi,
    'skeletalmuscle': skeletalmuscle,
    'bodywater': bodywater,
    'chest': chest,
    'waist': waist,
    'hip': hip,
    'arm': arm,
    'thigh': thigh,
    'note': note,
    'measureddate': measureddate,
    'measuredby': measuredby,
    'date': date,
  };

  Memberbody clone() {
    return Memberbody.fromJson(toJson());
  }
}

class MemberbodyManager {
  static const baseUrl = '/api/memberbody';

  static Future<List<Memberbody>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['content'] == null) {
      return List<Memberbody>.empty(growable: true);
    }

    return result['content'].map<Memberbody>((json) => Memberbody.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Memberbody> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Memberbody();
    }

    return Memberbody.fromJson(result);
  }

  static Future<int> insert(Memberbody item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Memberbody item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Memberbody item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
