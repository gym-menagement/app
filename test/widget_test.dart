// FullScreenQRCode 스모크 테스트.
//
// 원래 있던 Flutter 템플릿 카운터 테스트는 앱과 무관해 항상 실패했다.
// 대신 P2 QR 화면의 핵심 계약을 검증한다: 서버(TTL QR 발급)에 접속할 수
// 없는 환경에서도 전달받은 고정 QR 로 폴백해 화면이 그려져야 한다.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:app/screens/membership_screen_fullscreen_qr.dart';

void main() {
  testWidgets('QR 화면은 서버 불가 시 고정 QR 로 폴백해 렌더링된다',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FullScreenQRCode(
          qrData: 'usehealth_test_1',
          gymName: '테스트 체육관',
        ),
      ),
    );
    // initState 의 Http.get 은 테스트 환경에서 실패 → null → 고정 QR 폴백.
    await tester.pump();

    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('테스트 체육관'), findsOneWidget);
    expect(find.text('입장 QR 코드'), findsOneWidget);
    // 폴백 상태에서는 자동 갱신 카운트다운이 표시되지 않는다.
    expect(find.textContaining('자동 갱신'), findsNothing);
  });
}
