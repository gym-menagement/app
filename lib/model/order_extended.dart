import 'package:app/config/http.dart';
import 'package:app/model/order.dart';

/// 주문 상태 Enum
enum OrderStatus {
  pending(0, '대기중'),
  completed(1, '완료'),
  cancelled(2, '취소'),
  refunded(3, '환불');

  const OrderStatus(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static OrderStatus fromCode(int code) {
    return OrderStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => OrderStatus.pending,
    );
  }
}

/// 확장된 Order 모델
/// 자동 생성된 order.dart의 Order 클래스를 확장
class OrderExtended extends Order {
  int originalPrice;
  int discount;
  int finalPrice;
  OrderStatus status;
  String? paymentMethod;
  String? transactionId;
  String? receiptUrl;

  OrderExtended({
    super.id,
    super.user,
    super.gym,
    super.health,
    super.date,
    super.extra,
    super.checked,
    required this.originalPrice,
    required this.discount,
    required this.finalPrice,
    this.status = OrderStatus.pending,
    this.paymentMethod,
    this.transactionId,
    this.receiptUrl,
  });

  factory OrderExtended.fromJson(Map<String, dynamic> json) {
    return OrderExtended(
      id: json['id'] as int? ?? 0,
      user: json['user'] as int? ?? 0,
      gym: json['gym'] as int? ?? 0,
      health: json['health'] as int? ?? 0,
      date: json['date'] as String? ?? '',
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
      checked: json['checked'] as bool? ?? false,
      status: OrderStatus.fromCode(json['status'] as int? ?? 0),
      originalPrice: json['originalPrice'] as int? ?? 0,
      discount: json['discount'] as int? ?? 0,
      finalPrice: json['finalPrice'] as int? ?? 0,
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...super.toJson(),
    'status': status.code,
    'originalPrice': originalPrice,
    'discount': discount,
    'finalPrice': finalPrice,
    'paymentMethod': paymentMethod,
    'transactionId': transactionId,
    'receiptUrl': receiptUrl,
  };

  @override
  OrderExtended clone() {
    return OrderExtended.fromJson(toJson());
  }

  /// 취소 가능 여부
  bool get canCancel => status == OrderStatus.completed || status == OrderStatus.pending;

  /// 환불 가능 여부
  bool get canRefund => status == OrderStatus.completed;

  /// 상태 표시 색상
  String get statusColor {
    switch (status) {
      case OrderStatus.completed:
        return '#4CAF50'; // 초록색
      case OrderStatus.cancelled:
        return '#F44336'; // 빨간색
      case OrderStatus.refunded:
        return '#FF9800'; // 주황색
      case OrderStatus.pending:
        return '#9E9E9E'; // 회색
    }
  }
}

/// 확장된 OrderManager
class OrderExtendedManager {
  static const baseUrl = '/api/order';

  static Future<List<OrderExtended>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['content'] == null) {
      return List<OrderExtended>.empty(growable: true);
    }

    return result['content']
        .map<OrderExtended>((json) => OrderExtended.fromJson(json))
        .toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<OrderExtended?> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null) {
      return null;
    }

    return OrderExtended.fromJson(result);
  }

  static Future<int> insert(OrderExtended item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static Future<void> update(OrderExtended item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static Future<void> delete(OrderExtended item) async {
    await Http.delete(baseUrl, item.toJson());
  }

  /// 사용자별 주문 조회
  static Future<List<OrderExtended>> getUserOrders(int userId, {int page = 0, int pagesize = 20}) async {
    return find(page: page, pagesize: pagesize, params: 'user=$userId');
  }

  /// 체육관별 주문 조회
  static Future<List<OrderExtended>> getGymOrders(int gymId, {int page = 0, int pagesize = 20}) async {
    return find(page: page, pagesize: pagesize, params: 'gym=$gymId');
  }

  /// 상태별 주문 조회
  static Future<List<OrderExtended>> getOrdersByStatus(OrderStatus status, {int page = 0, int pagesize = 20}) async {
    return find(page: page, pagesize: pagesize, params: 'status=${status.code}');
  }
}
