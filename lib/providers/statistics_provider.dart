import 'package:flutter/material.dart';
import '../model/attendance.dart';
import '../model/workoutlog.dart';

class ExerciseStats {
  final String exerciseName;
  final int count;
  final int maxWeight;
  final int maxReps;
  final int totalSets;

  ExerciseStats({
    required this.exerciseName,
    required this.count,
    required this.maxWeight,
    required this.maxReps,
    required this.totalSets,
  });
}

class DailyStats {
  final DateTime date;
  final int attendanceCount;
  final int workoutCount;
  final int totalCalories;
  final int totalDuration;

  DailyStats({
    required this.date,
    required this.attendanceCount,
    required this.workoutCount,
    required this.totalCalories,
    required this.totalDuration,
  });
}

class WeeklyStats {
  final int weekNumber;
  final int year;
  final int attendanceCount;
  final int workoutCount;
  final int totalCalories;

  WeeklyStats({
    required this.weekNumber,
    required this.year,
    required this.attendanceCount,
    required this.workoutCount,
    required this.totalCalories,
  });
}

class PersonalRecord {
  final String exerciseName;
  final int maxWeight;
  final int maxReps;
  final DateTime achievedDate;

  PersonalRecord({
    required this.exerciseName,
    required this.maxWeight,
    required this.maxReps,
    required this.achievedDate,
  });
}

class StatisticsProvider extends ChangeNotifier {
  List<Attendance> _attendances = [];
  List<Workoutlog> _workoutlogs = [];
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 데이터 설정
  void setData(List<Attendance> attendances, List<Workoutlog> workoutlogs) {
    _attendances = attendances;
    _workoutlogs = workoutlogs;
    notifyListeners();
  }

  // 총 출석 일수
  int get totalAttendanceDays {
    final uniqueDates = <String>{};
    for (var attendance in _attendances) {
      try {
        final date = DateTime.parse(
          attendance.checkintime.isNotEmpty
              ? attendance.checkintime
              : attendance.date,
        );
        uniqueDates.add(_formatDateKey(date));
      } catch (e) {
        // 날짜 파싱 실패 시 무시
      }
    }
    return uniqueDates.length;
  }

  // 총 운동 일지 수
  int get totalWorkoutLogs => _workoutlogs.length;

  // 총 소모 칼로리
  int get totalCalories {
    return _workoutlogs.fold(0, (sum, log) => sum + log.calories);
  }

  // 총 운동 시간 (분)
  int get totalDuration {
    return _workoutlogs.fold(0, (sum, log) => sum + log.duration);
  }

