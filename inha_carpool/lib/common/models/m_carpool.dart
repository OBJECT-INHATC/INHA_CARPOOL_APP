import 'package:flutter/cupertino.dart';

/// 참여중인 카풀 정보를 담는 모델
class CarpoolModel {
  // 카풀 정보

  final String? carId;
  final String? endDetailPoint;
  final String? endPointName;
  final String? startPointName;
  final String? startDetailPoint;
  late bool? isChatAlarmOn;

  // 출발 시간
  final int? startTime;

  // 최근 메시지 보낸 사람
  final String? recentMessageSender;
  final String? recentMessage;


  CarpoolModel(
      {this.endDetailPoint,
      this.endPointName,
      this.carId,
      this.isChatAlarmOn,
      this.startPointName,
      this.startDetailPoint,
      this.startTime,
      this.recentMessageSender,
      this.recentMessage,
     });

  //toMap
  Map<String, dynamic> toMap() {
    return {
      'endDetailPoint': endDetailPoint,
      'startDetailPoint': startDetailPoint,
      'carId': carId,
      'endPointName': endPointName,
      'startPointName': startPointName,
      'startTime': startTime,
      'recentMessageSender': recentMessageSender,
      'recentMessage': recentMessage,
      'isChatAlarmOn': isChatAlarmOn,
    };
  }

  // fromJson
  factory CarpoolModel.fromJson(Map<String, dynamic> json) {
    return CarpoolModel(
      endDetailPoint: json['endDetailPoint'] as String,
      carId: json['carId'] as String,
      endPointName: json['endPointName'] as String,
      startPointName: json['startPointName'] as String,
      startDetailPoint: json['startDetailPoint'] as String,
      startTime: json['startTime'] as int,
      recentMessageSender: json['recentMessageSender'] as String ?? '',
      recentMessage: json['recentMessage'] as String ?? '',
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
    );
  }





}
