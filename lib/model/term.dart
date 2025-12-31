import 'package:app/config/http.dart';


class Term {
  int id;
  int gym;
  int daytype;
  String name;
  int term;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Term({
    this.id = 0,
    this.gym = 0,
    this.daytype = 0,
    this.name = '',
    this.term = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      id: json['id'] as int,
      gym: json['gym'] as int,
      daytype: json['daytype'] as int,
      name: json['name'] as String,
      term: json['term'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gym': gym,
    'daytype': daytype,
    'name': name,
    'term': term,
    'date': date,
  };

  Term clone() {
    return Term.fromJson(toJson());
  }
}

class TermManager {
  static const baseUrl = '/api/term';

  static Future<List<Term>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['content'] == null) {
      return List<Term>.empty(growable: true);
    }

    return result['content'].map<Term>((json) => Term.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Term> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Term();
    }

    return Term.fromJson(result);
  }

  static Future<int> insert(Term item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Term item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Term item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
