import 'package:flutter/foundation.dart';
import '../model/membership.dart';
import '../model/gym.dart';
import '../config/http.dart';
import '../config/config.dart';

/// Membership state management provider
/// Manages active memberships, history, statistics, and membership operations
class MembershipProvider extends ChangeNotifier {
  Membership? _activeMembership;
  Gym? _activeGym;
  List<Membership> _membershipHistory = [];
  Map<String, dynamic>? _stats;

  bool _isLoading = false;
  String? _error;

  // Getters
  Membership? get activeMembership => _activeMembership;
  Gym? get activeGym => _activeGym;
  List<Membership> get membershipHistory => _membershipHistory;
  Map<String, dynamic>? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveMembership => _activeMembership != null;

  /// Load user memberships
  Future<void> loadMemberships(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // GET /api/membership/search/user?user={userId}
      final result = await Http.get('${Config.apiMembership}/search/user', {
        'user': userId,
      });

      if (result != null && result is List) {
        // API 응답의 userId/gymId를 user/gym으로 변환하고 추가 필드는 extra에 저장
        final memberships = result.map((json) {
          final extra = json['extra'] == null
              ? <String, dynamic>{}
              : Map<String, dynamic>.from(json['extra'] as Map<String, dynamic>);

          // API 응답의 추가 필드들을 extra에 저장
          if (json['healthId'] != null) extra['healthId'] = json['healthId'];
          if (json['orderId'] != null) extra['orderId'] = json['orderId'];
          if (json['startDate'] != null) extra['startDate'] = json['startDate'];
          if (json['endDate'] != null) extra['endDate'] = json['endDate'];
          if (json['remainingCount'] != null) extra['remainingCount'] = json['remainingCount'];
          if (json['totalCount'] != null) extra['totalCount'] = json['totalCount'];
          if (json['status'] != null) extra['statusCode'] = json['status'];

          // userId/gymId를 user/gym으로 변환
          final converted = {
            'id': json['id'],
            'user': json['userId'] ?? json['user'] ?? 0,
            'gym': json['gymId'] ?? json['gym'] ?? 0,
            'date': json['date'] ?? '',
            'extra': extra,
          };

          return Membership.fromJson(converted);
        }).toList();

        // Separate active and history memberships based on status
        _activeMembership = null;
        _membershipHistory = [];

        for (var membership in memberships) {
          final status = membership.extra['statusCode'] as int? ?? 0;
          if (status == 0) { // ACTIVE
            _activeMembership = membership;
          } else {
            _membershipHistory.add(membership);
          }
        }

        // Load active gym if there's an active membership
        if (_activeMembership != null) {
          await _loadActiveGym(_activeMembership!.gym);
        }

        _isLoading = false;
        notifyListeners();
      } else {
        _error = '멤버십 정보를 불러올 수 없습니다.';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = '네트워크 오류가 발생했습니다: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load active gym data
  Future<void> _loadActiveGym(int gymId) async {
    try {
      // GET /api/gym/{id}
      final result = await Http.get('${Config.apiGym}/$gymId');

      if (result != null) {
        _activeGym = Gym.fromJson(result);
      }
    } catch (e) {
      // Gym loading error is not critical, just log it
      debugPrint('Failed to load gym: $e');
    }
  }

  /// Purchase new membership
  Future<bool> purchaseMembership({
    required int userId,
    required int gymId,
    required String plan,
    required int price,
    required String paymentMethod,
    int? orderId,
    int? healthId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Calculate dates based on plan
      final startDate = DateTime.now();
      DateTime endDate;

      if (plan.contains('1개월')) {
        endDate = startDate.add(const Duration(days: 30));
      } else if (plan.contains('3개월')) {
        endDate = startDate.add(const Duration(days: 90));
      } else if (plan.contains('6개월')) {
        endDate = startDate.add(const Duration(days: 180));
      } else if (plan.contains('12개월')) {
        endDate = startDate.add(const Duration(days: 365));
      } else {
        endDate = startDate.add(const Duration(days: 30));
      }

      // POST /api/membership - API expects userId, gymId format
      final result = await Http.post(Config.apiMembership, {
        'userId': userId,
        'gymId': gymId,
        'healthId': healthId ?? 0,
        'orderId': orderId ?? 0,
        'startDate': startDate.toString(),
        'endDate': endDate.toString(),
        'remainingCount': 0,
        'totalCount': 0,
        'status': 0, // ACTIVE
      });

      if (result != null && result['id'] != null) {
        // Reload memberships to get updated list
        await loadMemberships(userId);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = '멤버십 구매에 실패했습니다.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '네트워크 오류가 발생했습니다: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Extend/renew membership
  Future<bool> extendMembership({
    required String plan,
    required int price,
    required String paymentMethod,
  }) async {
    if (_activeMembership == null) {
      _error = '활성 이용권이 없습니다';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // extra에서 데이터 가져오기
      final endDateStr = _activeMembership!.extra['endDate'] as String? ?? DateTime.now().toString();
      final currentEndDate = DateTime.parse(endDateStr);
      DateTime newEndDate;

      if (plan.contains('1개월')) {
        newEndDate = currentEndDate.add(const Duration(days: 30));
      } else if (plan.contains('3개월')) {
        newEndDate = currentEndDate.add(const Duration(days: 90));
      } else if (plan.contains('6개월')) {
        newEndDate = currentEndDate.add(const Duration(days: 180));
      } else if (plan.contains('12개월')) {
        newEndDate = currentEndDate.add(const Duration(days: 365));
      } else {
        newEndDate = currentEndDate.add(const Duration(days: 30));
      }

      // PUT /api/membership/{id} - API expects userId, gymId format
      final success = await Http.put('${Config.apiMembership}/${_activeMembership!.id}', {
        'userId': _activeMembership!.user,
        'gymId': _activeMembership!.gym,
        'healthId': _activeMembership!.extra['healthId'] ?? 0,
        'orderId': _activeMembership!.extra['orderId'] ?? 0,
        'startDate': _activeMembership!.extra['startDate'] ?? DateTime.now().toString(),
        'endDate': newEndDate.toString(),
        'remainingCount': _activeMembership!.extra['remainingCount'] ?? 0,
        'totalCount': _activeMembership!.extra['totalCount'] ?? 0,
        'status': _activeMembership!.extra['statusCode'] ?? 0,
      });

      if (success == true) {
        // Reload memberships to get updated data
        await loadMemberships(_activeMembership!.user);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = '멤버십 연장에 실패했습니다.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = '네트워크 오류가 발생했습니다: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Pause membership
  Future<bool> pauseMembership(int days) async {
    if (_activeMembership == null) {
      _error = '활성 이용권이 없습니다';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      _activeMembership!.extra['status'] = 'paused';
      _activeMembership!.extra['pausedDays'] = days;
      _activeMembership!.extra['pausedAt'] = DateTime.now().toIso8601String();

      // Extend end date by paused days
      final currentEndDate = DateTime.parse(_activeMembership!.extra['endDate'] as String);
      final newEndDate = currentEndDate.add(Duration(days: days));
      _activeMembership!.extra['endDate'] = newEndDate.toIso8601String();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Resume paused membership
  Future<bool> resumeMembership() async {
    if (_activeMembership == null) {
      _error = '활성 이용권이 없습니다';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      _activeMembership!.extra['status'] = 'active';
      _activeMembership!.extra.remove('pausedDays');
      _activeMembership!.extra.remove('pausedAt');

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Record gym visit (check-in)
  Future<bool> recordVisit() async {
    if (_activeMembership == null) {
      _error = '활성 이용권이 없습니다';
      notifyListeners();
      return false;
    }

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Update visit count
      final currentVisits = _activeMembership!.extra['totalVisits'] as int? ?? 0;
      _activeMembership!.extra['totalVisits'] = currentVisits + 1;

      // Update last visit
      _activeMembership!.extra['lastVisit'] = DateTime.now().toIso8601String();

      // Update stats
      if (_stats != null) {
        _stats!['totalVisitsThisMonth'] = (_stats!['totalVisitsThisMonth'] as int? ?? 0) + 1;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get remaining days
  int getRemainingDays() {
    if (_activeMembership == null) return 0;

    final endDateStr = _activeMembership!.extra['endDate'] as String?;
    if (endDateStr == null) return 0;

    final endDate = DateTime.parse(endDateStr);
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Check if membership is expiring soon (within 7 days)
  bool isExpiringSoon() {
    return getRemainingDays() > 0 && getRemainingDays() <= 7;
  }

  /// Check if membership is expired
  bool isExpired() {
    return getRemainingDays() <= 0;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset provider (for logout)
  void reset() {
    _activeMembership = null;
    _activeGym = null;
    _membershipHistory = [];
    _stats = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
