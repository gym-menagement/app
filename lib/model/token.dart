import 'package:common_control/common_control.dart';
import 'package:dreamcam/models/status.dart';


class Token {
  int id;
  int user;
  String token;
  Status status;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Token({
    this.id = 0,
    this.user = 0,
    this.token = '',
    this.status = Status(),
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      id: json['id'] as int,
      user: json['user'] as int,
      token: json['token'] as String,
      status: Status.fromJson(json['status']),
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'token': token,
    'status': status.toJson(),
    'date': date,
  };

  Token clone() {
    return Token.fromJson(toJson());
  }
}

class TokenManager {
  static const baseUrl = '/api/token';

  static Future<List<Token>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Token>.empty(growable: true);
    }

    return result['items'].map<Token>((json) => Token.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Token> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Token();
    }

    return Token.fromJson(result['item']);
  }

  static Future<int> insert(Token item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Token item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Token item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
