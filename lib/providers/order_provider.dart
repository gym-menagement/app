import 'package:flutter/material.dart';
import '../model/order_extended.dart';

/// 결제 내역 Provider
class OrderProvider extends ChangeNotifier {
  List<OrderExtended> _orders = [];
  bool _isLoading = false;
  int _currentPage = 0;
  bool _hasMore = true;

  List<OrderExtended> get orders => _orders;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  /// 결제 내역 로드
  Future<void> loadOrders({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 0;
      _hasMore = true;
      _orders.clear();
    }

    _isLoading = true;
    notifyListeners();

    try {
      final newOrders = await OrderExtendedManager.find(
        page: _currentPage,
        pagesize: 20,
      );

      if (newOrders.isEmpty) {
        _hasMore = false;
      } else {
        if (refresh) {
          _orders = newOrders;
        } else {
          _orders.addAll(newOrders);
        }
        _currentPage++;
      }
    } catch (e) {
      debugPrint('결제 내역 로드 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadOrders(refresh: true);
  }

  /// 다음 페이지 로드
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    await loadOrders();
  }

  /// 특정 주문 조회
  Future<OrderExtended?> getOrder(int orderId) async {
    try {
      return await OrderExtendedManager.get(orderId);
    } catch (e) {
      debugPrint('주문 조회 실패: $e');
      return null;
    }
  }

  /// 주문 취소 요청
  Future<bool> cancelOrder(int orderId) async {
    try {
      final order = _orders.firstWhere((o) => o.id == orderId);
      order.status = OrderStatus.cancelled;
      await OrderExtendedManager.update(order);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('주문 취소 실패: $e');
      return false;
    }
  }

  /// 환불 요청
  Future<bool> requestRefund(int orderId) async {
    try {
      final order = _orders.firstWhere((o) => o.id == orderId);
      order.status = OrderStatus.refunded;
      await OrderExtendedManager.update(order);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('환불 요청 실패: $e');
      return false;
    }
  }

  /// 상태별 필터링
  List<OrderExtended> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }

  /// 총 결제 금액 계산
  int get totalAmount {
    return _orders
        .where((order) => order.status == OrderStatus.completed)
        .fold<int>(0, (sum, order) => sum + order.finalPrice);
  }
}
