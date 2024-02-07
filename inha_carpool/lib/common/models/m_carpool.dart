/// 참여중인 카풀 정보를 담는 모델
class CarpoolModel {
  // 카풀 정보
  final String? endDetailPoint;
  final String? endPointName;
  final String? startPointName;
  final String? startDetailPoint;

  // 출발 시간
  final int? startTime;

  // 최근 메시지 보낸 사람
  final String? recentMessageSender;
  final int? recentMessageTime;

  CarpoolModel(
      {this.endDetailPoint,
      this.endPointName,
      this.startPointName,
      this.startDetailPoint,
      this.startTime,
      this.recentMessageSender,
      this.recentMessageTime});

  // fromMap
  static CarpoolModel fromMap(Map<String, dynamic> map) {
    return CarpoolModel(
      endDetailPoint: map['endDetailPoint'] as String,
      startDetailPoint: map['startDetailPoint'] as String,
      startPointName: map['startPointName'] as String,
      endPointName: map['endPointName'] as String,
      startTime: map['startTime'] as int,
      recentMessageSender: map['recentMessageSender'] as String,
      recentMessageTime: map['recentMessageTime'] as int,
    );
  }

  //toMap
  Map<String, dynamic> toMap() {
    return {
      'endDetailPoint': endDetailPoint,
      'startDetailPoint': startDetailPoint,
      'endPointName': endPointName,
      'startPointName': startPointName,
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
      startPointName: json['startPointName'] as String,
      startDetailPoint: json['startDetailPoint'] as String,
      startTime: json['startTime'] as int,
      recentMessageSender: json['recentMessageSender'] as String ?? '',
      recentMessageTime: json['recentMessageTime'] as int ?? 0,
    );
  }



}
