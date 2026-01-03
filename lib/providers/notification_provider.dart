import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/alarm.dart';
import '../services/notification_service.dart';

/// 알림 설정 모델
class NotificationSettings {
  final bool enabled;
  final bool membershipExpiring;
  final bool workoutReminder;
  final bool achievement;
  final bool marketing;

  const NotificationSettings({
    this.enabled = true,
    this.membershipExpiring = true,
    this.workoutReminder = true,
    this.achievement = true,
    this.marketing = false,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      enabled: json['enabled'] as bool? ?? true,
      membershipExpiring: json['membership_expiring'] as bool? ?? true,
      workoutReminder: json['workout_reminder'] as bool? ?? true,
      achievement: json['achievement'] as bool? ?? true,
      marketing: json['marketing'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'membership_expiring': membershipExpiring,
      'workout_reminder': workoutReminder,
      'achievement': achievement,
      'marketing': marketing,
    };
  }

  NotificationSettings copyWith({
    bool? enabled,
    bool? membershipExpiring,
    bool? workoutReminder,
    bool? achievement,
    bool? marketing,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      membershipExpiring: membershipExpiring ?? this.membershipExpiring,
      workoutReminder: workoutReminder ?? this.workoutReminder,
      achievement: achievement ?? this.achievement,
      marketing: marketing ?? this.marketing,
    );
  }
}

/// 알림 Provider
class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  NotificationSettings _settings = const NotificationSettings();
  List<Alarm> _alarms = [];
  bool _isLoading = false;

  NotificationSettings get settings => _settings;
  List<Alarm> get alarms => _alarms;
  bool get isLoading => _isLoading;
  int get unreadCount => _alarms.where((a) => !a.checked).length;

  /// 초기화
  Future<void> initialize() async {
    await _notificationService.initialize();
    await loadSettings();
    await loadAlarms();
  }

  /// 설정 로드
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('notification_settings');

      if (settingsJson != null) {
        // JSON 파싱 로직 추가 가능
        // _settings = NotificationSettings.fromJson(jsonDecode(settingsJson));
      }
    } catch (e) {
      debugPrint('알림 설정 로드 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 서버에서 알림 목록 로드
  Future<void> loadAlarms() async {
    _isLoading = true;
    notifyListeners();

    try {
      _alarms = await AlarmManager.find(page: 0, pagesize: 50);
    } catch (e) {
      debugPrint('알림 목록 로드 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadAlarms();
  }

  /// 설정 저장
  Future<void> saveSettings(NotificationSettings newSettings) async {
    _settings = newSettings;

    try {
      // TODO: 서버에 설정 저장
      // final prefs = await SharedPreferences.getInstance();
      // await prefs.setString('notification_settings', jsonEncode(_settings.toJson()));

      // 설정에 따라 알림 활성화/비활성화
      if (!_settings.enabled) {
        await _notificationService.cancelAllNotifications();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('알림 설정 저장 실패: $e');
    }
  }

  /// 전체 알림 활성화/비활성화
  Future<void> toggleNotifications(bool enabled) async {
    await saveSettings(_settings.copyWith(enabled: enabled));
  }

  /// 이용권 만료 알림 설정
  Future<void> toggleMembershipExpiringNotification(bool enabled) async {
    await saveSettings(_settings.copyWith(membershipExpiring: enabled));
  }

  /// 운동 독려 알림 설정
  Future<void> toggleWorkoutReminderNotification(bool enabled) async {
    await saveSettings(_settings.copyWith(workoutReminder: enabled));
  }

  /// 목표 달성 알림 설정
  Future<void> toggleAchievementNotification(bool enabled) async {
    await saveSettings(_settings.copyWith(achievement: enabled));
  }

  /// 마케팅 알림 설정
  Future<void> toggleMarketingNotification(bool enabled) async {
    await saveSettings(_settings.copyWith(marketing: enabled));
  }

  /// 이용권 만료 알림 스케줄링
  Future<void> scheduleMembershipExpiryNotifications({
    required int usehealthId,
    required String gymName,
    required DateTime expiryDate,
  }) async {
    if (!_settings.enabled || !_settings.membershipExpiring) {
      return;
    }

    await _notificationService.scheduleMembershipExpiryNotifications(
      usehealthId: usehealthId,
      gymName: gymName,
      expiryDate: expiryDate,
    );
  }

  /// 운동 독려 알림 스케줄링
  Future<void> scheduleWorkoutReminder({
    int hour = 20,
    int minute = 0,
  }) async {
    if (!_settings.enabled || !_settings.workoutReminder) {
      return;
    }

    await _notificationService.scheduleWorkoutReminder(
      hour: hour,
      minute: minute,
    );
  }

  /// 즉시 알림 표시
  Future<void> showNotification({
    required String title,
    required String body,
    AlarmType type = AlarmType.info,
  }) async {
    if (!_settings.enabled) {
      return;
    }

    await _notificationService.showNotification(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
    );

    // 서버에 알림 저장 (필요시)
    // await AlarmManager.insert(Alarm(
    //   title: title,
    //   content: body,
    //   type: type,
    //   status: AlarmStatus.success,
    //   date: DateTime.now().toIso8601String(),
    // ));
  }

  /// 알림 읽음 처리
  Future<void> markAsRead(int alarmId) async {
    final index = _alarms.indexWhere((a) => a.id == alarmId);
    if (index != -1) {
      _alarms[index].checked = true;

      // 서버에 업데이트
      try {
        await AlarmManager.update(_alarms[index]);
        notifyListeners();
      } catch (e) {
        debugPrint('알림 읽음 처리 실패: $e');
      }
    }
  }

  /// 모든 알림 읽음 처리
  Future<void> markAllAsRead() async {
    for (var alarm in _alarms) {
      if (!alarm.checked) {
        alarm.checked = true;
        try {
          await AlarmManager.update(alarm);
        } catch (e) {
          debugPrint('알림 읽음 처리 실패: $e');
        }
      }
    }
    notifyListeners();
  }

  /// 알림 삭제
  Future<void> deleteAlarm(int alarmId) async {
    final alarm = _alarms.firstWhere((a) => a.id == alarmId);
    try {
      await AlarmManager.delete(alarm);
      _alarms.removeWhere((a) => a.id == alarmId);
      notifyListeners();
    } catch (e) {
      debugPrint('알림 삭제 실패: $e');
    }
  }

  /// 모든 알림 삭제
  Future<void> deleteAllAlarms() async {
    for (var alarm in _alarms) {
      try {
        await AlarmManager.delete(alarm);
      } catch (e) {
        debugPrint('알림 삭제 실패: $e');
      }
    }
    _alarms.clear();
    notifyListeners();
  }

  /// FCM 토큰 가져오기
  String? get fcmToken => _notificationService.fcmToken;

  /// 대기 중인 알림 확인
  Future<void> checkPendingNotifications() async {
    final pending = await _notificationService.getPendingNotifications();
    debugPrint('대기 중인 알림: ${pending.length}개');
  }
}
