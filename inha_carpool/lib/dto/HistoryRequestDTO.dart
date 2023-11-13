class HistoryRequestDTO {

  final String carPoolId;
  final String admin;
  final String member1;
  final String member2;
  final String member3;
  final String member4;
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
    required this.member4,
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
      'member4': member4,
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


  factory HistoryRequestDTO.fromJson(Map<String, dynamic> json) {

    return HistoryRequestDTO(
      carPoolId: json['carPoolId'],
      admin: json['admin'],
      member1: json['member1'],
      member2: json['member2'],
      member3: json['member3'],
      member4: json['member4'],
      nowMember: json['nowMember'],
      maxMember: json['maxMember'],
      startDetailPoint: json['startDetailPoint'],
      startPoint: json['startPoint'],
      startPointName: json['startPointName'],
      startTime: json['startTime'],
      endDetailPoint: json['endDetailPoint'],
      endPoint: json['endPoint'],
      endPointName: json['endPointName'],
      gender: json['gender'],
    );
  }


}