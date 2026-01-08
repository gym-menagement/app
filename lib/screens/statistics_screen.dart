import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../components/gym_card.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../providers/statistics_provider.dart';
import '../providers/workout_provider.dart';
import '../providers/auth_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final workoutProvider = context.read<WorkoutProvider>();
    final statisticsProvider = context.read<StatisticsProvider>();

    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      print('Current User ID: $userId');
      workoutProvider.setUserId(userId);

      // 전체 데이터 로드 (날짜 제한 없음)
      await workoutProvider.loadAll();

      print('Loaded attendances: ${workoutProvider.attendances.length}');
      print('Loaded workoutlogs: ${workoutProvider.workoutlogs.length}');

      // 통계 데이터 설정
      statisticsProvider.setData(
        workoutProvider.attendances,
        workoutProvider.workoutlogs,
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '운동 통계',
          style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey500,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
          tabs: const [Tab(text: '개요'), Tab(text: '운동 분석'), Tab(text: '개인 기록')],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadData,
                child: TabBarView(
                  controller: _tabController,
                  children: const [
                    _OverviewTab(),
                    _AnalysisTab(),
                    _RecordsTab(),
                  ],
                ),
              ),
    );
  }
}

// 개요 탭
class _OverviewTab extends StatelessWidget {
  const _OverviewTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 주요 통계 카드들
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_today,
                      label: '총 출석',
                      value: '${provider.totalAttendanceDays}일',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.fitness_center,
                      label: '운동 기록',
                      value: '${provider.totalWorkoutLogs}회',
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department,
                      label: '소모 칼로리',
                      value: '${_formatNumber(provider.totalCalories)}kcal',
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.timer,
                      label: '운동 시간',
                      value: '${_formatDuration(provider.totalDuration)}',
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.trending_up,
                      label: '최장 연속',
                      value: '${provider.longestStreak}일',
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.whatshot,
                      label: '현재 연속',
                      value: '${provider.currentStreak}일',
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // 주간 출석 그래프
              Text(
                '주간 출석 추이',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GymCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  height: 250,
                  child: _WeeklyAttendanceChart(
                    data: provider.getWeeklyAttendanceStats(),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 월별 출석 그래프
              Text(
                '월별 출석 통계',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GymCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  height: 250,
                  child: _MonthlyAttendanceChart(
                    data: provider.getMonthlyAttendanceStats(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
    }
    return '${minutes}m';
  }
}

// 운동 분석 탭
class _AnalysisTab extends StatelessWidget {
  const _AnalysisTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        final exerciseStats = provider.getExerciseStats();
        final dailyStats = provider.getDailyStats(days: 30);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 최근 30일 칼로리 추이
              Text(
                '최근 30일 칼로리 소모',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              GymCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  height: 250,
                  child: _CaloriesLineChart(data: dailyStats),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 운동 종류별 분석
              Text(
                '운동 종류별 분석',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '가장 많이 한 운동 TOP 10',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              if (exerciseStats.isEmpty)
                GymCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 60,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '운동 기록이 없습니다',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...exerciseStats.take(10).map((stat) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _ExerciseStatCard(stat: stat),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

// 개인 기록 탭
class _RecordsTab extends StatelessWidget {
  const _RecordsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, provider, child) {
        final records = provider.getPersonalRecords();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '개인 최고 기록',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '운동별 최고 무게 기록',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.grey600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              if (records.isEmpty)
                GymCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          size: 60,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          '개인 기록이 없습니다',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '무게를 기록하여 개인 기록을 세워보세요!',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.grey400,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...records.asMap().entries.map((entry) {
                  final index = entry.key;
                  final record = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _PersonalRecordCard(record: record, rank: index + 1),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}

// 통계 카드 위젯
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GymCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// 주간 출석 차트
class _WeeklyAttendanceChart extends StatelessWidget {
  final List<WeeklyStats> data;

  const _WeeklyAttendanceChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          '데이터가 없습니다',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            (data
                        .map((e) => e.attendanceCount)
                        .reduce((a, b) => a > b ? a : b) +
                    2)
                .toDouble(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()}일',
                AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  final stat = data[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${stat.weekNumber}주',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.grey600,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppColors.grey300, strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups:
            data.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.attendanceCount.toDouble(),
                    color: AppColors.primary,
                    width: 16,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}

// 월별 출석 차트
class _MonthlyAttendanceChart extends StatelessWidget {
  final Map<String, int> data;

  const _MonthlyAttendanceChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          '데이터가 없습니다',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
        ),
      );
    }

    final sortedEntries =
        data.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY:
            (sortedEntries.map((e) => e.value).reduce((a, b) => a > b ? a : b) +
                    5)
                .toDouble(),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()}일',
                AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < sortedEntries.length) {
                  final monthKey = sortedEntries[value.toInt()].key;
                  final month = monthKey.split('-')[1];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${month}월',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.grey600,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppColors.grey300, strokeWidth: 1);
          },
        ),
        borderData: FlBorderData(show: false),
        barGroups:
            sortedEntries.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.value.toDouble(),
                    color: AppColors.success,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}

// 칼로리 라인 차트
class _CaloriesLineChart extends StatelessWidget {
  final List<DailyStats> data;

  const _CaloriesLineChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          '데이터가 없습니다',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.grey500),
        ),
      );
    }

    final maxCalories = data
        .map((e) => e.totalCalories)
        .reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: AppColors.grey300, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < data.length) {
                  if (value.toInt() % 5 == 0) {
                    final date = data[value.toInt()].date;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${date.month}/${date.day}',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    );
                  }
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.grey600,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: (maxCalories + 100).toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots:
                data.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value.totalCalories.toDouble(),
                  );
                }).toList(),
            isCurved: true,
            color: AppColors.warning,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.warning.withOpacity(0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()}kcal',
                  AppTextStyles.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

// 운동 통계 카드
class _ExerciseStatCard extends StatelessWidget {
  final ExerciseStats stat;

  const _ExerciseStatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return GymCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Icon(
              Icons.fitness_center,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.exerciseName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${stat.count}회 수행 · 총 ${stat.totalSets}세트',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (stat.maxWeight > 0) ...[
                Text(
                  '${stat.maxWeight}kg',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '최고 무게',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ] else if (stat.maxReps > 0) ...[
                Text(
                  '${stat.maxReps}회',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '최고 횟수',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// 개인 기록 카드
class _PersonalRecordCard extends StatelessWidget {
  final PersonalRecord record;
  final int rank;

  const _PersonalRecordCard({required this.record, required this.rank});

  @override
  Widget build(BuildContext context) {
    Color rankColor;
    IconData rankIcon;

    if (rank == 1) {
      rankColor = const Color(0xFFFFD700); // Gold
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0); // Silver
      rankIcon = Icons.emoji_events;
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32); // Bronze
      rankIcon = Icons.emoji_events;
    } else {
      rankColor = AppColors.grey500;
      rankIcon = Icons.military_tech;
    }

    return GymCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Center(child: Icon(rankIcon, color: rankColor, size: 24)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.exerciseName,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatDate(record.achievedDate),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${record.maxWeight}kg',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: rankColor,
                ),
              ),
              if (record.maxReps > 0)
                Text(
                  '${record.maxReps}회',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.grey600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
