import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../config/http.dart';

/// 전체화면 QR 코드 (P2 무인 출입, docs/roadmap-p1-p6.md)
///
/// 서버의 TTL 서명 QR(GET /api/door/qr, 30초 유효)을 주기적으로 재발급받아
/// 표시한다 — 스크린샷 재사용을 막는 보안 장치. 발급 실패(구 서버·회원권 없음)
/// 시에는 기존 고정 QR([qrData])로 폴백한다. 백엔드 verify 도 두 형식을 다 받는다.
class FullScreenQRCode extends StatefulWidget {
  final String qrData;
  final String gymName;

  /// 지정 시 이 회원권의 QR 을 발급받는다. 여러 헬스장 회원권 보유 회원이
  /// 엉뚱한 헬스장 QR 을 받는 것을 막는다 (서버가 소유·활성 재검증).
  final int? usehealthId;

  const FullScreenQRCode({
    super.key,
    required this.qrData,
    required this.gymName,
    this.usehealthId,
  });

  @override
  State<FullScreenQRCode> createState() => _FullScreenQRCodeState();
}

class _FullScreenQRCodeState extends State<FullScreenQRCode> {
  static const _refreshSeconds = 25; // 서버 TTL 30초보다 짧게

  String? _liveQr; // 서버 발급 TTL QR. null 이면 고정 QR 폴백
  int _remaining = _refreshSeconds;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _fetchQr();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining--);
      if (_remaining <= 0) {
        _fetchQr();
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _fetchQr() async {
    final res = await Http.get(
        '/api/door/qr',
        widget.usehealthId == null ? null : {'usehealth': widget.usehealthId});
    if (!mounted) return;
    setState(() {
      _remaining = _refreshSeconds;
      if (res != null && res['qr'] != null) {
        _liveQr = res['qr'] as String;
      }
      // 실패 시 _liveQr 유지(직전 값) 또는 null → 고정 QR 폴백
    });
  }

  @override
  Widget build(BuildContext context) {
    final qr = _liveQr ?? widget.qrData;
    final isLive = _liveQr != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.grey900,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '입장 QR 코드',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.gymName,
                style: AppTextStyles.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  border: Border.all(color: AppColors.grey300, width: 2),
                ),
                child: QrImageView(
                  data: qr,
                  version: QrVersions.auto,
                  size: 300.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (isLive)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.autorenew, size: 16, color: AppColors.grey500),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$_remaining초 후 자동 갱신',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey500,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '체육관 입장 시 이 QR코드를 스캔해주세요',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.grey700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '화면 밝기를 최대로 설정하면 더 잘 인식됩니다',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
