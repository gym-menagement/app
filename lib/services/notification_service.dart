import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../model/login.dart';

/// 백그라운드 메시지 핸들러 (최상위 함수여야 함)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('백그라운드 메시지 처리: ${message.messageId}');
}

/// 알림 서비스 클래스
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  FirebaseMessaging? _firebaseMessaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  String? _fcmToken;

  /// FCM 토큰 가져오기
  String? get fcmToken => _fcmToken;

  /// 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    // 타임존 초기화
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

    // 로컬 알림 초기화 (Firebase 없이도 작동)
    await _initializeLocalNotifications();

    // Firebase 초기화 시도 (실패해도 계속 진행)
    try {
      await Firebase.initializeApp();
      _firebaseMessaging = FirebaseMessaging.instance;

      // 알림 권한 요청
      await _requestPermission();

      // FCM 메시지 리스너 설정
      _setupMessageListeners();

      // FCM 토큰 가져오기 (APNs 토큰 없어도 계속 진행)
      try {
        _fcmToken = await _firebaseMessaging?.getToken();
        print('FCM Token: $_fcmToken');

        // 로그인 후에 토큰을 전송하므로 여기서는 전송하지 않음

        // 토큰 갱신 리스너
        _firebaseMessaging?.onTokenRefresh.listen((token) async {
          _fcmToken = token;
          print('FCM Token 갱신: $token');

          // 토큰 갱신 시에도 userId는 나중에 수동으로 전송
          // 필요하다면 여기서 저장된 userId를 사용하여 전송
        });
      } catch (e) {
        print('FCM 토큰 가져오기 실패 (APNs 미설정): $e');
        print('로컬 알림은 정상 작동합니다.');
      }
    } catch (e) {
      print('Firebase 초기화 실패 (로컬 알림만 사용): $e');
    }

    _isInitialized = true;
  }

  /// 알림 권한 요청
  Future<void> _requestPermission() async {
    if (_firebaseMessaging == null) return;

    final settings = await _firebaseMessaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('알림 권한 상태: ${settings.authorizationStatus}');
  }

  /// 로컬 알림 초기화
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Android 알림 채널 생성
    const androidChannel = AndroidNotificationChannel(
      'gym_app_channel',
      '헬스장 앱 알림',
      description: '헬스장 앱의 주요 알림',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// FCM 메시지 리스너 설정
  void _setupMessageListeners() {
    // 포그라운드 메시지
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('포그라운드 메시지: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 백그라운드 메시지에서 앱 열기
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('백그라운드 메시지로 앱 열기: ${message.notification?.title}');
      _handleNotificationTap(message.data);
    });

    // 종료된 상태에서 알림으로 앱 열기
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        print('종료 상태에서 알림으로 앱 열기: ${message.notification?.title}');
        _handleNotificationTap(message.data);
      }
    });
  }

  /// 로컬 알림 표시
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'gym_app_channel',
            '헬스장 앱 알림',
            channelDescription: '헬스장 앱의 주요 알림',
            importance: Importance.high,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// 알림 탭 처리 (로컬 알림)
  void _onNotificationTapped(NotificationResponse response) {
    print('알림 탭: ${response.payload}');
    // TODO: 알림 타입에 따라 화면 이동
  }

  /// 알림 탭 처리 (FCM)
  void _handleNotificationTap(Map<String, dynamic> data) {
    print('FCM 알림 탭: $data');
    // TODO: 알림 타입에 따라 화면 이동
  }

  /// 예약 알림 스케줄링 (로컬)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    Map<String, String>? payload,
  }) async {
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'gym_app_channel',
          '헬스장 앱 알림',
          channelDescription: '헬스장 앱의 주요 알림',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload.toString(),
    );
  }

  /// 이용권 만료 알림 스케줄링
  Future<void> scheduleMembershipExpiryNotifications({
    required int usehealthId,
    required String gymName,
    required DateTime expiryDate,
  }) async {
    // D-7 알림
    final d7 = expiryDate.subtract(const Duration(days: 7));
    if (d7.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: usehealthId * 1000 + 7,
        title: '이용권 만료 7일 전',
        body: '$gymName 이용권이 7일 후 만료됩니다.',
        scheduledDate: d7,
      );
    }

    // D-3 알림
    final d3 = expiryDate.subtract(const Duration(days: 3));
    if (d3.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: usehealthId * 1000 + 3,
        title: '이용권 만료 3일 전',
        body: '$gymName 이용권이 3일 후 만료됩니다.',
        scheduledDate: d3,
      );
    }

    // D-1 알림
    final d1 = expiryDate.subtract(const Duration(days: 1));
    if (d1.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: usehealthId * 1000 + 1,
        title: '이용권 만료 1일 전',
        body: '$gymName 이용권이 내일 만료됩니다. 갱신을 고려해보세요.',
        scheduledDate: d1,
      );
    }

    // D-Day 알림
    if (expiryDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        id: usehealthId * 1000,
        title: '이용권 만료',
        body: '$gymName 이용권이 오늘 만료됩니다.',
        scheduledDate: expiryDate,
      );
    }
  }

  /// 운동 독려 알림 스케줄링 (매일 특정 시간)
  Future<void> scheduleWorkoutReminder({
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 오늘 시간이 지났으면 내일로
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await scheduleNotification(
      id: 9999, // 운동 독려 알림 고정 ID
      title: '오늘 운동하셨나요?',
      body: '건강한 하루를 위해 운동을 시작해보세요!',
      scheduledDate: scheduledDate,
    );
  }

  /// 운동 독려 알림 스케줄링 (3일 미출석 시)
  Future<void> scheduleInactivityReminder({
    required int usehealthId,
    required String gymName,
    required DateTime lastAttendanceDate,
  }) async {
    final now = DateTime.now();
    final daysSinceLastAttendance = now.difference(lastAttendanceDate).inDays;

    // 3일 이상 미출석 시 내일 오전 10시에 알림
    if (daysSinceLastAttendance >= 3) {
      final tomorrow = now.add(const Duration(days: 1));
      final scheduledDate = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        10, // 오전 10시
        0,
      );

      await scheduleNotification(
        id: usehealthId * 2000 + 999, // 운동 독려 알림용 ID
        title: '운동하러 가실 시간이에요! 💪',
        body: '$gymName에서 ${daysSinceLastAttendance}일째 운동을 쉬고 계세요. 오늘은 운동해보시는 건 어떨까요?',
        scheduledDate: scheduledDate,
      );
    }
  }

  /// 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// 모든 알림 취소
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// 대기 중인 알림 목록 가져오기
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// 즉시 알림 표시
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'gym_app_channel',
          '헬스장 앱 알림',
          channelDescription: '헬스장 앱의 주요 알림',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: payload,
    );
  }

  /// FCM 토큰을 서버에 전송 (로그인 후 userId와 함께 전송)
  Future<void> sendTokenToServer({required int userId, String oldToken = ''}) async {
    if (_fcmToken == null) {
      print('FCM 토큰이 없습니다');
      return;
    }

    try {
      await LoginManager.fcm(_fcmToken!, oldToken, userId: userId);
      print('서버에 FCM 토큰 전송 성공 (userId: $userId): $_fcmToken');
    } catch (e) {
      print('서버에 FCM 토큰 전송 실패: $e');
    }
  }

  /// 서버에서 FCM 토큰 삭제
  Future<void> deleteTokenFromServer() async {
    if (_fcmToken == null) return;

    try {
      // 빈 토큰으로 업데이트하여 삭제
      await LoginManager.fcm('', _fcmToken!);
      print('서버에서 FCM 토큰 삭제 성공');
    } catch (e) {
      print('서버에서 FCM 토큰 삭제 실패: $e');
    }
  }
}
