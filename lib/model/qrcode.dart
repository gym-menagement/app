import 'package:app/config/http.dart';


enum QrcodeIsactive {
  none(0, ''),
  inactive(1, '비활성'),
  active(2, '활성'),
;

  const QrcodeIsactive(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static QrcodeIsactive fromCode(int code) {
    return QrcodeIsactive.values.firstWhere((e) => e.code == code, orElse: () => QrcodeIsactive.none);
  }
}

class Qrcode {
  int id;
  int user;
  String code;
  String imageurl;
  QrcodeIsactive isactive;
  String expiredate;
  String generateddate;
  String lastuseddate;
  int usecount;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Qrcode({
    this.id = 0,
    this.user = 0,
    this.code = '',
    this.imageurl = '',
    this.isactive = QrcodeIsactive.none,
    this.expiredate = '',
    this.generateddate = '',
    this.lastuseddate = '',
    this.usecount = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Qrcode.fromJson(Map<String, dynamic> json) {
    return Qrcode(
      id: json['id'] as int,
      user: json['user'] as int,
      code: json['code'] as String,
      imageurl: json['imageurl'] as String,
      isactive: QrcodeIsactive.fromCode(json['isactive'] as int),
      expiredate: json['expiredate'] as String,
      generateddate: json['generateddate'] as String,
      lastuseddate: json['lastuseddate'] as String,
      usecount: json['usecount'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'code': code,
    'imageurl': imageurl,
    'isactive': isactive.code,
    'expiredate': expiredate,
    'generateddate': generateddate,
    'lastuseddate': lastuseddate,
    'usecount': usecount,
    'date': date,
  };

  Qrcode clone() {
    return Qrcode.fromJson(toJson());
  }
}

class QrcodeManager {
  static const baseUrl = '/api/qrcode';

  static Future<List<Qrcode>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Qrcode>.empty(growable: true);
    }

    return result['items'].map<Qrcode>((json) => Qrcode.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Qrcode> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Qrcode();
    }

    return Qrcode.fromJson(result['item']);
  }

  static Future<int> insert(Qrcode item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Qrcode item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Qrcode item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
