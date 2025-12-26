# Config - API 설정 및 HTTP 통신

앱의 API 서버 연동을 위한 설정 및 HTTP 통신 유틸리티입니다.

## 파일 구조

- **config.dart**: 서버 URL 및 API 엔드포인트 상수 관리
- **cconfig.dart**: 런타임 설정 관리 (토큰, 동적 서버 URL 등)
- **http.dart**: HTTP 통신 유틸리티 클래스

## 사용 방법

### 1. 서버 URL 설정

`config.dart`에서 서버 URL을 설정합니다:

```dart
// lib/config/config.dart
class Config {
  // 개발 환경에 맞게 변경
  static const serverUrl = 'http://10.0.1.62:9004';

  // 또는
  // static const serverUrl = 'http://localhost:9004';  // 로컬
  // static const serverUrl = 'https://api.yourdomain.com';  // 운영
}
```

### 2. 인증 토큰 설정

로그인 성공 후 CConfig에 토큰을 저장합니다:

```dart
import 'package:app/config/cconfig.dart';

// 로그인 성공 후
final config = CConfig();
config.token = 'your-auth-token-here';

// 필요시 서버 URL 동적 변경도 가능
// config.serverUrl = 'https://different-server.com';
```

### 3. HTTP 요청 사용

#### GET 요청

```dart
import 'package:app/config/http.dart';
import 'package:app/config/config.dart';

// 체육관 목록 조회
var gyms = await Http.get(Config.apiGym, {
  'page': 1,
  'limit': 10,
  'search': '강남'
});

// 결과 사용
if (gyms != null) {
  print('총 ${gyms['total']}개의 체육관');
  List items = gyms['items'];
  // ...
}
```

#### POST 요청

```dart
// 로그인
var result = await Http.post('${Config.apiAuth}/login', {
  'email': 'user@example.com',
  'password': 'password123'
});

if (result != null && result['success']) {
  // 토큰 저장
  CConfig().token = result['token'];
  print('로그인 성공!');
}
```

#### INSERT 요청 (새 데이터 생성)

```dart
// 새 회원권 생성
int newId = await Http.insert(Config.apiMembership, {
  'userId': 123,
  'gymId': 456,
  'type': 'monthly',
  'startDate': '2025-01-01',
});

if (newId > 0) {
  print('생성된 회원권 ID: $newId');
}
```

#### PUT 요청 (업데이트)

```dart
// 프로필 업데이트
bool success = await Http.put('${Config.apiUser}/profile', {
  'name': '홍길동',
  'phone': '010-1234-5678'
});

if (success == true) {
  print('프로필 업데이트 성공!');
}
```

#### DELETE 요청

```dart
// 회원권 삭제
await Http.delete('${Config.apiMembership}/$membershipId', {
  'id': membershipId
});
```

#### 파일 업로드

```dart
// 프로필 이미지 업로드
String filename = await Http.upload(
  '${Config.apiUser}/upload-profile',
  'profile',  // 파일 필드 이름
  '/path/to/image.jpg'
);

if (filename.isNotEmpty) {
  print('업로드된 파일: $filename');
}
```

## API 엔드포인트 상수

Config 클래스에서 제공하는 API 엔드포인트:

```dart
Config.apiAuth          // '/api/auth'
Config.apiUser          // '/api/user'
Config.apiGym           // '/api/gym'
Config.apiMembership    // '/api/membership'
Config.apiPayment       // '/api/payment'
Config.apiAttendance    // '/api/attendance'
Config.apiHealth        // '/api/health'
Config.apiNotice        // '/api/notice'
Config.apiInquiry       // '/api/inquiry'
```

### 사용 예시

```dart
// 하드코딩 대신
await Http.get('/api/gyms');

// 상수 사용 (권장)
await Http.get(Config.apiGym);
```

## 플랫폼 체크

현재 실행 중인 플랫폼을 확인할 수 있습니다:

```dart
// 플랫폼 이름 가져오기
String platform = Config.platform();  // 'android', 'ios', 'web'

// 플랫폼별 체크
if (Config.isAndroid) {
  print('안드로이드에서 실행 중');
}

if (Config.isIOS) {
  print('iOS에서 실행 중');
}

if (Config.isWeb) {
  print('웹에서 실행 중');
}
```

## Provider와 함께 사용

```dart
import 'package:flutter/material.dart';
import 'package:app/config/http.dart';
import 'package:app/config/config.dart';

class GymProvider extends ChangeNotifier {
  List<Gym> _gyms = [];
  bool _isLoading = false;

  List<Gym> get gyms => _gyms;
  bool get isLoading => _isLoading;

  Future<void> fetchGyms() async {
    _isLoading = true;
    notifyListeners();

    try {
      var result = await Http.get(Config.apiGym, {
        'page': 1,
        'limit': 20,
      });

      if (result != null && result['items'] != null) {
        _gyms = (result['items'] as List)
            .map((json) => Gym.fromJson(json))
            .toList();
      }
    } catch (e) {
      print('체육관 목록 조회 실패: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

## 에러 처리

Http 클래스는 자동으로 에러를 처리하고 null을 반환합니다:

```dart
var result = await Http.get(Config.apiGym);

if (result == null) {
  // 네트워크 에러 또는 서버 에러
  print('데이터를 불러올 수 없습니다');
} else {
  // 성공
  print('데이터 로드 완료');
}
```

## 초기화 순서

앱 시작 시 권장 초기화 순서:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. CConfig 초기화 (자동으로 Config.serverUrl 사용)
  final config = CConfig();

  // 2. 저장된 토큰이 있다면 로드
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // String? savedToken = prefs.getString('auth_token');
  // if (savedToken != null) {
  //   config.token = savedToken;
  // }

  runApp(MyApp());
}
```

## 보안 주의사항

1. **토큰 관리**: 민감한 토큰은 안전하게 저장하세요 (flutter_secure_storage 권장)
2. **HTTPS 사용**: 운영 환경에서는 반드시 HTTPS를 사용하세요
3. **환경 분리**: 개발/운영 환경의 서버 URL을 분리하세요
4. **토큰 갱신**: 토큰 만료 시 자동 갱신 로직을 구현하세요

## 디버깅

Http 클래스는 디버그 모드에서 자동으로 에러를 출력합니다:

```dart
if (kDebugMode) {
  print(e);  // 콘솔에 에러 출력
}
```

전체 요청/응답을 로깅하려면:

```dart
// http.dart 파일에 추가
if (kDebugMode) {
  print('Request: $url');
  print('Response: ${result.body}');
}
```
