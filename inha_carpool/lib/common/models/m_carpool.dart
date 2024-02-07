/// 참여중인 카풀 정보를 담는 모델
class CarpoolModel {
  // 카풀 정보
  final String? endDetailPoint;
  final String? endPointName;
  final String? startPoint;
  final String? startDetailPoint;

  // 출발 시간
  final String? startTime;

  // 최근 메시지 보낸 사람
  final String? recentMessageSender;
  final String? recentMessageTime;

  CarpoolModel(
      {this.endDetailPoint,
      this.endPointName,
      this.startPoint,
      this.startDetailPoint,
      this.startTime,
      this.recentMessageSender,
      this.recentMessageTime});

  // fromMap
  static CarpoolModel fromMap(Map<String, dynamic> map) {
    return CarpoolModel(
      endDetailPoint: map['endDetailPoint'] as String,
      endPointName: map['endPointName'] as String,
      startPoint: map['startPoint'] as String,
      startDetailPoint: map['startDetailPoint'] as String,
      startTime: map['startTime'] as String,
      recentMessageSender: map['recentMessageSender'] as String,
      recentMessageTime: map['recentMessageTime'] as String,
    );
  }

  //toMap
  Map<String, dynamic> toMap() {
    return {
      'endDetailPoint': endDetailPoint,
      'endPointName': endPointName,
      'startPoint': startPoint,
      'startDetailPoint': startDetailPoint,
      'startTime': startTime,
      'recentMessageSender': recentMessageSender,
      'recentMessageTime': recentMessageTime,
    };
  }

  // fromJson
  factory CarpoolModel.fromJson(Map<String, dynamic> json) {
    return CarpoolModel(
      endDetailPoint: json['endDetailPoint'] as String,
      endPointName: json['endPointName'] as String,
      startPoint: json['startPoint'] as String,
      startDetailPoint: json['startDetailPoint'] as String,
      startTime: json['startTime'] as String,
      recentMessageSender: json['recentMessageSender'] as String,
      recentMessageTime: json['recentMessageTime'] as String,
    );
  }

  // toJson
  Map<String, dynamic> toJson() {
    return {
      'endDetailPoint': endDetailPoint,
      'endPointName': endPointName,
      'startPoint': startPoint,
      'startDetailPoint': startDetailPoint,
      'startTime': startTime,
      'recentMessageSender': recentMessageSender,
      'recentMessageTime': recentMessageTime,
    };
  }


}
