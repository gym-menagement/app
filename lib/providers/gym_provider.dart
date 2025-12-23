import 'package:flutter/foundation.dart';
import '../model/gym.dart';

/// Gym data and search state management provider
/// Manages gym listings, search filters, favorites, and location-based queries
class GymProvider extends ChangeNotifier {
  List<Gym> _allGyms = [];
  List<Gym> _filteredGyms = [];
  Set<int> _favoriteGymIds = {};

  bool _isLoading = false;
  String? _error;

  // Search and filter state
  String _searchQuery = '';
  String _sortBy = 'distance'; // distance, name, newest
  Set<String> _selectedFacilities = {};

  // Location state
  double? _userLatitude;
  double? _userLongitude;

  // Getters
  List<Gym> get allGyms => _allGyms;
  List<Gym> get filteredGyms => _filteredGyms;
  Set<int> get favoriteGymIds => _favoriteGymIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get sortBy => _sortBy;
  Set<String> get selectedFacilities => _selectedFacilities;
  bool get hasActiveFilters => _searchQuery.isNotEmpty || _selectedFacilities.isNotEmpty || _sortBy != 'distance';

  /// Load gyms from API
  Future<void> loadGyms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      _allGyms = [
        Gym(
          id: 1,
          name: '강남 피트니스',
          address: '서울 강남구 테헤란로 123',
          tel: '02-1234-5678',
          user: 1,
          date: DateTime.now().toString(),
          extra: {
            'facilities': ['PT', '샤워실', '주차'],
            'distance': 0.5,
          },
        ),
        Gym(
          id: 2,
          name: '역삼 헬스클럽',
          address: '서울 강남구 역삼동 456',
          tel: '02-2345-6789',
          user: 1,
          date: DateTime.now().toString(),
          extra: {
            'facilities': ['그룹수업', '샤워실'],
            'distance': 1.2,
          },
        ),
        Gym(
          id: 3,
          name: '삼성 스포츠센터',
          address: '서울 강남구 삼성동 789',
          tel: '02-3456-7890',
          user: 1,
          date: DateTime.now().toString(),
          extra: {
            'facilities': ['수영장', 'PT', '주차', '샤워실'],
            'distance': 2.1,
          },
        ),
        Gym(
          id: 4,
          name: '논현 GYM',
          address: '서울 강남구 논현동 321',
          tel: '02-4567-8901',
          user: 1,
          date: DateTime.now().toString(),
          extra: {
            'facilities': ['PT', '락커룸'],
            'distance': 0.8,
          },
        ),
        Gym(
          id: 5,
          name: '도곡 휘트니스',
          address: '서울 강남구 도곡동 654',
          tel: '02-5678-9012',
          user: 1,
          date: DateTime.now().toString(),
          extra: {
            'facilities': ['그룹수업', '샤워실', '주차'],
            'distance': 1.5,
          },
        ),
      ];

      _isLoading = false;
      applyFilters();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search gyms by query
  void search(String query) {
    _searchQuery = query.toLowerCase().trim();
    applyFilters();
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery = '';
    applyFilters();
  }

  /// Set sort order
  void setSortBy(String sortBy) {
    _sortBy = sortBy;
    applyFilters();
  }

  /// Toggle facility filter
  void toggleFacility(String facility) {
    if (_selectedFacilities.contains(facility)) {
      _selectedFacilities.remove(facility);
    } else {
      _selectedFacilities.add(facility);
    }
    applyFilters();
  }

  /// Set facility filters
  void setFacilities(Set<String> facilities) {
    _selectedFacilities = Set.from(facilities);
    applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _sortBy = 'distance';
    _selectedFacilities.clear();
    applyFilters();
  }

  /// Apply current filters and sorting
  void applyFilters() {
    _filteredGyms = _allGyms.where((gym) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesName = gym.name.toLowerCase().contains(_searchQuery);
        final matchesAddress = gym.address.toLowerCase().contains(_searchQuery);
        if (!matchesName && !matchesAddress) return false;
      }

      // Facility filter
      if (_selectedFacilities.isNotEmpty) {
        final gymFacilities = gym.extra['facilities'] as List? ?? [];
        final hasAllFacilities = _selectedFacilities.every(
          (facility) => gymFacilities.contains(facility),
        );
        if (!hasAllFacilities) return false;
      }

      return true;
    }).toList();

    // Apply sorting
    _filteredGyms.sort((a, b) {
      switch (_sortBy) {
        case 'name':
          return a.name.compareTo(b.name);
        case 'newest':
          return b.date.compareTo(a.date);
        case 'distance':
        default:
          final distanceA = a.extra['distance'] as double? ?? 999.0;
          final distanceB = b.extra['distance'] as double? ?? 999.0;
          return distanceA.compareTo(distanceB);
      }
    });

    notifyListeners();
  }

  /// Toggle favorite status
  void toggleFavorite(int gymId) {
    if (_favoriteGymIds.contains(gymId)) {
      _favoriteGymIds.remove(gymId);
    } else {
      _favoriteGymIds.add(gymId);
    }
    notifyListeners();

    // TODO: Sync with backend
  }

  /// Check if gym is favorite
  bool isFavorite(int gymId) {
    return _favoriteGymIds.contains(gymId);
  }

  /// Get gym by ID
  Gym? getGymById(int id) {
    try {
      return _allGyms.firstWhere((gym) => gym.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Load favorite gyms from backend
  Future<void> loadFavorites(int userId) async {
    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(milliseconds: 500));

      // Mock: Load saved favorites
      _favoriteGymIds = {1, 3};
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Update user location
  void updateUserLocation(double latitude, double longitude) {
    _userLatitude = latitude;
    _userLongitude = longitude;

    // Recalculate distances
    // TODO: Implement actual distance calculation
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
