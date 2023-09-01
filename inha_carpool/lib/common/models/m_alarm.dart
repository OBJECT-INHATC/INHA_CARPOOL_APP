/// 0831 한승완
/// 알림 모델 - 알림 정보를 담고 있는 모델
class AlarmMessage {

  int? id;

  final String aid; /// 제목 + 내용 + 시간 -> 해당 정보로 알림을 구분
  final String carId;
  final String type;
  final String title;
  final String body;
  final int time;


  AlarmMessage({
    this.id,
    required this.aid,
    required this.carId,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
  });

  static AlarmMessage fromMap(Map<String, dynamic> map) {
  return AlarmMessage(
    aid : map['aid'] as String,
    carId: map['carId'] as String,
    type: map['type'] as String,
    title: map['title'] as String,
    body: map['body'] as String,
    time: map['time'] as int,
  );
  }


  factory AlarmMessage.fromJson(Map<String, dynamic> json) {
    return AlarmMessage(
      aid : json['aid'] as String,
      carId: json['carId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      time: json['time'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'aid' : aid,
      'carId': carId,
      'type': type,
      'title': title,
      'body': body,
      'time': time,
    };
  }

}