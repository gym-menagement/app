# Provider API 연동 가이드

API_RESPONSE_EXAMPLES.md를 기반으로 Provider와 Screen을 수정하는 가이드입니다.

## 완료된 작업

### 1. AuthProvider ✅

- **로그인**: `POST /api/auth/login` 연동 완료
- **회원가입**: `POST /api/user` 연동 완료
- **프로필 업데이트**: `PUT /api/user/{id}` 연동 완료
- **아이디 중복 체크**: `GET /api/user/search/loginid` 연동 완료

### 2. Config 설정 ✅

- `Config.serverUrl`: API 서버 URL 중앙 관리
- `CConfig`: 토큰 및 런타임 설정 관리
- `Http`: 모든 HTTP 요청을 자동으로 Config.serverUrl 사용

## API 연동 패턴

### 기본 패턴

```dart
// 1. import 추가
import '../config/http.dart';
import '../config/config.dart';
import '../config/cconfig.dart';

// 2. GET 요청 (목록 조회)
Future<void> loadItems() async {
  try {
    final result = await Http.get(Config.apiXxx, {
      'page': 0,
      'pagesize': 10,
    });

    if (result != null && result['content'] != null) {
      final List<dynamic> content = result['content'];
      _items = content.map((json) => Item.fromJson(json)).toList();
      notifyListeners();
    }
  } catch (e) {
    _error = e.toString();
    notifyListeners();
  }
}

// 3. POST 요청 (생성)
Future<bool> createItem(Item item) async {
  try {
    final result = await Http.post(Config.apiXxx, {
      'field1': item.field1,
      'field2': item.field2,
    });

    if (result != null && result['id'] != null) {
      return true;
    }
    return false;
  } catch (e) {
    return false;
  }
}

// 4. PUT 요청 (수정)
Future<bool> updateItem(Item item) async {
  try {
    final success = await Http.put('${Config.apiXxx}/${item.id}', {
      'field1': item.field1,
      'field2': item.field2,
    });

    return success == true;
  } catch (e) {
    return false;
  }
}

// 5. DELETE 요청 (삭제)
Future<bool> deleteItem(int id) async {
  try {
    await Http.delete('${Config.apiXxx}/$id', {'id': id});
    return true;
  } catch (e) {
    return false;
  }
}
```

### 페이징 응답 처리

API에서 반환하는 페이징 구조:

```json
{
  "content": [...],
  "page": 0,
  "size": 10,
  "totalElements": 100,
  "totalPages": 10,
  "first": true,
  "last": false,
  "empty": false
}
```

Provider에서 처리:

```dart
Future<void> loadItems({int page = 0, int pagesize = 10}) async {
  final result = await Http.get(Config.apiXxx, {
    'page': page,
    'pagesize': pagesize,
  });

  if (result != null && result['content'] != null) {
    final List<dynamic> content = result['content'];
    _items = content.map((json) => Item.fromJson(json)).toList();

    // 페이징 정보 저장
    _currentPage = result['page'] ?? 0;
    _totalPages = result['totalPages'] ?? 1;
    _totalElements = result['totalElements'] ?? 0;
    _isLastPage = result['last'] ?? false;

    notifyListeners();
  }
}
```

## GymProvider 수정 예시

```dart
import 'package:flutter/foundation.dart';
import '../model/gym.dart';
import '../config/http.dart';
import '../config/config.dart';

class GymProvider extends ChangeNotifier {
  List<Gym> _gyms = [];
  bool _isLoading = false;
  String? _error;

  List<Gym> get gyms => _gyms;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 체육관 목록 조회
  Future<void> loadGyms({int page = 0, int pagesize = 100}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await Http.get(Config.apiGym, {
        'page': page,
        'pagesize': pagesize,
      });

      if (result != null && result['content'] != null) {
        final List<dynamic> content = result['content'];
        _gyms = content.map((json) => Gym.fromJson(json)).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 체육관 검색 (이름)
  Future<void> searchGymsByName(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await Http.get('${Config.apiGym}/search/name', {
        'name': name,
      });

      if (result != null && result is List) {
        _gyms = result.map((json) => Gym.fromJson(json)).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 체육관 상세 조회
  Future<Gym?> getGymById(int id) async {
    try {
      final result = await Http.get('${Config.apiGym}/$id');

      if (result != null) {
        return Gym.fromJson(result);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
```

