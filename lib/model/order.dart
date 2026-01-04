import 'package:app/config/http.dart';

/// 결제 상태
enum OrderStatus {
  none(0, ''),
  pending(1, '대기'),
  completed(2, '완료'),
  cancelled(3, '취소'),
  refunded(4, '환불'),
;

  const OrderStatus(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static OrderStatus fromCode(int code) {
    return OrderStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => OrderStatus.none,
    );
  }
}

/// 결제 수단
enum PaymentMethod {
  none(0, ''),
  card(1, '신용카드'),
  kakao(2, '카카오페이'),
  naver(3, '네이버페이'),
  toss(4, '토스'),
  bank(5, '계좌이체'),
;

  const PaymentMethod(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static PaymentMethod fromCode(int code) {
    return PaymentMethod.values.firstWhere(
      (e) => e.code == code,
      orElse: () => PaymentMethod.none,
    );
  }
}

class Order {
  int id;
  int user;
  int gym;
  int health;
  String date;
  int originalPrice; // 정상가
  int discount; // 할인 금액
  int finalPrice; // 최종 결제 금액
  OrderStatus status; // 결제 상태
  PaymentMethod paymentMethod; // 결제 수단
  String? receiptUrl; // 영수증 URL
  bool checked;
  Map<String, dynamic> extra;

  Order({
    this.id = 0,
    this.user = 0,
    this.gym = 0,
    this.health = 0,
    this.date = '',
    this.originalPrice = 0,
    this.discount = 0,
    this.finalPrice = 0,
    this.status = OrderStatus.none,
    this.paymentMethod = PaymentMethod.none,
    this.receiptUrl,
    this.extra = const {},
    this.checked = false,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      user: json['user'] as int,
      gym: json['gym'] as int,
      health: json['health'] as int,
      date: json['date'] as String,
      originalPrice: json['original_price'] as int? ?? 0,
      discount: json['discount'] as int? ?? 0,
      finalPrice: json['final_price'] as int? ?? 0,
      status: OrderStatus.fromCode(json['status'] as int? ?? 0),
      paymentMethod: PaymentMethod.fromCode(json['payment_method'] as int? ?? 0),
      receiptUrl: json['receipt_url'] as String?,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'gym': gym,
    'health': health,
    'date': date,
    'original_price': originalPrice,
    'discount': discount,
    'final_price': finalPrice,
    'status': status.code,
    'payment_method': paymentMethod.code,
    'receipt_url': receiptUrl,
  };

  Order clone() {
    return Order.fromJson(toJson());
  }
}

class OrderManager {
  static const baseUrl = '/api/order';

  static Future<List<Order>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['content'] == null) {
      return List<Order>.empty(growable: true);
    }

    return result['content'].map<Order>((json) => Order.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Order> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Order();
    }

    return Order.fromJson(result);
  }

  static Future<int> insert(Order item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Order item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Order item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
