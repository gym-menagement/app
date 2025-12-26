import 'package:flutter/foundation.dart';
import '../model/gym.dart';
import '../config/http.dart';
import '../config/config.dart';

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
  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedFacilities.isNotEmpty ||
      _sortBy != 'distance';

  /// Load gyms from API
  Future<void> loadGyms({int page = 0, int pageSize = 100}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // GET /api/gym?page=0&pageSize=100
      final result = await Http.get(Config.apiGym, {
        'page': page,
        'pageSize': pageSize,
      });

      if (result != null && result['content'] != null) {
        final List<dynamic> content = result['content'];
        _allGyms = content.map((json) => Gym.fromJson(json)).toList();
        _isLoading = false;
        applyFilters();
      } else {
        _error = '체육관 목록을 불러올 수 없습니다.';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = '네트워크 오류가 발생했습니다: ${e.toString()}';
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
    _filteredGyms =
        _allGyms.where((gym) {
          // Search filter
          if (_searchQuery.isNotEmpty) {
            final matchesName = gym.name.toLowerCase().contains(_searchQuery);
            final matchesAddress = gym.address.toLowerCase().contains(
              _searchQuery,
            );
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

  /// Get gym by ID from API
  Future<Gym?> getGymById(int id) async {
    try {
      // GET /api/gym/{id}
      final result = await Http.get('${Config.apiGym}/$id');

      if (result != null) {
        return Gym.fromJson(result);
      }
      return null;
    } catch (e) {
      _error = '체육관 정보를 불러올 수 없습니다: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  /// Search gyms by name from API
  Future<void> searchGymsByName(String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // GET /api/gym/search/name?name=xxx
      final result = await Http.get('${Config.apiGym}/search/name', {
        'name': name,
      });

      if (result != null && result is List) {
        _allGyms = result.map((json) => Gym.fromJson(json)).toList();
        _isLoading = false;
        applyFilters();
      } else {
        _error = '검색 결과가 없습니다.';
        _allGyms = [];
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = '검색 중 오류가 발생했습니다: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
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
