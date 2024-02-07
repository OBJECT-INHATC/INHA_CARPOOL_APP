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
}
