import 'package:common_control/common_control.dart';
import 'package:dreamcam/models/status.dart';


class Ptreservation {
  int id;
  int trainer;
  int member;
  int gym;
  String reservationdate;
  String starttime;
  String endtime;
  int duration;
  Status status;
  String note;
  String cancelreason;
  String createddate;
  String updateddate;
  String date;
  bool checked;
  Map<String, dynamic> extra;

  Ptreservation({
    this.id = 0,
    this.trainer = 0,
    this.member = 0,
    this.gym = 0,
    this.reservationdate = '',
    this.starttime = '',
    this.endtime = '',
    this.duration = 0,
    this.status = Status(),
    this.note = '',
    this.cancelreason = '',
    this.createddate = '',
    this.updateddate = '',
    this.date = '',
    this.extra = const {},
    this.checked = false,
  });

  factory Ptreservation.fromJson(Map<String, dynamic> json) {
    return Ptreservation(
      id: json['id'] as int,
      trainer: json['trainer'] as int,
      member: json['member'] as int,
      gym: json['gym'] as int,
      reservationdate: json['reservationdate'] as String,
      starttime: json['starttime'] as String,
      endtime: json['endtime'] as String,
      duration: json['duration'] as int,
      status: Status.fromJson(json['status']),
      note: json['note'] as String,
      cancelreason: json['cancelreason'] as String,
      createddate: json['createddate'] as String,
      updateddate: json['updateddate'] as String,
      date: json['date'] as String,
      extra: json['extra'] == null ? <String, dynamic>{} : json['extra'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'trainer': trainer,
    'member': member,
    'gym': gym,
    'reservationdate': reservationdate,
    'starttime': starttime,
    'endtime': endtime,
    'duration': duration,
    'status': status.toJson(),
    'note': note,
    'cancelreason': cancelreason,
    'createddate': createddate,
    'updateddate': updateddate,
    'date': date,
  };

  Ptreservation clone() {
    return Ptreservation.fromJson(toJson());
  }
}

class PtreservationManager {
  static const baseUrl = '/api/ptreservation';

  static Future<List<Ptreservation>> find({
    int page = 0,
    int pagesize = 20,
    String? params,
  }) async {
    var result = await Http.get(baseUrl, {
      'page': page,
      'pagesize': pagesize,
    }, params);
    if (result == null || result['items'] == null) {
      return List<Ptreservation>.empty(growable: true);
    }

    return result['items'].map<Ptreservation>((json) => Ptreservation.fromJson(json)).toList();
  }

  static Future<int> count({String? params}) async {
    var result = await Http.get('$baseUrl/count', {}, params);
    if (result == null || result['total'] == null) {
      return 0;
    }

    return int.parse(result['total']);
  }

  static Future<Ptreservation> get(int id) async {
    var result = await Http.get('$baseUrl/$id');
    if (result == null || result['item'] == null) {
      return Ptreservation();
    }

    return Ptreservation.fromJson(result['item']);
  }

  static Future<int> insert(Ptreservation item) async {
    var result = await Http.insert(baseUrl, item.toJson());
    return result;
  }

  static update(Ptreservation item) async {
    await Http.put(baseUrl, item.toJson());
  }

  static delete(Ptreservation item) async {
    await Http.delete(baseUrl, item.toJson());
  }
}
