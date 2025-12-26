import 'package:app/config/http.dart';


enum AppversionForceupdate {
  none(0, ''),
  no(1, '아니오'),
  yes(2, '예'),
;

  const AppversionForceupdate(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static AppversionForceupdate fromCode(int code) {
    return AppversionForceupdate.values.firstWhere((e) => e.code == code, orElse: () => AppversionForceupdate.none);
  }
}

enum AppversionStatus {
  none(0, ''),
  inactive(1, '비활성'),
  active(2, '활성'),
;

  const AppversionStatus(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static AppversionStatus fromCode(int code) {
    return AppversionStatus.values.firstWhere((e) => e.code == code, orElse: () => AppversionStatus.none);
  }
}

class Appversion {
  int id;
  String platform;
  String version;
  String minversion;
  AppversionForceupdate forceupdate;
  String updatemessage;
  String downloadurl;
  AppversionStatus status;
  String releasedate;
  String createddate;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Appversion({
    this.id = 0,
    this.platform = '',
    this.version = '',
    this.minversion = '',
    this.forceupdate = AppversionForceupdate.none,
    this.updatemessage = '',
    this.downloadurl = '',
    this.status = AppversionStatus.none,
    this.releasedate = '',
    this.createddate = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Appversion.fromJson(Map<String, dynamic> json) {
    return Appversion(
      id: json['id'] as int,
      platform: json['platform'] as String,
      version: json['version'] as String,
      minversion: json['minversion'] as String,
      forceupdate: AppversionForceupdate.fromCode(json['forceupdate'] as int),
      updatemessage: json['updatemessage'] as String,
      downloadurl: json['downloadurl'] as String,
      status: AppversionStatus.fromCode(json['status'] as int),
      releasedate: json['releasedate'] as String,
      createddate: json['createddate'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'platform': platform,
    'version': version,
    'minversion': minversion,
    'forceupdate': forceupdate.code,
    'updatemessage': updatemessage,
    'downloadurl': downloadurl,
    'status': status.code,
    'releasedate': releasedate,
    'createddate': createddate,
    'date': date,
  };

  Appversion clone() {
    return Appversion.fromJson(toJson());
  }
}

class AppversionManager {
  static const baseUrl = '/api/appversion';

  static Future<List<Appversion>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Appversion>.empty(growable: true);
    }

    return result['items'].map<Appversion>((json) => Appversion.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Appversion> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Appversion();
    }

    return Appversion.fromJson(result['item']);
  }

  static Future<int> insert(Appversion item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Appversion item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Appversion item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
