import 'package:app/config/http.dart';


class Paymentform {
  int id;
  int gym;
  int payment;
  int type;
  int cost;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Paymentform({
    this.id = 0,
    this.gym = 0,
    this.payment = 0,
    this.type = 0,
    this.cost = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Paymentform.fromJson(Map<String, dynamic> json) {
    return Paymentform(
      id: json['id'] as int,
      gym: json['gym'] as int,
      payment: json['payment'] as int,
      type: json['type'] as int,
      cost: json['cost'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gym': gym,
    'payment': payment,
    'type': type,
    'cost': cost,
    'date': date,
  };

  Paymentform clone() {
    return Paymentform.fromJson(toJson());
  }
}

class PaymentformManager {
  static const baseUrl = '/api/paymentform';

  static Future<List<Paymentform>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['content'] == null) {
      return List<Paymentform>.empty(growable: true);
    }

    return result['content'].map<Paymentform>((json) => Paymentform.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Paymentform> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Paymentform();
    }

    return Paymentform.fromJson(result);
  }

  static Future<int> insert(Paymentform item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Paymentform item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Paymentform item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
