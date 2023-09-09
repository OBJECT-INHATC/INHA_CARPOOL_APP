class HistoryRequestDTO {

  final String carPoolId;
  final String admin;
  final String member1;
  final String member2;
  final String member3;
  final int nowMember;
  final int maxMember;
  final String startDetailPoint;
  final String startPoint;
  final String startPointName;
  final int startTime;
  final String endDetailPoint;
  final String endPoint;
  final String endPointName;
  final String gender;

  HistoryRequestDTO({
    required this.carPoolId,
    required this.admin,
    required this.member1,
    required this.member2,
    required this.member3,
    required this.nowMember,
    required this.maxMember,
    required this.startDetailPoint,
    required this.startPoint,
    required this.startPointName,
    required this.startTime,
    required this.endDetailPoint,
    required this.endPoint,
    required this.endPointName,
    required this.gender,
  });

  Map<String, dynamic> toJson() {
    return {
      'carPoolId': carPoolId,
      'admin': admin,
      'member1': member1,
      'member2': member2,
      'member3': member3,
      'nowMember': nowMember,
      'maxMember': maxMember,
      'startDetailPoint': startDetailPoint,
      'startPoint': startPoint,
      'startPointName': startPointName,
      'startTime': startTime,
      'endDetailPoint': endDetailPoint,
      'endPoint': endPoint,
      'endPointName': endPointName,
      'gender': gender,
    };
  }


}