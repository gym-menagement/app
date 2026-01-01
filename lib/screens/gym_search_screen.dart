import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/gym_card.dart';
import '../components/gym_button.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../providers/gym_provider.dart';
import '../model/gym.dart';
import 'membership_plan_screen.dart';

class GymSearchScreen extends StatefulWidget {
  const GymSearchScreen({super.key});

  @override
  State<GymSearchScreen> createState() => _GymSearchScreenState();
}

class _GymSearchScreenState extends State<GymSearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load gyms when screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gymProvider = context.read<GymProvider>();
      if (gymProvider.allGyms.isEmpty) {
        gymProvider.loadGyms();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<GymProvider>().search(query);
  }

  void _showFilterBottomSheet() {
    final gymProvider = context.read<GymProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => _FilterBottomSheet(
            sortBy: gymProvider.sortBy,
            selectedFacilities: gymProvider.selectedFacilities,
            onApply: (sortBy, facilities) {
              gymProvider.setSortBy(sortBy);
              gymProvider.setFacilities(facilities);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('체육관 찾기'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<GymProvider>(
        builder: (context, gymProvider, child) {
          final isSearching = gymProvider.searchQuery.isNotEmpty;

          return Column(
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
                              isSearching
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: AppColors.grey500,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      gymProvider.clearSearch();
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
              if (gymProvider.hasActiveFilters &&
                  (gymProvider.selectedFacilities.isNotEmpty ||
                      gymProvider.sortBy != 'distance'))
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (gymProvider.sortBy != 'distance')
                          Chip(
                            label: Text(_getSortLabel(gymProvider.sortBy)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              gymProvider.setSortBy('distance');
                            },
                          ),
                        ...gymProvider.selectedFacilities.map((facility) {
                          return Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.sm),
                            child: Chip(
                              label: Text(facility),
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                gymProvider.toggleFacility(facility);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

              // Results count
              // Padding(
              //   padding: const EdgeInsets.symmetric(
              //     horizontal: AppSpacing.md,
              //     vertical: AppSpacing.sm,
              //   ),
              //   child: Row(
              //     children: [
              //       Text(
              //         '검색 결과 ${gymProvider.filteredGyms.length}개',
              //         style: AppTextStyles.bodyMedium.copyWith(
              //           color: AppColors.grey700,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),

              // Gym List
              Expanded(
                child:
                    gymProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : gymProvider.filteredGyms.isEmpty
                        ? _buildEmptyState(isSearching)
                        : RefreshIndicator(
                          onRefresh: () => gymProvider.loadGyms(),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: gymProvider.filteredGyms.length,
                            itemBuilder: (context, index) {
                              final gym = gymProvider.filteredGyms[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.md,
                                ),
                                child: GymListCard(
                                  gym: gym,
                                  isFavorite: gymProvider.isFavorite(gym.id),
                                  distance: gym.extra['distance'] as double?,
                                  showDistance: true,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MembershipPlanScreen(
                                          gym: gym,
                                        ),
                                      ),
                                    );
                                  },
                                  onFavorite: () {
                                    gymProvider.toggleFavorite(gym.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          gymProvider.isFavorite(gym.id)
                                              ? '즐겨찾기에 추가되었습니다'
                                              : '즐겨찾기에서 제거되었습니다',
                                        ),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearching ? Icons.search_off : Icons.fitness_center_outlined,
            size: 80,
            color: AppColors.grey400,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            isSearching ? '검색 결과가 없습니다' : '주변 체육관이 없습니다',
            style: AppTextStyles.titleMedium.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isSearching ? '다른 검색어로 시도해보세요' : '위치 권한을 확인하거나 다른 지역을 검색해보세요',
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
      selectedColor: AppColors.primaryLight,
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isSelected ? AppColors.primary : AppColors.grey700,
      ),
    );
  }
}
