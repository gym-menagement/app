import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/usehealth.dart';
import '../model/gym.dart';
import 'notification_provider.dart';

class UsehealthProvider extends ChangeNotifier {
  List<Usehealth> _usehealths = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _userId;
  BuildContext? _context;

  List<Usehealth> get usehealths => _usehealths;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 활성 중인 이용권 (기간 기반 - 현재 날짜가 startday와 endday 사이이고 일시정지가 아닌 경우)
  List<Usehealth> get activeUsehealths {
    final now = DateTime.now();
    return _usehealths.where((u) {
      try {
        final startDate = DateTime.parse(u.startday);
        final endDate = DateTime.parse(u.endday);
        final isPaused = u.status == UsehealthStatus.paused;
        return now.isAfter(startDate) && now.isBefore(endDate) && !isPaused;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // 만료된 이용권 (기간 기반 - 종료일이 현재보다 이전인 경우)
  List<Usehealth> get expiredUsehealths {
    final now = DateTime.now();
    return _usehealths.where((u) {
      try {
        final endDate = DateTime.parse(u.endday);
        return now.isAfter(endDate);
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // 일시정지된 이용권 (상태가 일시정지인 경우)
  List<Usehealth> get pausedUsehealths =>
      _usehealths.where((u) => u.status == UsehealthStatus.paused).toList();

  // userId 설정
  void setUserId(int userId) {
    _userId = userId;
  }

  // BuildContext 설정 (알림 스케줄링에 필요)
  void setContext(BuildContext context) {
    _context = context;
  }

  // 이용권 목록 로드
  Future<void> loadUsehealths() async {
    if (_userId == null) {
      _errorMessage = 'userId가 설정되지 않았습니다';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // userId를 params로 전달
      final params = 'user=$_userId';

      _usehealths = await UsehealthManager.find(
        page: 0,
        pagesize: 9999,
        params: params,
      );

      // 3일 미출석 체크 및 알림 스케줄링
      await _checkInactivityAndScheduleReminders();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 특정 이용권 상세 정보 가져오기
  Future<Usehealth?> getUsehealth(int id) async {
    try {
      return await UsehealthManager.get(id);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  // 이용권 새로고침
  Future<void> refresh() async {
    await loadUsehealths();
  }

  // 3일 미출석 체크 및 알림 스케줄링
  Future<void> _checkInactivityAndScheduleReminders() async {
    if (_context == null) return;

    try {
      final notificationProvider = _context!.read<NotificationProvider>();
      final now = DateTime.now();

      // 활성 이용권 중 3일 이상 미출석 체크
      for (final usehealth in activeUsehealths) {
        if (usehealth.lastuseddate.isEmpty) continue;

        try {
          final lastUsedDate = DateTime.parse(usehealth.lastuseddate);
          final daysSinceLastUse = now.difference(lastUsedDate).inDays;

          // 3일 이상 미출석 시 알림 스케줄링
          if (daysSinceLastUse >= 3) {
            // 헬스장 이름 가져오기
            final gym = await GymManager.get(usehealth.gym);
            if (gym.id != 0) {
              await notificationProvider.scheduleInactivityReminder(
                usehealthId: usehealth.id,
                gymName: gym.name,
                lastAttendanceDate: lastUsedDate,
              );
              print('운동 독려 알림 스케줄링 완료: ${gym.name}, ${daysSinceLastUse}일 미출석');
            }
          }
        } catch (e) {
          print('알림 스케줄링 실패 (usehealth ${usehealth.id}): $e');
        }
      }
    } catch (e) {
      print('운동 독려 알림 체크 실패: $e');
    }
  }
}
