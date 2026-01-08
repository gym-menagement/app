import 'package:flutter/material.dart';
import 'usehealth.dart';

/**
 * Usehealth 모델 확장
 *
 * 자동 생성된 usehealth.dart를 수정하지 않고
 * 추가 기능을 extension으로 제공합니다.
 */

/// UsehealthStatus의 색상 확장
extension UsehealthStatusColorExtension on UsehealthStatus {
  /// 상태별 색상 코드 (hex string)
  String get colorHex {
    switch (this) {
      case UsehealthStatus.none:
        return '#9E9E9E'; // 회색
      case UsehealthStatus.terminated:
        return '#F44336'; // 빨간색
      case UsehealthStatus.use:
        return '#4CAF50'; // 초록색
      case UsehealthStatus.paused:
        return '#FF9800'; // 주황색
      case UsehealthStatus.expired:
        return '#757575'; // 진한 회색
    }
  }

  /// 상태별 색상 (Flutter Color 객체)
  Color get color {
    return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
  }
}

/// Usehealth 클래스의 추가 기능
extension UsehealthExtension on Usehealth {
  /// 이용 가능 여부
  bool get isActive => status == UsehealthStatus.use;

  /// 종료 여부
  bool get isTerminated => status == UsehealthStatus.terminated;

  /// 일시정지 여부
  bool get isPaused => status == UsehealthStatus.paused;

  /// 만료 여부
  bool get isExpired => status == UsehealthStatus.expired;

  /// 남은 횟수 비율 (0.0 ~ 1.0)
  double get remainingRatio {
    if (totalcount == 0) return 0.0;
    return remainingcount / totalcount;
  }

  /// 사용 횟수 비율 (0.0 ~ 1.0)
  double get usedRatio {
    if (totalcount == 0) return 0.0;
    return usedcount / totalcount;
  }

  /// 종료일까지 남은 일수
  int get daysUntilExpiry {
    try {
      final endDate = DateTime.parse(endday);
      final now = DateTime.now();
      return endDate.difference(now).inDays;
    } catch (e) {
      return 0;
    }
  }

  /// 만료 임박 여부 (7일 이내)
  bool get isNearExpiry {
    return daysUntilExpiry > 0 && daysUntilExpiry <= 7;
  }
}
