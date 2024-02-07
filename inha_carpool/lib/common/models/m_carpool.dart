/// 참여중인 카풀 정보를 담는 모델
class CarpoolModel {
  // 카풀 정보

  final String? carId;
  final String? endDetailPoint;
  final String? endPointName;
  final String? startPointName;
  final String? startDetailPoint;

  // 출발 시간
  final int? startTime;

  // 최근 메시지 보낸 사람
  final String? recentMessageSender;
  final String? recentMessage;


  CarpoolModel(
      {this.endDetailPoint,
      this.endPointName,
      this.carId,
      this.startPointName,
      this.startDetailPoint,
      this.startTime,
      this.recentMessageSender,
      this.recentMessage,
     });

  // fromMap
  static CarpoolModel fromMap(Map<String, dynamic> map) {
    return CarpoolModel(
      endDetailPoint: map['endDetailPoint'] as String,
      carId: map['carId'] as String,
      startDetailPoint: map['startDetailPoint'] as String,
      startPointName: map['startPointName'] as String,
      endPointName: map['endPointName'] as String,
      startTime: map['startTime'] as int,
      recentMessageSender: map['recentMessageSender'] as String,
      recentMessage: map['recentMessage'] as String,
    );
  }

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



}
