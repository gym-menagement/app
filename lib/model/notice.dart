import 'package:common_control/common_control.dart';
import 'package:dreamcam/models/type.dart';
import 'package:dreamcam/models/ispopup.dart';
import 'package:dreamcam/models/ispush.dart';
import 'package:dreamcam/models/target.dart';
import 'package:dreamcam/models/status.dart';


class Notice {
  int id;
  int gym;
  String title;
  String content;
  Type type;
  Ispopup ispopup;
  Ispush ispush;
  Target target;
  int viewcount;
  String startdate;
  String enddate;
  Status status;
  int createdby;
  String createddate;
  String updateddate;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Notice({
    this.id = 0,
    this.gym = 0,
    this.title = '',
    this.content = '',
    this.type = Type(),
    this.ispopup = Ispopup(),
    this.ispush = Ispush(),
    this.target = Target(),
    this.viewcount = 0,
    this.startdate = '',
    this.enddate = '',
    this.status = Status(),
    this.createdby = 0,
    this.createddate = '',
    this.updateddate = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as int,
      gym: json['gym'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      type: Type.fromJson(json['type']),
      ispopup: Ispopup.fromJson(json['ispopup']),
      ispush: Ispush.fromJson(json['ispush']),
      target: Target.fromJson(json['target']),
      viewcount: json['viewcount'] as int,
      startdate: json['startdate'] as String,
      enddate: json['enddate'] as String,
      status: Status.fromJson(json['status']),
      createdby: json['createdby'] as int,
      createddate: json['createddate'] as String,
      updateddate: json['updateddate'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gym': gym,
    'title': title,
    'content': content,
    'type': type.toJson(),
    'ispopup': ispopup.toJson(),
    'ispush': ispush.toJson(),
    'target': target.toJson(),
    'viewcount': viewcount,
    'startdate': startdate,
    'enddate': enddate,
    'status': status.toJson(),
    'createdby': createdby,
    'createddate': createddate,
    'updateddate': updateddate,
    'date': date,
  };

  Notice clone() {
    return Notice.fromJson(toJson());
  }
}

class NoticeManager {
  static const baseUrl = '/api/notice';

  static Future<List<Notice>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Notice>.empty(growable: true);
    }

    return result['items'].map<Notice>((json) => Notice.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Notice> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Notice();
    }

    return Notice.fromJson(result['item']);
  }

  static Future<int> insert(Notice item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Notice item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Notice item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
