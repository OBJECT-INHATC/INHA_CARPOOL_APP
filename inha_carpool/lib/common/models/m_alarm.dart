/// 0831 한승완
/// 알림 모델 - 알림 정보를 담고 있는 모델
class AlarmMessage {

  int? id;

  final String carId;
  final String type;
  final String title;
  final String body;
  final int time;

  AlarmMessage(
      {this.id,
    required this.carId,
    required this.type,
    required this.title,
    required this.body,
    required this.time,
  });

  static AlarmMessage fromMap(Map<String, dynamic> map, int? id) {
    return AlarmMessage(
      id: id,
      carId: map['carId'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      time: map['time'] as int,
    );
  }

  factory AlarmMessage.fromJson(Map<String, dynamic> json) {
    return AlarmMessage(
      id : json['id'] as int,
      carId: json['carId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      time: json['time'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id ?? 0 ,
      'carId': carId,
      'type': type,
      'title': title,
      'body': body,
      'time': time,
    };
  }

}