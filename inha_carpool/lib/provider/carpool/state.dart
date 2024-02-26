import 'package:google_maps_flutter/google_maps_flutter.dart';

class CarpoolState {
  final String carId;
  final String endPointName;
  final String endDetailPoint;
  final String startPointName;
  final String startDetailPoint;
  final LatLng startPoint;
  final LatLng endPoint;
  final DateTime startTime;
  final int maxMember;
  final int nowMember;
   List<String> members = [];
  final String admin;
  final String gender;
  double? distance;


  CarpoolState({
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
    required this.members,
    required this.admin,
    required this.carId,
  });

  //fromJson
  factory CarpoolState.fromJson(Map<String, dynamic> json) {

    final memberList = List<String>.from(json['members']);

    return CarpoolState(
      gender: json['gender'],
      endDetailPoint: json['endDetailPoint'],
      endPointName: json['endPointName'],
      endPoint: LatLng(json['endPoint'].latitude, json['endPoint'].longitude),
      startPoint: LatLng(json['startPoint'].latitude, json['startPoint'].longitude),
      startPointName: json['startPointName'],
      startDetailPoint: json['startDetailPoint'],
      maxMember: json['maxMember'],
      nowMember: json['nowMember'],
      members: memberList,
      admin: json['admin'],
      carId: json['carId'],
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime']),
    );
  }


}
