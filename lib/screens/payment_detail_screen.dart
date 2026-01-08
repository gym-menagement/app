import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../model/order_extended.dart';
import '../config/app_colors.dart';
import '../model/payment_method.dart';
import '../model/payment_method.dart';
import '../components/gym_card.dart';

class PaymentDetailScreen extends StatefulWidget {
  const PaymentDetailScreen({super.key});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  OrderExtended? _order;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orderId = ModalRoute.of(context)?.settings.arguments as int?;
    if (orderId != null && _order == null) {
      _loadOrderDetail(orderId);
    }
  }

  Future<void> _loadOrderDetail(int orderId) async {
    setState(() => _isLoading = true);
    final order = await context.read<OrderProvider>().getOrder(orderId);
    if (mounted) {
      setState(() {
        _order = order;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        title: const Text('결제 상세'),
        backgroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _order == null
              ? _buildErrorState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 결제 상태 카드
                      _buildStatusCard(),
                      const SizedBox(height: 16),

                      // 주문 정보
                      _buildSectionTitle('주문 정보'),
                      const SizedBox(height: 8),
                      _buildOrderInfoCard(),
                      const SizedBox(height: 16),

                      // 결제 정보
                      _buildSectionTitle('결제 정보'),
                      const SizedBox(height: 8),
                      _buildPaymentInfoCard(),
                      const SizedBox(height: 16),

                      // 액션 버튼
                      if (_order!.status == OrderStatus.completed ||
                          _order!.status == OrderStatus.pending)
                        _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatusCard() {
    final status = _order!.status;
    Color statusColor;
    IconData statusIcon;
    String statusMessage;

    switch (status) {
      case OrderStatus.completed:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        statusMessage = '결제가 정상적으로 완료되었습니다';
        break;
      case OrderStatus.pending:
        statusColor = AppColors.warning;
        statusIcon = Icons.access_time;
        statusMessage = '결제 처리 중입니다';
        break;
      case OrderStatus.cancelled:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        statusMessage = '주문이 취소되었습니다';
        break;
      case OrderStatus.refunded:
        statusColor = AppColors.error;
        statusIcon = Icons.receipt_long;
        statusMessage = '환불 처리되었습니다';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusMessage = '알 수 없는 상태입니다';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor, statusColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(statusIcon, size: 64, color: Colors.white),
          const SizedBox(height: 12),
          Text(
            status.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            statusMessage,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return GymCard(
      child: Column(
        children: [
          _buildInfoRow('주문번호', '#${_order!.id}'),
          const Divider(height: 24),
          _buildInfoRow('주문일시', _formatDateTime(_order!.date)),
          const Divider(height: 24),
          _buildInfoRow('헬스장 ID', _order!.gym.toString()),
          const Divider(height: 24),
          _buildInfoRow('이용권 ID', _order!.health.toString()),
          // TODO: Gym, Health 모델과 연동하여 실제 이름 표시
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return GymCard(
      child: Column(
        children: [
          if (_order!.originalPrice > 0) ...[
            _buildInfoRow(
              '정상가',
              '${_formatCurrency(_order!.originalPrice)}원',
              valueColor: Colors.grey[600],
            ),
            const Divider(height: 24),
          ],
          if (_order!.discount > 0) ...[
            _buildInfoRow(
              '할인',
              '-${_formatCurrency(_order!.discount)}원',
              valueColor: AppColors.error,
            ),
            const Divider(height: 24),
          ],
          _buildInfoRow(
            '최종 결제금액',
            '${_formatCurrency(_order!.finalPrice)}원',
            valueStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          if (_order!.paymentMethod != null && _order!.paymentMethod!.isNotEmpty) ...[
            const Divider(height: 24),
            _buildInfoRow('결제수단', _order!.paymentMethod ?? '알 수 없음'),
          ],
          if (_order!.receiptUrl != null) ...[
            const Divider(height: 24),
            _buildReceiptRow(),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
        ),
      ],
    );
  }

  Widget _buildReceiptRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '영수증',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        TextButton.icon(
          onPressed: _viewReceipt,
          icon: const Icon(Icons.receipt_long, size: 18),
          label: const Text('보기'),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (_order!.status == OrderStatus.pending)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showCancelDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '주문 취소',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        if (_order!.status == OrderStatus.completed) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _showRefundDialog,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '환불 요청',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '주문 정보를 불러올 수 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('돌아가기'),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String date) {
    try {
      final dateTime = DateTime.parse(date);
      final year = dateTime.year;
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final second = dateTime.second.toString().padLeft(2, '0');
      return '$year년 $month월 $day일 $hour:$minute:$second';
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

  Future<void> _showCancelDialog() async {
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
      final success = await context.read<OrderProvider>().cancelOrder(_order!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '주문이 취소되었습니다' : '주문 취소에 실패했습니다'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
        if (success) {
          // 주문 정보 새로고침
          _loadOrderDetail(_order!.id);
        }
      }
    }
  }

  Future<void> _showRefundDialog() async {
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
      final success = await context.read<OrderProvider>().requestRefund(_order!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? '환불 요청이 접수되었습니다' : '환불 요청에 실패했습니다'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
        if (success) {
          // 주문 정보 새로고침
          _loadOrderDetail(_order!.id);
        }
      }
    }
  }

  void _viewReceipt() {
    // TODO: 영수증 URL을 웹뷰나 브라우저로 열기
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('영수증 보기 기능은 준비중입니다')),
    );
  }
}
