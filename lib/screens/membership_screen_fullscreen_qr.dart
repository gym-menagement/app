import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';

/// 전체화면 QR 코드
class FullScreenQRCode extends StatelessWidget {
  final String qrData;
  final String gymName;

  const FullScreenQRCode({
    super.key,
    required this.qrData,
    required this.gymName,
  });

  @override
  Widget build(BuildContext context) {
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
                gymName,
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
                  data: qrData,
                  version: QrVersions.auto,
                  size: 300.0,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
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
