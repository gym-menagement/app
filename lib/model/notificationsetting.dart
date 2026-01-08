import 'package:app/config/http.dart';


enum NotificationsettingEnabled {
  none(0, ''),
  enabled(1, '활성화'),
  disabled(2, '비활성화'),
;

  const NotificationsettingEnabled(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationsettingEnabled fromCode(int code) {
    return NotificationsettingEnabled.values.firstWhere((e) => e.code == code, orElse: () => NotificationsettingEnabled.none);
  }
}

enum NotificationsettingMembershipexpiry {
  none(0, ''),
  enabled(1, '활성화'),
  disabled(2, '비활성화'),
;

  const NotificationsettingMembershipexpiry(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationsettingMembershipexpiry fromCode(int code) {
    return NotificationsettingMembershipexpiry.values.firstWhere((e) => e.code == code, orElse: () => NotificationsettingMembershipexpiry.none);
  }
}

enum NotificationsettingMembershipnear {
  none(0, ''),
  enabled(1, '활성화'),
  disabled(2, '비활성화'),
;

  const NotificationsettingMembershipnear(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationsettingMembershipnear fromCode(int code) {
    return NotificationsettingMembershipnear.values.firstWhere((e) => e.code == code, orElse: () => NotificationsettingMembershipnear.none);
  }
}

enum NotificationsettingAttendanceenc {
  none(0, ''),
  enabled(1, '활성화'),
  disabled(2, '비활성화'),
;

  const NotificationsettingAttendanceenc(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationsettingAttendanceenc fromCode(int code) {
    return NotificationsettingAttendanceenc.values.firstWhere((e) => e.code == code, orElse: () => NotificationsettingAttendanceenc.none);
  }
}

enum NotificationsettingGymannounce {
  none(0, ''),
  enabled(1, '활성화'),
  disabled(2, '비활성화'),
;

  const NotificationsettingGymannounce(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationsettingGymannounce fromCode(int code) {
    return NotificationsettingGymannounce.values.firstWhere((e) => e.code == code, orElse: () => NotificationsettingGymannounce.none);
  }
}

enum NotificationsettingSystemnotice {
  none(0, ''),
  enabled(1, '활성화'),
  disabled(2, '비활성화'),
;

  const NotificationsettingSystemnotice(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationsettingSystemnotice fromCode(int code) {
    return NotificationsettingSystemnotice.values.firstWhere((e) => e.code == code, orElse: () => NotificationsettingSystemnotice.none);
  }
}

enum NotificationsettingPaymentconfirm {
  none(0, ''),
  enabled(1, '활성화'),
  disabled(2, '비활성화'),
;

  const NotificationsettingPaymentconfirm(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationsettingPaymentconfirm fromCode(int code) {
    return NotificationsettingPaymentconfirm.values.firstWhere((e) => e.code == code, orElse: () => NotificationsettingPaymentconfirm.none);
  }
}

enum NotificationsettingPauseexpiry {
  none(0, ''),
  enabled(1, '활성화'),
  disabled(2, '비활성화'),
;

  const NotificationsettingPauseexpiry(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationsettingPauseexpiry fromCode(int code) {
    return NotificationsettingPauseexpiry.values.firstWhere((e) => e.code == code, orElse: () => NotificationsettingPauseexpiry.none);
  }
}

enum NotificationsettingWeeklygoal {
  none(0, ''),
  enabled(1, '활성화'),
  disabled(2, '비활성화'),
;

  const NotificationsettingWeeklygoal(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationsettingWeeklygoal fromCode(int code) {
    return NotificationsettingWeeklygoal.values.firstWhere((e) => e.code == code, orElse: () => NotificationsettingWeeklygoal.none);
  }
}

enum NotificationsettingPersonalrecord {
  none(0, ''),
  enabled(1, '활성화'),
  disabled(2, '비활성화'),
;

  const NotificationsettingPersonalrecord(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationsettingPersonalrecord fromCode(int code) {
    return NotificationsettingPersonalrecord.values.firstWhere((e) => e.code == code, orElse: () => NotificationsettingPersonalrecord.none);
  }
}

enum NotificationsettingQuietenabled {
  none(0, ''),
  enabled(1, '활성화'),
  disabled(2, '비활성화'),
;

  const NotificationsettingQuietenabled(this.code, this.label);

  final int code;
  final String label;

  @override
  String toString() => label;

