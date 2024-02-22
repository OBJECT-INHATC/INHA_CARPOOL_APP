class CarpoolState {
  final String gender;
  final String endPointName;
  final String endPoint;
  final String endDetailPoint;
  final String startTime;
  final String startPointName;
  final String startPoint;
  final String startDetailPoint;
  final int maxMember;
  final int nowMember;
  final String member4;
  final String member3;
  final String member2;
  final String member1;
final String admin;
final String carPoolId;

  const CarpoolState({
    required this.gender,
    required this.endDetailPoint,
    required this.endPoint,
    required this.endPointName,
    required this.startTime,
    required this.startPointName,
    required this.startPoint,
    required this.startDetailPoint,
    required this.maxMember,
    required this.nowMember,
    required this.member4,
    required this.member3,
    required this.member2,
    required this.member1,
    required this.admin,
    required this.carPoolId,
  });

  //fromJson
factory CarpoolState.fromJson(Map<String, dynamic> json) {
    return CarpoolState(
      gender: json['gender'],
      endDetailPoint: json['endDetailPoint'],
      endPoint: json['endPoint'],
      endPointName: json['endPointName'],
      startTime: json['startTime'],
      startPointName: json['startPointName'],
      startPoint: json['startPoint'],
      startDetailPoint: json['startDetailPoint'],
      maxMember: json['maxMember'],
      nowMember: json['nowMember'],
      member4: json['member4'],
      member3: json['member3'],
      member2: json['member2'],
      member1: json['member1'],
      admin: json['admin'],
      carPoolId: json['carPoolId'],
    );
}





}

