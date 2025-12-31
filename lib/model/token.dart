import 'package:app/config/http.dart';


enum TokenStatus {
  none(0, ''),
  active(1, '활성'),
  expired(2, '만료'),
  revoked(3, '폐기'),
;

  const TokenStatus(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static TokenStatus fromCode(int code) {
    return TokenStatus.values.firstWhere((e) => e.code == code, orElse: () => TokenStatus.none);
  }
}

class Token {
  int id;
  int user;
  String token;
  TokenStatus status;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Token({
    this.id = 0,
    this.user = 0,
    this.token = '',
    this.status = TokenStatus.none,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      id: json['id'] as int,
      user: json['user'] as int,
      token: json['token'] as String,
      status: TokenStatus.fromCode(json['status'] as int),
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'token': token,
    'status': status.code,
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
    if (result == null || result['content'] == null) {
      return List<Token>.empty(growable: true);
    }

    return result['content'].map<Token>((json) => Token.fromJson(json)).toList();
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

    return Token.fromJson(result);
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
