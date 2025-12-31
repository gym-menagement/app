import 'package:app/config/http.dart';


class Discount {
  int id;
  int gym;
  String name;
  int discount;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Discount({
    this.id = 0,
    this.gym = 0,
    this.name = '',
    this.discount = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['id'] as int,
      gym: json['gym'] as int,
      name: json['name'] as String,
      discount: json['discount'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gym': gym,
    'name': name,
    'discount': discount,
    'date': date,
  };

  Discount clone() {
    return Discount.fromJson(toJson());
  }
}

class DiscountManager {
  static const baseUrl = '/api/discount';

  static Future<List<Discount>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['content'] == null) {
      return List<Discount>.empty(growable: true);
    }

    return result['content'].map<Discount>((json) => Discount.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Discount> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Discount();
    }

    return Discount.fromJson(result);
  }

  static Future<int> insert(Discount item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Discount item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Discount item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
