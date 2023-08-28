/// 0828 서은율, 한승완
/// 채팅 메시지 모델 - 채팅 메시지 정보 담고 있는 모델
class ChatMessage {

  @override
  int get hashCode => message.hashCode ^ sender.hashCode ^ time.hashCode ^ carId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ChatMessage &&
              runtimeType == other.runtimeType &&
              message == other.message &&
              sender == other.sender &&
              time == other.time &&
              carId == other.carId;

  int? id;

  final String carId;
  final String message;
  final String sender;
  final int time;

  ChatMessage( {
    required this.carId,
    required this.message,
    required this.sender,
    required this.time,
  });

  static ChatMessage fromMap(Map<String, dynamic> map, String carId) {
    return ChatMessage(
      carId: carId,
      message: map['message'] as String,
      sender: map['sender'] as String,
      time: map['time'] as int,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      carId: json['carId'] as String,
      message: json['message'] as String,
      sender: json['sender'] as String,
      time: json['time'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'carId': carId,
      'message': message,
      'sender': sender,
      'time': time,
    };
  }

}