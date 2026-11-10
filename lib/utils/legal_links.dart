import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 약관·개인정보 처리방침 등 외부 문서를 인앱 브라우저로 연다.
/// 열지 못하면 스낵바로 알린다.
Future<void> openLegalUrl(BuildContext context, String url) async {
  var opened = false;
  try {
    opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.inAppBrowserView,
    );
  } catch (_) {
    opened = false;
  }

  if (!opened && context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('페이지를 열 수 없습니다')));
  }
}
