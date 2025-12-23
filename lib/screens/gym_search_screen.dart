import 'package:flutter/material.dart';
import '../components/gym_layout.dart';
import '../components/gym_card.dart';
import '../components/gym_button.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../model/gym.dart';

class GymSearchScreen extends StatefulWidget {
  const GymSearchScreen({super.key});

  @override
  State<GymSearchScreen> createState() => _GymSearchScreenState();
}

class _GymSearchScreenState extends State<GymSearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<Gym> _allGyms = [];
  List<Gym> _filteredGyms = [];
  Set<int> _favoriteGymIds = {};

  bool _isLoading = false;
  bool _isSearching = false;

  // Filter states
  String _sortBy = 'distance'; // distance, name, newest
  Set<String> _selectedFacilities = {};

  @override
  void initState() {
    super.initState();
    _loadGyms();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadGyms() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data
      final mockGyms = [
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

      if (mounted) {
        setState(() {
          _allGyms = mockGyms;
          _filteredGyms = mockGyms;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('데이터 로드 실패: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    _applyFilters();
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();

    setState(() {
      _filteredGyms =
          _allGyms.where((gym) {
            // Search filter
            if (query.isNotEmpty) {
              final matchesName = gym.name.toLowerCase().contains(query);
              final matchesAddress = gym.address.toLowerCase().contains(query);
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
    });
  }

  void _toggleFavorite(Gym gym) {
    setState(() {
      if (_favoriteGymIds.contains(gym.id)) {
        _favoriteGymIds.remove(gym.id);
      } else {
        _favoriteGymIds.add(gym.id);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _favoriteGymIds.contains(gym.id) ? '즐겨찾기에 추가되었습니다' : '즐겨찾기에서 제거되었습니다',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => _FilterBottomSheet(
            sortBy: _sortBy,
            selectedFacilities: _selectedFacilities,
            onApply: (sortBy, facilities) {
              setState(() {
                _sortBy = sortBy;
                _selectedFacilities = facilities;
              });
              _applyFilters();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GymLayout(
      title: '체육관 검색',
      scrollable: false,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: '체육관 이름 또는 주소로 검색',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.grey400,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.grey500,
                      ),
                      suffixIcon:
                          _isSearching
                              ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: AppColors.grey500,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged('');
                                },
                              )
                              : null,
                      filled: true,
                      fillColor: AppColors.grey100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMedium,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: _showFilterBottomSheet,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Filter Chips
          if (_selectedFacilities.isNotEmpty || _sortBy != 'distance')
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_sortBy != 'distance')
                      Chip(
                        label: Text(_getSortLabel(_sortBy)),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () {
                          setState(() => _sortBy = 'distance');
                          _applyFilters();
                        },
                      ),
                    ..._selectedFacilities.map((facility) {
                      return Padding(
                        padding: const EdgeInsets.only(left: AppSpacing.sm),
                        child: Chip(
                          label: Text(facility),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          onDeleted: () {
                            setState(
                              () => _selectedFacilities.remove(facility),
                            );
                            _applyFilters();
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  '검색 결과 ${_filteredGyms.length}개',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.grey700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Gym List
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredGyms.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                      onRefresh: _loadGyms,
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: _filteredGyms.length,
                        itemBuilder: (context, index) {
                          final gym = _filteredGyms[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: GymCard(
                              gym: gym,
                              isFavorite: _favoriteGymIds.contains(gym.id),
                              distance: gym.extra['distance'] as double?,
                              showDistance: true,
                              onTap: () {
                                // TODO: Navigate to gym detail
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('${gym.name} 상세 페이지')),
                                );
                              },
                              onFavorite: () => _toggleFavorite(gym),
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isSearching ? Icons.search_off : Icons.fitness_center_outlined,
            size: 80,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _isSearching ? '검색 결과가 없습니다' : '주변 체육관이 없습니다',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _isSearching ? '다른 검색어로 시도해보세요' : '위치 권한을 확인하거나 다른 지역을 검색해보세요',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'name':
        return '이름순';
      case 'newest':
        return '최신순';
      case 'distance':
      default:
        return '거리순';
    }
  }
}

// Filter Bottom Sheet
class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet({
    required this.sortBy,
    required this.selectedFacilities,
    required this.onApply,
  });

  final String sortBy;
  final Set<String> selectedFacilities;
  final Function(String sortBy, Set<String> facilities) onApply;

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _sortBy;
  late Set<String> _selectedFacilities;

  final List<String> _availableFacilities = [
    'PT',
    '샤워실',
    '주차',
    '그룹수업',
    '수영장',
    '락커룸',
    '사우나',
  ];

  @override
  void initState() {
    super.initState();
    _sortBy = widget.sortBy;
    _selectedFacilities = Set.from(widget.selectedFacilities);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.lg,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('필터', style: AppTextStyles.h3),
              TextButton(
                onPressed: () {
                  setState(() {
                    _sortBy = 'distance';
                    _selectedFacilities.clear();
                  });
                },
                child: const Text('초기화'),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Sort By
          Text(
            '정렬',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Wrap(
            spacing: AppSpacing.sm,
            children: [
              _buildSortChip('distance', '거리순'),
              _buildSortChip('name', '이름순'),
              _buildSortChip('newest', '최신순'),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Facilities
          Text(
            '편의시설',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children:
                _availableFacilities.map((facility) {
                  return _buildFacilityChip(facility);
                }).toList(),
          ),

          const SizedBox(height: AppSpacing.xl),

          GymButton(
            text: '적용하기',
            onPressed: () {
              widget.onApply(_sortBy, _selectedFacilities);
              Navigator.pop(context);
            },
            size: GymButtonSize.large,
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String value, String label) {
    final isSelected = _sortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _sortBy = value);
      },
      selectedColor: AppColors.primary,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isSelected ? Colors.white : AppColors.grey700,
      ),
    );
  }

  Widget _buildFacilityChip(String facility) {
    final isSelected = _selectedFacilities.contains(facility);
    return FilterChip(
      label: Text(facility),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedFacilities.add(facility);
          } else {
            _selectedFacilities.remove(facility);
          }
        });
      },
      selectedColor: AppColors.primaryContainer,
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isSelected ? AppColors.primary : AppColors.grey700,
      ),
    );
  }
}