## MembershipProvider 수정 예시

```dart
import 'package:flutter/foundation.dart';
import '../model/membership.dart';
import '../config/http.dart';
import '../config/config.dart';

class MembershipProvider extends ChangeNotifier {
  List<Membership> _memberships = [];
  bool _isLoading = false;
  String? _error;

  List<Membership> get memberships => _memberships;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// 사용자별 멤버십 조회
  Future<void> loadUserMemberships(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await Http.get('${Config.apiMembership}/search/user', {
        'user': userId,
      });

      if (result != null && result is List) {
        _memberships = result.map((json) => Membership.fromJson(json)).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 멤버십 목록 조회 (페이징)
  Future<void> loadMemberships({
    int page = 0,
    int pagesize = 10,
    int? userId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final params = {
        'page': page,
        'pagesize': pagesize,
      };

      if (userId != null) {
        params['user'] = userId;
      }

      final result = await Http.get(Config.apiMembership, params);

      if (result != null && result['content'] != null) {
        final List<dynamic> content = result['content'];
        _memberships = content.map((json) => Membership.fromJson(json)).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 멤버십 생성
  Future<bool> createMembership(Membership membership) async {
    try {
      final result = await Http.post(Config.apiMembership, {
        'userId': membership.userId,
        'gymId': membership.gymId,
        'healthId': membership.healthId,
        'orderId': membership.orderId,
        'startDate': membership.startDate,
        'endDate': membership.endDate,
        'remainingCount': membership.remainingCount,
        'totalCount': membership.totalCount,
        'status': membership.status,
      });

      if (result != null && result['id'] != null) {
        // 목록 새로고침
        await loadUserMemberships(membership.userId);
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
```

## Screen에서 Provider 사용

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gym_provider.dart';

class GymListScreen extends StatefulWidget {
  @override
  State<GymListScreen> createState() => _GymListScreenState();
}

class _GymListScreenState extends State<GymListScreen> {
  @override
  void initState() {
    super.initState();
    // 화면 로드 시 데이터 가져오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GymProvider>().loadGyms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('체육관 목록')),
      body: Consumer<GymProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(child: Text('오류: ${provider.error}'));
          }

          if (provider.gyms.isEmpty) {
            return Center(child: Text('체육관이 없습니다'));
          }

          return ListView.builder(
            itemCount: provider.gyms.length,
            itemBuilder: (context, index) {
              final gym = provider.gyms[index];
              return ListTile(
                title: Text(gym.name),
                subtitle: Text(gym.address),
                onTap: () {
                  // 상세 화면으로 이동
                },
              );
            },
          );
        },
      ),
    );
  }
}
```

## Config API 엔드포인트 사용

모든 API 요청에서 Config의 상수를 사용하세요:

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

## 에러 처리 패턴

```dart
Future<void> someApiCall() async {
  try {
    final result = await Http.get(Config.apiXxx);

    if (result == null) {
      _error = 'API 호출에 실패했습니다';
      notifyListeners();
      return;
    }

    // 정상 처리
    _items = result['content'].map(...).toList();
    _error = null;
    notifyListeners();

  } catch (e) {
    _error = '네트워크 오류: ${e.toString()}';
    notifyListeners();
  }
}
```

## 다음 단계

1. ✅ AuthProvider - 완료
2. ⏳ GymProvider - import 추가됨, loadGyms 메서드 수정 필요
3. ⏳ MembershipProvider - 수정 필요
4. ⏳ Screens - Provider 호출 코드 확인 및 수정

모든 Provider는 위의 패턴을 따라 수정하면 됩니다.
