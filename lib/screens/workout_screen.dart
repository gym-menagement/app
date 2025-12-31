import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../components/gym_card.dart';
import '../components/gym_button.dart';
import '../config/app_colors.dart';
import '../config/app_text_styles.dart';
import '../config/app_spacing.dart';
import '../model/attendance.dart';
import '../model/workoutlog.dart';
import '../providers/workout_provider.dart';
import '../providers/auth_provider.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final workoutProvider = context.read<WorkoutProvider>();

      final userId = authProvider.currentUser?.id;
      if (userId != null) {
        workoutProvider.setUserId(userId);
        workoutProvider.setSelectedDate(_selectedDay!);

        // 현재 월의 데이터 로드
        final firstDay = DateTime(_focusedDay.year, _focusedDay.month, 1);
        final lastDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
        workoutProvider.loadAll(startDate: firstDay, endDate: lastDay);
      }
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      final workoutProvider = context.read<WorkoutProvider>();
      workoutProvider.setSelectedDate(selectedDay);
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;

    // 월이 변경되면 해당 월의 데이터 로드
    final workoutProvider = context.read<WorkoutProvider>();
    final firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDay = DateTime(focusedDay.year, focusedDay.month + 1, 0);
    workoutProvider.loadAll(startDate: firstDay, endDate: lastDay);
  }

  void _showAddWorkoutDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddWorkoutDialog(
        selectedDate: _selectedDay ?? DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<WorkoutProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final selectedDayAttendances =
                provider.getAttendancesByDate(_selectedDay ?? DateTime.now());
            final selectedDayWorkouts =
                provider.getWorkoutlogsByDate(_selectedDay ?? DateTime.now());
            final monthlyCount = provider.getMonthlyAttendanceCount(_focusedDay);

            return RefreshIndicator(
              onRefresh: provider.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                children: [
                  // 달력
                  GymCard(
                    margin: const EdgeInsets.all(AppSpacing.md),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      children: [
                        // 월별 출석 통계
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                color: AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '이번 달 출석: $monthlyCount일',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TableCalendar(
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: _focusedDay,
                          calendarFormat: _calendarFormat,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: _onDaySelected,
                          onFormatChanged: (format) {
                            if (_calendarFormat != format) {
                              setState(() {
                                _calendarFormat = format;
                              });
                            }
                          },
                          onPageChanged: _onPageChanged,
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            markersMaxCount: 1,
                          ),
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: AppTextStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          eventLoader: (day) {
                            // 출석 기록이 있는 날짜에 마커 표시
                            final attendances =
                                provider.getAttendancesByDate(day);
                            return attendances.isEmpty ? [] : [attendances];
                          },
                        ),
                      ],
                    ),
                  ),

                  // 선택된 날짜의 출석 정보
                  if (selectedDayAttendances.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '출석 기록',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...selectedDayAttendances.map((attendance) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        child: _buildAttendanceCard(attendance),
                      );
                    }),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // 선택된 날짜의 운동 일지
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '운동 일지',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, size: 28),
                          color: AppColors.primary,
                          onPressed: _showAddWorkoutDialog,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  if (selectedDayWorkouts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        children: [
                          Icon(
                            Icons.note_add_outlined,
                            size: 60,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            '운동 일지가 없습니다',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '오늘의 운동을 기록해보세요!',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grey400,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...selectedDayWorkouts.map((workout) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        child: _buildWorkoutCard(workout),
                      );
                    }),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(Attendance attendance) {
    return GymCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '출석 완료',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.grey500,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      _formatTime(attendance.checkintime),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grey600,
                      ),
                    ),
                    if (attendance.checkouttime.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '→',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        _formatTime(attendance.checkouttime),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (attendance.duration > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Text(
                '${attendance.duration}분',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Workoutlog workout) {
    return GymCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () {
        _showWorkoutDetail(workout);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  workout.exercisename,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.xs,
            children: [
              if (workout.sets > 0)
                _buildWorkoutStat('세트', '${workout.sets}'),
              if (workout.reps > 0)
                _buildWorkoutStat('횟수', '${workout.reps}'),
              if (workout.weight > 0)
                _buildWorkoutStat('무게', '${workout.weight}kg'),
              if (workout.duration > 0)
                _buildWorkoutStat('시간', '${workout.duration}분'),
              if (workout.calories > 0)
                _buildWorkoutStat('칼로리', '${workout.calories}kcal'),
            ],
          ),
          if (workout.note.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              workout.note,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.grey600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWorkoutStat(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.grey600,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showWorkoutDetail(Workoutlog workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WorkoutDetailSheet(workout: workout),
    );
  }

  String _formatTime(String dateTimeStr) {
    if (dateTimeStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }
}

// 운동 일지 상세 보기
class _WorkoutDetailSheet extends StatelessWidget {
  final Workoutlog workout;

  const _WorkoutDetailSheet({required this.workout});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLarge),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // 운동 이름
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSmall),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: AppColors.primary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      workout.exercisename,
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),

              // 운동 상세 정보
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (workout.sets > 0) ...[
                      _buildDetailRow('세트', '${workout.sets}세트'),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (workout.reps > 0) ...[
                      _buildDetailRow('횟수', '${workout.reps}회'),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (workout.weight > 0) ...[
                      _buildDetailRow('무게', '${workout.weight}kg'),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (workout.duration > 0) ...[
                      _buildDetailRow('시간', '${workout.duration}분'),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (workout.calories > 0) ...[
                      _buildDetailRow('칼로리', '${workout.calories}kcal'),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    _buildDetailRow('날짜', _formatDate(workout.date)),
                  ],
                ),
              ),

              if (workout.note.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '메모',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMedium),
                  ),
                  child: Text(
                    workout.note,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.lg),

              // 버튼들
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmDialog(context, workout);
                      },
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        side: BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMedium),
                        ),
                      ),
                      child: Text(
                        '삭제',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMedium),
                        ),
                      ),
                      child: Text(
                        '닫기',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.grey600,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showDeleteConfirmDialog(BuildContext context, Workoutlog workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('운동 일지 삭제'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final provider = context.read<WorkoutProvider>();
              final success = await provider.deleteWorkoutlog(workout);
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('운동 일지가 삭제되었습니다')),
                  );
                }
              }
            },
            child: Text(
              '삭제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// 운동 일지 추가 다이얼로그
class _AddWorkoutDialog extends StatefulWidget {
  final DateTime selectedDate;

  const _AddWorkoutDialog({required this.selectedDate});

  @override
  State<_AddWorkoutDialog> createState() => _AddWorkoutDialogState();
}

class _AddWorkoutDialogState extends State<_AddWorkoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _exerciseNameController = TextEditingController();
  final _setsController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _exerciseNameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _saveWorkout() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final workoutProvider = context.read<WorkoutProvider>();

    final workout = Workoutlog(
      user: authProvider.currentUser?.id ?? 0,
      exercisename: _exerciseNameController.text,
      sets: int.tryParse(_setsController.text) ?? 0,
      reps: int.tryParse(_repsController.text) ?? 0,
      weight: int.tryParse(_weightController.text) ?? 0,
      duration: int.tryParse(_durationController.text) ?? 0,
      calories: int.tryParse(_caloriesController.text) ?? 0,
      note: _noteController.text,
      date: widget.selectedDate.toIso8601String(),
    );

    final success = await workoutProvider.addWorkoutlog(workout);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('운동 일지가 저장되었습니다')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // 상단 헤더
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.grey200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  '운동 일지 작성',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 폼 내용
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 운동 이름
                    _buildTossTextField(
                      controller: _exerciseNameController,
                      label: '운동 이름',
                      placeholder: '벤치프레스',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '운동 이름을 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // 세트 & 횟수
                    Row(
                      children: [
                        Expanded(
                          child: _buildTossTextField(
                            controller: _setsController,
                            label: '세트',
                            placeholder: '3',
                            keyboardType: TextInputType.number,
                            suffix: '세트',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTossTextField(
                            controller: _repsController,
                            label: '횟수',
                            placeholder: '10',
                            keyboardType: TextInputType.number,
                            suffix: '회',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 무게 & 시간
                    Row(
                      children: [
                        Expanded(
                          child: _buildTossTextField(
                            controller: _weightController,
                            label: '무게',
                            placeholder: '50',
                            keyboardType: TextInputType.number,
                            suffix: 'kg',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTossTextField(
                            controller: _durationController,
                            label: '시간',
                            placeholder: '30',
                            keyboardType: TextInputType.number,
                            suffix: '분',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 칼로리
                    _buildTossTextField(
                      controller: _caloriesController,
                      label: '칼로리',
                      placeholder: '200',
                      keyboardType: TextInputType.number,
                      suffix: 'kcal',
                    ),
                    const SizedBox(height: 24),

                    // 메모
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '메모',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.grey700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText: '오늘의 운동은 어땠나요?',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.grey400,
                            ),
                            filled: true,
                            fillColor: AppColors.grey100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                          maxLines: 4,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 하단 저장 버튼
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: GymButton(
                text: '저장하기',
                onPressed: _saveWorkout,
                size: GymButtonSize.large,
                fullWidth: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTossTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    String? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey400,
            ),
            suffixText: suffix,
            suffixStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: AppColors.grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
