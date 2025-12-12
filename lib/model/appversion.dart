import 'package:common_control/common_control.dart';
import 'package:dreamcam/models/forceupdate.dart';
import 'package:dreamcam/models/status.dart';


class Appversion {
  int id;
  String platform;
  String version;
  String minversion;
  Forceupdate forceupdate;
  String updatemessage;
  String downloadurl;
  Status status;
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
    this.forceupdate = Forceupdate(),
    this.updatemessage = '',
    this.downloadurl = '',
    this.status = Status(),
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
      forceupdate: Forceupdate.fromJson(json['forceupdate']),
      updatemessage: json['updatemessage'] as String,
      downloadurl: json['downloadurl'] as String,
      status: Status.fromJson(json['status']),
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
    'forceupdate': forceupdate.toJson(),
    'updatemessage': updatemessage,
    'downloadurl': downloadurl,
    'status': status.toJson(),
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
