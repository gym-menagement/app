/// 포맷팅 유틸리티 함수들
library;

/// 가격을 한국 원화 형식으로 포맷합니다.
///
/// 예: 1000000 -> "1,000,000원"
String formatPrice(int price) {
  return '${price.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  )}원';
}

/// 날짜 문자열을 YYYY.MM.DD 형식으로 포맷합니다.
///
/// 예: "2024-01-15T10:30:00Z" -> "2024.01.15"
String formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  } catch (e) {
    return dateStr;
  }
}

/// 날짜 문자열을 YYYY.MM.DD HH:mm 형식으로 포맷합니다.
///
/// 예: "2024-01-15T10:30:00Z" -> "2024.01.15 10:30"
String formatDateTime(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  } catch (e) {
    return dateStr;
  }
}

/// 이용 기간(개월 수)을 한글 레이블로 변환합니다.
///
/// 12개월 이상인 경우 년 단위로 표시합니다.
/// - 6개월 -> "6개월"
/// - 12개월 -> "1년"
/// - 18개월 -> "18개월"
String getTermLabel(int term) {
  if (term >= 12 && term % 12 == 0) {
    return '${term ~/ 12}년';
  } else {
    return '$term개월';
  }
}

/// 두 날짜 사이의 일수를 계산합니다.
int getDaysBetween(DateTime start, DateTime end) {
  return end.difference(start).inDays;
}

/// 현재 날짜와 주어진 날짜 사이의 남은 일수를 계산합니다.
int getRemainingDays(String endDateStr) {
  try {
    final endDate = DateTime.parse(endDateStr);
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  } catch (e) {
    return 0;
  }
}

/// 현재 날짜와 주어진 시작/종료 날짜 사이의 진행률을 계산합니다 (0.0 ~ 1.0).
double getProgressRate(String startDateStr, String endDateStr) {
  try {
    final startDate = DateTime.parse(startDateStr);
    final endDate = DateTime.parse(endDateStr);
    final now = DateTime.now();

    final total = getDaysBetween(startDate, endDate);
    final elapsed = getDaysBetween(startDate, now);

    if (total <= 0) return 0.0;
    final rate = elapsed / total;

    return rate.clamp(0.0, 1.0);
  } catch (e) {
    return 0.0;
  }
}
