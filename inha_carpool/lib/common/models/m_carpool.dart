import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 참여중인 카풀 정보를 담는 모델
class CarpoolModel {
  // 카풀 정보

  final String? carId;
  final String? endDetailPoint;
  final String? endPointName;
  final String? startPointName;
  final String? startDetailPoint;
  late  bool? isChatAlarmOn;

  // 출발 시간
  final int? startTime;

  // 최근 메시지 보낸 사람
  final String? recentMessageSender;
  final String? recentMessage;

  final LatLng? startPoint;
  final LatLng? endPoint;

  final String? gender;
  final String? admin;



  CarpoolModel(
      {this.endDetailPoint,
      this.endPointName,
      this.carId,
        this.gender,
        this.admin,
      this.isChatAlarmOn,
      this.startPointName,
      this.startDetailPoint,
      this.startTime,
      this.recentMessageSender,
      this.recentMessage,
        this.startPoint,
        this.endPoint,
     });



  // fromJson
  factory CarpoolModel.fromJson(Map<String, dynamic> json) {
    return CarpoolModel(
      endDetailPoint: json['endDetailPoint'] as String,
      carId: json['carId'] as String,
      endPointName: json['endPointName'] as String,
      startPointName: json['startPointName'] as String,
      startDetailPoint: json['startDetailPoint'] as String,
      startTime: json['startTime'] as int,
      recentMessageSender: json['recentMessageSender'] as String,
      recentMessage: json['recentMessage'] as String,
      isChatAlarmOn: json['isChatAlarmOn'] == null ? true : json['isChatAlarmOn'] as bool,
      startPoint: LatLng(json['startPoint'].latitude, json['startPoint'].longitude),
      endPoint: LatLng(json['endPoint'].latitude, json['endPoint'].longitude),
      gender: json['admin'] as String,
      admin: json['admin'] as String,
    );
  }

  


  CarpoolModel copyWith({bool? alarm}) {
    print('copyWith alarm: $alarm');
    return CarpoolModel(
      endDetailPoint: endDetailPoint,
      carId: carId,
      startDetailPoint: startDetailPoint,
      startPointName: startPointName,
      endPointName: endPointName,
      startTime: startTime,
      recentMessageSender: recentMessageSender,
      recentMessage: recentMessage,
      isChatAlarmOn: alarm ?? isChatAlarmOn,
      startPoint: startPoint,
      endPoint: endPoint,
      gender: gender,
      admin: admin,
    );
  }

}
