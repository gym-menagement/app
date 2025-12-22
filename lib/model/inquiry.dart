import 'package:common_control/common_control.dart';


enum InquiryType {
  none(0, ''),
  general(1, '일반'),
  membership(2, '회원권'),
  refund(3, '환불'),
  facility(4, '시설'),
  other(5, '기타'),
;

  const InquiryType(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static InquiryType fromCode(int code) {
    return InquiryType.values.firstWhere((e) => e.code == code, orElse: () => InquiryType.none);
  }
}

enum InquiryStatus {
  none(0, ''),
  waiting(1, '대기'),
  answered(2, '답변완료'),
;

  const InquiryStatus(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static InquiryStatus fromCode(int code) {
    return InquiryStatus.values.firstWhere((e) => e.code == code, orElse: () => InquiryStatus.none);
  }
}

class Inquiry {
  int id;
  int user;
  int gym;
  InquiryType type;
  String title;
  String content;
  InquiryStatus status;
  String answer;
  int answeredby;
  String answereddate;
  String createddate;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Inquiry({
    this.id = 0,
    this.user = 0,
    this.gym = 0,
    this.type = InquiryType.none,
    this.title = '',
    this.content = '',
    this.status = InquiryStatus.none,
    this.answer = '',
    this.answeredby = 0,
    this.answereddate = '',
    this.createddate = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Inquiry.fromJson(Map<String, dynamic> json) {
    return Inquiry(
      id: json['id'] as int,
      user: json['user'] as int,
      gym: json['gym'] as int,
      type: InquiryType.fromCode(json['type'] as int),
      title: json['title'] as String,
      content: json['content'] as String,
      status: InquiryStatus.fromCode(json['status'] as int),
      answer: json['answer'] as String,
      answeredby: json['answeredby'] as int,
      answereddate: json['answereddate'] as String,
      createddate: json['createddate'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'gym': gym,
    'type': type.code,
    'title': title,
    'content': content,
    'status': status.code,
    'answer': answer,
    'answeredby': answeredby,
    'answereddate': answereddate,
    'createddate': createddate,
    'date': date,
  };

  Inquiry clone() {
    return Inquiry.fromJson(toJson());
  }
}

class InquiryManager {
  static const baseUrl = '/api/inquiry';

  static Future<List<Inquiry>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Inquiry>.empty(growable: true);
    }

    return result['items'].map<Inquiry>((json) => Inquiry.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Inquiry> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Inquiry();
    }

    return Inquiry.fromJson(result['item']);
  }

  static Future<int> insert(Inquiry item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Inquiry item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Inquiry item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
