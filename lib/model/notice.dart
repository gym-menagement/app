import 'package:app/config/http.dart';


enum NoticeType {
  none(0, ''),
  general(1, '일반'),
  important(2, '중요'),
  event(3, '이벤트'),
;

  const NoticeType(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NoticeType fromCode(int code) {
    return NoticeType.values.firstWhere((e) => e.code == code, orElse: () => NoticeType.none);
  }
}

enum NoticeIspopup {
  none(0, ''),
  no(1, '아니오'),
  yes(2, '예'),
;

  const NoticeIspopup(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NoticeIspopup fromCode(int code) {
    return NoticeIspopup.values.firstWhere((e) => e.code == code, orElse: () => NoticeIspopup.none);
  }
}

enum NoticeIspush {
  none(0, ''),
  no(1, '아니오'),
  yes(2, '예'),
;

  const NoticeIspush(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NoticeIspush fromCode(int code) {
    return NoticeIspush.values.firstWhere((e) => e.code == code, orElse: () => NoticeIspush.none);
  }
}

enum NoticeTarget {
  none(0, ''),
  all(1, '전체'),
  members_only(2, '회원만'),
  specific_members(3, '특정회원'),
;

  const NoticeTarget(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NoticeTarget fromCode(int code) {
    return NoticeTarget.values.firstWhere((e) => e.code == code, orElse: () => NoticeTarget.none);
  }
}

enum NoticeStatus {
  none(0, ''),
  private(1, '비공개'),
  public(2, '공개'),
;

  const NoticeStatus(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NoticeStatus fromCode(int code) {
    return NoticeStatus.values.firstWhere((e) => e.code == code, orElse: () => NoticeStatus.none);
  }
}

class Notice {
  int id;
  int gym;
  String title;
  String content;
  NoticeType type;
  NoticeIspopup ispopup;
  NoticeIspush ispush;
  NoticeTarget target;
  int viewcount;
  String startdate;
  String enddate;
  NoticeStatus status;
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
    this.type = NoticeType.none,
    this.ispopup = NoticeIspopup.none,
    this.ispush = NoticeIspush.none,
    this.target = NoticeTarget.none,
    this.viewcount = 0,
    this.startdate = '',
    this.enddate = '',
    this.status = NoticeStatus.none,
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
      type: NoticeType.fromCode(json['type'] as int),
      ispopup: NoticeIspopup.fromCode(json['ispopup'] as int),
      ispush: NoticeIspush.fromCode(json['ispush'] as int),
      target: NoticeTarget.fromCode(json['target'] as int),
      viewcount: json['viewcount'] as int,
      startdate: json['startdate'] as String,
      enddate: json['enddate'] as String,
      status: NoticeStatus.fromCode(json['status'] as int),
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
    'type': type.code,
    'ispopup': ispopup.code,
    'ispush': ispush.code,
    'target': target.code,
    'viewcount': viewcount,
    'startdate': startdate,
    'enddate': enddate,
    'status': status.code,
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
    if (result == null || result['content'] == null) {
      return List<Notice>.empty(growable: true);
    }

    return result['content'].map<Notice>((json) => Notice.fromJson(json)).toList();
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

    return Notice.fromJson(result);
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
