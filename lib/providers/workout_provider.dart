import 'package:flutter/material.dart';
import '../model/attendance.dart';
import '../model/usehealthusage.dart';
import '../model/workoutlog.dart';

class WorkoutProvider extends ChangeNotifier {
  List<Attendance> _attendances = [];
  List<Usehealthusage> _usages = [];
  List<Workoutlog> _workoutlogs = [];
  bool _isLoading = false;
  String? _errorMessage;
  int? _userId;
  DateTime _selectedDate = DateTime.now();

  List<Attendance> get attendances => _attendances;
  List<Usehealthusage> get usages => _usages;
  List<Workoutlog> get workoutlogs => _workoutlogs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedDate => _selectedDate;

  // userId 설정
  void setUserId(int userId) {
    _userId = userId;
  }

  // 선택된 날짜 설정
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // 특정 날짜의 출석 기록 가져오기
  List<Attendance> getAttendancesByDate(DateTime date) {
    final dateStr = _formatDateForComparison(date);
    return _attendances.where((a) {
      final attendanceDate = _formatDateForComparison(
        DateTime.parse(a.checkintime.isNotEmpty ? a.checkintime : a.date),
      );
      return attendanceDate == dateStr;
    }).toList();
  }

  // 특정 날짜의 운동 일지 가져오기
  List<Workoutlog> getWorkoutlogsByDate(DateTime date) {
    final dateStr = _formatDateForComparison(date);
    return _workoutlogs.where((w) {
      final workoutDate = _formatDateForComparison(DateTime.parse(w.date));
      return workoutDate == dateStr;
    }).toList();
  }

  // 특정 월의 출석 일수 계산
  int getMonthlyAttendanceCount(DateTime month) {
    final year = month.year;
    final monthNum = month.month;

    return _attendances.where((a) {
      try {
        final date = DateTime.parse(
          a.checkintime.isNotEmpty ? a.checkintime : a.date,
        );
        return date.year == year && date.month == monthNum;
      } catch (e) {
        return false;
      }
    }).length;
  }

  // 날짜 형식 변환 (비교용)
  String _formatDateForComparison(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // 출석 데이터 로드
  Future<void> loadAttendances({DateTime? startDate, DateTime? endDate}) async {
    if (_userId == null) {
      _errorMessage = 'userId가 설정되지 않았습니다';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String params = 'user=$_userId';

      if (startDate != null && endDate != null) {
        params +=
            '&startdate=${_formatDateForComparison(startDate)}&enddate=${_formatDateForComparison(endDate)}';
      }

      _attendances = await AttendanceManager.find(
        page: 0,
        pagesize: 9999,
        params: params,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 운동 일지 로드
  Future<void> loadWorkoutlogs({DateTime? startDate, DateTime? endDate}) async {
    if (_userId == null) {
      _errorMessage = 'userId가 설정되지 않았습니다';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String params = 'user=$_userId';

      if (startDate != null && endDate != null) {
        params +=
            '&startdate=${_formatDateForComparison(startDate)}&enddate=${_formatDateForComparison(endDate)}';
      }

      _workoutlogs = await WorkoutlogManager.find(
        page: 0,
        pageSize: 9999,
        params: params,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 모든 데이터 로드
  Future<void> loadAll({DateTime? startDate, DateTime? endDate}) async {
    await Future.wait([
      loadAttendances(startDate: startDate, endDate: endDate),
      loadWorkoutlogs(startDate: startDate, endDate: endDate),
    ]);
  }

  // 운동 일지 추가
  Future<bool> addWorkoutlog(Workoutlog log) async {
    try {
      final id = await WorkoutlogManager.insert(log);
      if (id > 0) {
        await loadWorkoutlogs();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 운동 일지 수정
  Future<bool> updateWorkoutlog(Workoutlog log) async {
    try {
      await WorkoutlogManager.update(log);
      await loadWorkoutlogs();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 운동 일지 삭제
  Future<bool> deleteWorkoutlog(Workoutlog log) async {
    try {
      await WorkoutlogManager.delete(log);
      await loadWorkoutlogs();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 새로고침
  Future<void> refresh() async {
    await loadAll();
  }
}