  static NotificationsettingQuietenabled fromCode(int code) {
    return NotificationsettingQuietenabled.values.firstWhere((e) => e.code == code, orElse: () => NotificationsettingQuietenabled.none);
  }
}

class Notificationsetting {
  int id;
  int user;
  NotificationsettingEnabled enabled;
  NotificationsettingMembershipexpiry membershipexpiry;
  NotificationsettingMembershipnear membershipnear;
  NotificationsettingAttendanceenc attendanceenc;
  NotificationsettingGymannounce gymannounce;
  NotificationsettingSystemnotice systemnotice;
  NotificationsettingPaymentconfirm paymentconfirm;
  NotificationsettingPauseexpiry pauseexpiry;
  NotificationsettingWeeklygoal weeklygoal;
  NotificationsettingPersonalrecord personalrecord;
  NotificationsettingQuietenabled quietenabled;
  String quietstart;
  String quietend;
  String createddate;
  String updateddate;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Notificationsetting({
    this.id = 0,
    this.user = 0,
    this.enabled = NotificationsettingEnabled.none,
    this.membershipexpiry = NotificationsettingMembershipexpiry.none,
    this.membershipnear = NotificationsettingMembershipnear.none,
    this.attendanceenc = NotificationsettingAttendanceenc.none,
    this.gymannounce = NotificationsettingGymannounce.none,
    this.systemnotice = NotificationsettingSystemnotice.none,
    this.paymentconfirm = NotificationsettingPaymentconfirm.none,
    this.pauseexpiry = NotificationsettingPauseexpiry.none,
    this.weeklygoal = NotificationsettingWeeklygoal.none,
    this.personalrecord = NotificationsettingPersonalrecord.none,
    this.quietenabled = NotificationsettingQuietenabled.none,
    this.quietstart = '',
    this.quietend = '',
    this.createddate = '',
    this.updateddate = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Notificationsetting.fromJson(Map<String, dynamic> json) {
    return Notificationsetting(
      id: json['id'] as int,
      user: json['user'] as int,
      enabled: NotificationsettingEnabled.fromCode(json['enabled'] as int),
      membershipexpiry: NotificationsettingMembershipexpiry.fromCode(json['membershipexpiry'] as int),
      membershipnear: NotificationsettingMembershipnear.fromCode(json['membershipnear'] as int),
      attendanceenc: NotificationsettingAttendanceenc.fromCode(json['attendanceenc'] as int),
      gymannounce: NotificationsettingGymannounce.fromCode(json['gymannounce'] as int),
      systemnotice: NotificationsettingSystemnotice.fromCode(json['systemnotice'] as int),
      paymentconfirm: NotificationsettingPaymentconfirm.fromCode(json['paymentconfirm'] as int),
      pauseexpiry: NotificationsettingPauseexpiry.fromCode(json['pauseexpiry'] as int),
      weeklygoal: NotificationsettingWeeklygoal.fromCode(json['weeklygoal'] as int),
      personalrecord: NotificationsettingPersonalrecord.fromCode(json['personalrecord'] as int),
      quietenabled: NotificationsettingQuietenabled.fromCode(json['quietenabled'] as int),
      quietstart: json['quietstart'] as String,
      quietend: json['quietend'] as String,
      createddate: json['createddate'] as String,
      updateddate: json['updateddate'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user': user,
    'enabled': enabled.code,
    'membershipexpiry': membershipexpiry.code,
    'membershipnear': membershipnear.code,
    'attendanceenc': attendanceenc.code,
    'gymannounce': gymannounce.code,
    'systemnotice': systemnotice.code,
    'paymentconfirm': paymentconfirm.code,
    'pauseexpiry': pauseexpiry.code,
    'weeklygoal': weeklygoal.code,
    'personalrecord': personalrecord.code,
    'quietenabled': quietenabled.code,
    'quietstart': quietstart,
    'quietend': quietend,
    'createddate': createddate,
    'updateddate': updateddate,
    'date': date,
  };

  Notificationsetting clone() {
    return Notificationsetting.fromJson(toJson());
  }
}

class NotificationsettingManager {
  static const baseUrl = '/api/notificationsetting';

  static Future<List<Notificationsetting>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['content'] == null) {
      return List<Notificationsetting>.empty(growable: true);
    }

    return result['content'].map<Notificationsetting>((json) => Notificationsetting.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Notificationsetting> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Notificationsetting();
    }

    return Notificationsetting.fromJson(result);
  }

  static Future<int> insert(Notificationsetting item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Notificationsetting item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Notificationsetting item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
