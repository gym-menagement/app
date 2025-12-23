import 'package:flutter/foundation.dart';
import '../model/membership.dart';
import '../model/gym.dart';

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
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock active membership
      _activeMembership = Membership(
        id: 1,
        user: userId,
        gym: 1,
        date: DateTime.now().toString(),
        extra: {
          'plan': '6개월 이용권',
          'startDate': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          'endDate': DateTime.now().add(const Duration(days: 150)).toIso8601String(),
          'price': 480000,
          'status': 'active',
          'features': ['무제한 이용', 'PT 5회', '락커 제공', '운동복 제공'],
          'totalVisits': 45,
          'pauseAvailable': true,
        },
      );

      // Mock gym data
      _activeGym = Gym(
        id: 1,
        name: '강남 피트니스',
        address: '서울 강남구 테헤란로 123',
        tel: '02-1234-5678',
        user: 1,
        date: DateTime.now().toString(),
        extra: {},
      );

      // Mock history
      _membershipHistory = [
        Membership(
          id: 2,
          user: userId,
          gym: 1,
          date: DateTime.now().subtract(const Duration(days: 210)).toString(),
          extra: {
            'plan': '3개월 이용권',
            'startDate': DateTime.now().subtract(const Duration(days: 210)).toIso8601String(),
            'endDate': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
            'price': 270000,
            'status': 'expired',
          },
        ),
      ];

      // Mock statistics
      _stats = {
        'totalVisitsThisMonth': 12,
        'averageVisitsPerWeek': 3.5,
        'currentStreak': 5,
        'longestStreak': 14,
      };

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Purchase new membership
  Future<bool> purchaseMembership({
    required int userId,
    required int gymId,
    required String plan,
    required int price,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual payment API
      await Future.delayed(const Duration(seconds: 2));

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

      // Create new membership
      final newMembership = Membership(
        id: DateTime.now().millisecondsSinceEpoch,
        user: userId,
        gym: gymId,
        date: DateTime.now().toString(),
        extra: {
          'plan': plan,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'price': price,
          'status': 'active',
          'paymentMethod': paymentMethod,
          'features': ['무제한 이용', '락커 제공'],
          'totalVisits': 0,
          'pauseAvailable': true,
        },
      );

      // Move current active to history if exists
      if (_activeMembership != null) {
        _membershipHistory.insert(0, _activeMembership!);
      }

      _activeMembership = newMembership;

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
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 2));

      final currentEndDate = DateTime.parse(_activeMembership!.extra['endDate'] as String);
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

      // Update membership
      _activeMembership!.extra['endDate'] = newEndDate.toIso8601String();
      _activeMembership!.extra['extendedPlan'] = plan;
      _activeMembership!.extra['extendedPrice'] = price;

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