  // 최장 연속 출석 일수
  int get longestStreak {
    if (_attendances.isEmpty) return 0;

    final sortedDates = <DateTime>[];
    for (var attendance in _attendances) {
      try {
        final date = DateTime.parse(
          attendance.checkintime.isNotEmpty
              ? attendance.checkintime
              : attendance.date,
        );
        sortedDates.add(DateTime(date.year, date.month, date.day));
      } catch (e) {
        // 날짜 파싱 실패 시 무시
      }
    }

    if (sortedDates.isEmpty) return 0;

    sortedDates.sort();
    final uniqueDates = sortedDates.toSet().toList()..sort();

    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < uniqueDates.length; i++) {
      final diff = uniqueDates[i].difference(uniqueDates[i - 1]).inDays;
      if (diff == 1) {
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  // 현재 연속 출석 일수
  int get currentStreak {
    if (_attendances.isEmpty) return 0;

    final sortedDates = <DateTime>[];
    for (var attendance in _attendances) {
      try {
        final date = DateTime.parse(
          attendance.checkintime.isNotEmpty
              ? attendance.checkintime
              : attendance.date,
        );
        sortedDates.add(DateTime(date.year, date.month, date.day));
      } catch (e) {
        // 날짜 파싱 실패 시 무시
      }
    }

    if (sortedDates.isEmpty) return 0;

    sortedDates.sort();
    final uniqueDates =
        sortedDates.toSet().toList()..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    // 오늘이나 어제에 출석했는지 확인
    if (!uniqueDates.contains(todayDate) && !uniqueDates.contains(yesterday)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate =
        uniqueDates.contains(todayDate) ? todayDate : yesterday;

    for (var date in uniqueDates) {
      if (date.isAtSameMomentAs(checkDate)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(checkDate)) {
        break;
      }
    }

    return streak;
  }

  // 주간 출석 통계 (최근 12주)
  List<WeeklyStats> getWeeklyAttendanceStats() {
    final now = DateTime.now();
    final stats = <int, WeeklyStats>{};

    // 최근 12주 초기화
    for (int i = 0; i < 12; i++) {
      final weekDate = now.subtract(Duration(days: i * 7));
      final weekNumber = _getWeekNumber(weekDate);
      final year = weekDate.year;
      final key = year * 100 + weekNumber;

      stats[key] = WeeklyStats(
        weekNumber: weekNumber,
        year: year,
        attendanceCount: 0,
        workoutCount: 0,
        totalCalories: 0,
      );
    }

    // 출석 데이터 집계
    for (var attendance in _attendances) {
      try {
        final date = DateTime.parse(
          attendance.checkintime.isNotEmpty
              ? attendance.checkintime
              : attendance.date,
        );
        final weekNumber = _getWeekNumber(date);
        final year = date.year;
        final key = year * 100 + weekNumber;

        if (stats.containsKey(key)) {
          final current = stats[key]!;
          stats[key] = WeeklyStats(
            weekNumber: weekNumber,
            year: year,
            attendanceCount: current.attendanceCount + 1,
            workoutCount: current.workoutCount,
            totalCalories: current.totalCalories,
          );
        }
      } catch (e) {
        // 날짜 파싱 실패 시 무시
      }
    }

    // 운동 일지 데이터 집계
    for (var workout in _workoutlogs) {
      try {
        final date = DateTime.parse(workout.date);
        final weekNumber = _getWeekNumber(date);
        final year = date.year;
        final key = year * 100 + weekNumber;

        if (stats.containsKey(key)) {
          final current = stats[key]!;
          stats[key] = WeeklyStats(
            weekNumber: weekNumber,
            year: year,
            attendanceCount: current.attendanceCount,
            workoutCount: current.workoutCount + 1,
            totalCalories: current.totalCalories + workout.calories,
          );
        }
      } catch (e) {
        // 날짜 파싱 실패 시 무시
      }
    }

    final result =
        stats.values.toList()..sort((a, b) {
          final aKey = a.year * 100 + a.weekNumber;
          final bKey = b.year * 100 + b.weekNumber;
          return aKey.compareTo(bKey);
        });

    return result;
  }

  // 월별 출석 통계 (최근 6개월)
  Map<String, int> getMonthlyAttendanceStats() {
    final now = DateTime.now();
    final stats = <String, int>{};

    // 최근 6개월 초기화
    for (int i = 0; i < 6; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      stats[_formatMonthKey(month)] = 0;
    }

    // 출석 데이터 집계
    final uniqueAttendances = <String, Set<String>>{};
    for (var attendance in _attendances) {
      try {
        final date = DateTime.parse(
          attendance.checkintime.isNotEmpty
              ? attendance.checkintime
              : attendance.date,
        );
        final monthKey = _formatMonthKey(date);
        final dateKey = _formatDateKey(date);

        if (stats.containsKey(monthKey)) {
          uniqueAttendances.putIfAbsent(monthKey, () => {});
          uniqueAttendances[monthKey]!.add(dateKey);
        }
      } catch (e) {
        // 날짜 파싱 실패 시 무시
      }
    }

    // 고유 날짜 수로 업데이트
    uniqueAttendances.forEach((month, dates) {
      stats[month] = dates.length;
    });

    return stats;
  }

  // 운동 종류별 통계
  List<ExerciseStats> getExerciseStats() {
    final statsMap = <String, ExerciseStats>{};

    for (var workout in _workoutlogs) {
      final name = workout.exercisename;
      if (name.isEmpty) continue;

      if (statsMap.containsKey(name)) {
        final current = statsMap[name]!;
        statsMap[name] = ExerciseStats(
          exerciseName: name,
          count: current.count + 1,
          maxWeight:
              workout.weight > current.maxWeight
                  ? workout.weight
                  : current.maxWeight,
          maxReps:
              workout.reps > current.maxReps ? workout.reps : current.maxReps,
          totalSets: current.totalSets + workout.sets,
        );
      } else {
        statsMap[name] = ExerciseStats(
          exerciseName: name,
          count: 1,
          maxWeight: workout.weight,
          maxReps: workout.reps,
          totalSets: workout.sets,
        );
      }
    }

    final result =
        statsMap.values.toList()..sort((a, b) => b.count.compareTo(a.count));

    return result;
  }

  // 개인 기록 (운동별 최고 무게)
  List<PersonalRecord> getPersonalRecords() {
    final recordsMap = <String, PersonalRecord>{};

    for (var workout in _workoutlogs) {
      final name = workout.exercisename;
      if (name.isEmpty || workout.weight == 0) continue;

      try {
        final date = DateTime.parse(workout.date);

        if (recordsMap.containsKey(name)) {
          final current = recordsMap[name]!;
          if (workout.weight > current.maxWeight ||
              (workout.weight == current.maxWeight &&
                  workout.reps > current.maxReps)) {
            recordsMap[name] = PersonalRecord(
              exerciseName: name,
              maxWeight: workout.weight,
              maxReps: workout.reps,
              achievedDate: date,
            );
          }
        } else {
          recordsMap[name] = PersonalRecord(
            exerciseName: name,
            maxWeight: workout.weight,
            maxReps: workout.reps,
            achievedDate: date,
          );
        }
      } catch (e) {
        // 날짜 파싱 실패 시 무시
      }
    }

    final result =
        recordsMap.values.toList()
          ..sort((a, b) => b.maxWeight.compareTo(a.maxWeight));

    return result;
  }

  // 최근 30일 일별 통계
  List<DailyStats> getDailyStats({int days = 30}) {
    final now = DateTime.now();
    final statsMap = <String, DailyStats>{};

    // 초기화
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final key = _formatDateKey(date);
      statsMap[key] = DailyStats(
        date: DateTime(date.year, date.month, date.day),
        attendanceCount: 0,
        workoutCount: 0,
        totalCalories: 0,
        totalDuration: 0,
      );
    }

    // 출석 데이터 집계
    for (var attendance in _attendances) {
      try {
        final date = DateTime.parse(
          attendance.checkintime.isNotEmpty
              ? attendance.checkintime
              : attendance.date,
        );
        final key = _formatDateKey(date);

        if (statsMap.containsKey(key)) {
          final current = statsMap[key]!;
          statsMap[key] = DailyStats(
            date: current.date,
            attendanceCount: current.attendanceCount + 1,
            workoutCount: current.workoutCount,
            totalCalories: current.totalCalories,
            totalDuration: current.totalDuration,
          );
        }
      } catch (e) {
        // 날짜 파싱 실패 시 무시
      }
    }

    // 운동 일지 데이터 집계
    for (var workout in _workoutlogs) {
      try {
        final date = DateTime.parse(workout.date);
        final key = _formatDateKey(date);

        if (statsMap.containsKey(key)) {
          final current = statsMap[key]!;
          statsMap[key] = DailyStats(
            date: current.date,
            attendanceCount: current.attendanceCount,
            workoutCount: current.workoutCount + 1,
            totalCalories: current.totalCalories + workout.calories,
            totalDuration: current.totalDuration + workout.duration,
          );
        }
      } catch (e) {
        // 날짜 파싱 실패 시 무시
      }
    }

    final result =
        statsMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));

    return result;
  }

  // 헬퍼 함수들
  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatMonthKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return (daysSinceFirstDay / 7).ceil() + 1;
  }
}
