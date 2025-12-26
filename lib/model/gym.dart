import 'package:app/config/http.dart';


class Gym {
  int id;
  String name;
  String address;
  String tel;
  int user;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Gym({
    this.id = 0,
    this.name = '',
    this.address = '',
    this.tel = '',
    this.user = 0,
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Gym.fromJson(Map<String, dynamic> json) {
    return Gym(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      tel: json['tel'] as String,
      user: json['user'] as int,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'address': address,
    'tel': tel,
    'user': user,
    'date': date,
  };

  Gym clone() {
    return Gym.fromJson(toJson());
  }
}

class GymManager {
  static const baseUrl = '/api/gym';

  static Future<List<Gym>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Gym>.empty(growable: true);
    }

    return result['items'].map<Gym>((json) => Gym.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Gym> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Gym();
    }

    return Gym.fromJson(result['item']);
  }

  static Future<int> insert(Gym item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Gym item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Gym item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
