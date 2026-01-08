import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../model/order_extended.dart';
import '../config/app_colors.dart';
import '../components/gym_components.dart';

import '../model/payment_method.dart';
class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  OrderStatus _selectedStatus = OrderStatus.pending;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<OrderProvider>().loadOrders(refresh: true);
    });
  }

  Future<void> _onRefresh() async {
    await context.read<OrderProvider>().refresh();
  }

  Future<void> _onLoadMore() async {
    await context.read<OrderProvider>().loadMore();
  }

  List<OrderExtended> _getFilteredOrders(OrderProvider provider) {
    if (_selectedStatus == null) {
      return provider.orders;
    }
    return provider.getOrdersByStatus(_selectedStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('결제 내역'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          final filteredOrders = _getFilteredOrders(orderProvider);

          return Column(
            children: [
              // 필터 칩
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: '전체',
                        status: null,
                        count: orderProvider.orders.length,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: OrderStatus.completed.label,
                        status: OrderStatus.completed,
                        count: orderProvider.getOrdersByStatus(OrderStatus.completed).length,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: OrderStatus.pending.label,
                        status: OrderStatus.pending,
                        count: orderProvider.getOrdersByStatus(OrderStatus.pending).length,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: OrderStatus.cancelled.label,
                        status: OrderStatus.cancelled,
                        count: orderProvider.getOrdersByStatus(OrderStatus.cancelled).length,
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: OrderStatus.refunded.label,
                        status: OrderStatus.refunded,
                        count: orderProvider.getOrdersByStatus(OrderStatus.refunded).length,
                      ),
                    ],
                  ),
                ),
              ),

              // 총 결제 금액
              if (_selectedStatus == null || _selectedStatus == OrderStatus.completed)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '총 결제 금액',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_formatCurrency(orderProvider.totalAmount)}원',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

              // 결제 내역 목록
              Expanded(
                child: InfiniteScrollList<OrderExtended>(
                  items: filteredOrders,
                  isLoading: orderProvider.isLoading,
                  hasMore: orderProvider.hasMore,
                  onLoadMore: _onLoadMore,
                  onRefresh: _onRefresh,
                  itemBuilder: (context, order) => _buildOrderCard(order),
                  emptyWidget: _buildEmptyState(),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required OrderStatus status,
    required int count,
  }) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text('$label ($count)'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = status;
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/payment_detail',
          arguments: order.id,
        );
      },
      child: GymCard(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더: 날짜와 상태
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(order.date),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 12),

            // 주문 정보 (헬스장, 이용권 이름 등)
            // TODO: Gym, Health 모델과 연동하여 실제 이름 표시
            Text(
              '주문번호: ${order.id}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '헬스장 ID: ${order.gym} / 이용권 ID: ${order.health}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),

            // 가격 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.discount > 0) ...[
                      Text(
                        '정상가: ${_formatCurrency(order.originalPrice)}원',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '할인: -${_formatCurrency(order.discount)}원',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        const Text(
                          '결제금액: ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${_formatCurrency(order.finalPrice)}원',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // 결제수단
                if (order.paymentMethod != PaymentMethod.none)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.paymentMethod.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            // 액션 버튼 (취소, 환불 등)
            if (order.status == OrderStatus.completed || order.status == OrderStatus.pending)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (order.status == OrderStatus.pending)
                      TextButton(
                        onPressed: () => _showCancelDialog(order),
                        child: const Text(
                          '주문 취소',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    if (order.status == OrderStatus.completed)
                      TextButton(
                        onPressed: () => _showRefundDialog(order),
                        child: const Text(
                          '환불 요청',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    if (order.receiptUrl != null)
                      TextButton.icon(
                        onPressed: () => _viewReceipt(order),
                        icon: const Icon(Icons.receipt_long, size: 18),
                        label: const Text('영수증'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.completed:
        color = AppColors.success;
        break;
      case OrderStatus.pending:
        color = AppColors.warning;
        break;
      case OrderStatus.cancelled:
      case OrderStatus.refunded:
        color = AppColors.error;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '결제 내역이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '헬스장 이용권을 구매해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final dateTime = DateTime.parse(date);
      final year = dateTime.year;
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$year.$month.$day $hour:$minute';
    } catch (e) {
      return date;
    }
  }

  String _formatCurrency(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  Future<void> _showCancelDialog(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('주문 취소'),
        content: const Text('이 주문을 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('예', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<OrderProvider>().cancelOrder(order.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '주문이 취소되었습니다' : '주문 취소에 실패했습니다'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _showRefundDialog(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('환불 요청'),
        content: const Text('환불을 요청하시겠습니까?\n환불 처리까지 3-5 영업일이 소요될 수 있습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니오'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('예', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<OrderProvider>().requestRefund(order.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '환불 요청이 접수되었습니다' : '환불 요청에 실패했습니다'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }

  void _viewReceipt(Order order) {
    // TODO: 영수증 URL을 웹뷰나 브라우저로 열기
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('영수증 보기 기능은 준비중입니다')),
    );
  }
}
