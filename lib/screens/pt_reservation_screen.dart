import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_colors.dart';
import '../config/app_spacing.dart';
import '../config/app_text_styles.dart';
import '../config/http.dart';
import '../model/ptreservation.dart';
import '../model/trainermember.dart';
import '../model/user.dart';
import '../providers/auth_provider.dart';

/// PT 예약 (P3, docs/roadmap-p1-p6.md)
///
/// 자유 입력이 아니라 서버가 계산한 가용 슬롯(트레이너 근무시간 ∩ 휴게·기존
/// 예약 제외, GET /api/ptreservation/available)에서 고르는 방식. 슬롯 검증은
/// 서버가 다시 하므로 동시 예약 경합은 서버 응답으로 판정된다.
class PtReservationScreen extends StatefulWidget {
  const PtReservationScreen({super.key});

  @override
  State<PtReservationScreen> createState() => _PtReservationScreenState();
}

class _PtReservationScreenState extends State<PtReservationScreen> {
  List<Trainermember> _trainerLinks = [];
  final Map<int, User> _trainers = {};
  int _selectedTrainer = 0;
  DateTime _selectedDate = DateTime.now();
  List<Map<String, String>> _slots = [];
  String? _selectedSlotStart;
  bool _loadingSlots = false;
  bool _submitting = false;
  List<Ptreservation> _myReservations = [];

  int get _myId =>
      context.read<AuthProvider>().currentUser?.id ?? 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    // 내 담당 트레이너 (trainermember, 진행중=2)
    final links = await TrainermemberManager.find(params: 'member=$_myId');
    final active = links.where((l) => l.status.code != 1).toList();
    if (!mounted) return;
    setState(() {
      _trainerLinks = active;
      if (active.isNotEmpty) _selectedTrainer = active.first.trainer;
    });
    // 트레이너 이름
    for (final l in active) {
      final u = await UserManager.get(l.trainer);
      if (!mounted) return;
      setState(() => _trainers[l.trainer] = u);
    }
    await _loadSlots();
    await _loadMyReservations();
  }

  String get _dateStr =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _loadSlots() async {
    if (_selectedTrainer == 0) return;
    setState(() {
      _loadingSlots = true;
      _selectedSlotStart = null;
    });
    final res = await Http.get('/api/ptreservation/available', {
      'trainer': _selectedTrainer,
      'date': _dateStr,
    });
    if (!mounted) return;
    setState(() {
      _slots = (res?['content'] as List? ?? [])
          .map<Map<String, String>>((s) => {
                'start': s['start'] as String,
                'end': s['end'] as String,
              })
          .toList();
      _loadingSlots = false;
    });
  }

  Future<void> _loadMyReservations() async {
    final items = await PtreservationManager.find(
      pagesize: 50,
      params: 'member=$_myId',
    );
    if (!mounted) return;
    setState(() {
      _myReservations = items
          .where((r) => r.status == PtreservationStatus.reserved)
          .toList();
    });
  }

  Future<void> _reserve() async {
    final slot = _slots.firstWhere((s) => s['start'] == _selectedSlotStart);
    final link = _trainerLinks.firstWhere((l) => l.trainer == _selectedTrainer);

    setState(() => _submitting = true);
    final item = Ptreservation(
      trainer: _selectedTrainer,
      member: _myId,
      gym: link.gym,
      reservationdate: '${_dateStr}T00:00:00',
      starttime: '${slot['start']}:00',
      endtime: '${slot['end']}:00',
      duration: 60,
      status: PtreservationStatus.reserved,
    );
    final id = await PtreservationManager.insert(item);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (id > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$_dateStr ${slot['start']} 예약이 접수되었습니다.')),
      );
      await _loadSlots();
      await _loadMyReservations();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약에 실패했습니다. 잠시 후 다시 시도해주세요.')),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      await _loadSlots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('PT 예약',
            style: AppTextStyles.titleMedium
                .copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.grey900,
        elevation: 0,
      ),
      body: _trainerLinks.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  '배정된 트레이너가 없습니다.\n헬스장에 PT 등록 후 이용해주세요.',
                  style:
                      AppTextStyles.bodyLarge.copyWith(color: AppColors.grey600),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 트레이너 선택
                  Text('트레이너',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.grey600)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: _trainerLinks.map((l) {
                      final selected = l.trainer == _selectedTrainer;
                      return ChoiceChip(
                        label: Text(_trainers[l.trainer]?.name ??
                            '트레이너 ${l.trainer}'),
                        selected: selected,
                        selectedColor: AppColors.primaryLight,
                        onSelected: (_) async {
                          setState(() => _selectedTrainer = l.trainer);
                          await _loadSlots();
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 날짜 선택
                  Text('날짜',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.grey600)),
                  const SizedBox(height: AppSpacing.sm),
                  InkWell(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.grey300),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMedium),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 18, color: AppColors.grey600),
                          const SizedBox(width: AppSpacing.sm),
                          Text(_dateStr, style: AppTextStyles.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 슬롯
                  Text('예약 가능 시간',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.grey600)),
                  const SizedBox(height: AppSpacing.sm),
                  if (_loadingSlots)
                    const Center(child: CircularProgressIndicator())
                  else if (_slots.isEmpty)
                    Text(
                      '이 날짜에는 예약 가능한 시간이 없습니다.',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.grey600),
                    )
                  else
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _slots.map((s) {
                        final selected = s['start'] == _selectedSlotStart;
                        return ChoiceChip(
                          label: Text('${s['start']} ~ ${s['end']}'),
                          selected: selected,
                          selectedColor: AppColors.primaryLight,
                          onSelected: (_) => setState(
                              () => _selectedSlotStart = s['start']),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: AppSpacing.xl),

                  // 예약 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                      ),
                      onPressed:
                          _selectedSlotStart == null || _submitting
                              ? null
                              : _reserve,
                      child: Text(_submitting ? '예약 중...' : '예약하기'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // 내 예약
                  if (_myReservations.isNotEmpty) ...[
                    Text('나의 예약',
                        style: AppTextStyles.labelSmall
                            .copyWith(color: AppColors.grey600)),
                    const SizedBox(height: AppSpacing.sm),
                    ..._myReservations.map((r) => Container(
                          margin:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMedium),
                            border: Border.all(color: AppColors.grey200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.fitness_center,
                                  size: 20, color: AppColors.primary),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(
                                  '${r.reservationdate.split('T').first} '
                                  '${r.starttime.substring(0, 5)}~${r.endtime.substring(0, 5)}',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                              Text(
                                _trainers[r.trainer]?.name ?? '',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.grey600),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
    );
  }
}
