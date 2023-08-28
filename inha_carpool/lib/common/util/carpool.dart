import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:inha_Carpool/common/common.dart';

class FirebaseCarpool {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final storage = const FlutterSecureStorage();
  late String nickName = ""; // 기본값으로 초기화
  late String uid = "";
  late String gender = "";

  ///출발 시간순으로 조회 (출발 시간이 현재시간을 넘으면 제외)
  static Future<List<DocumentSnapshot>> getCarpoolsTimeby() async {
    CollectionReference carpoolCollection = _firestore.collection('carpool');
    QuerySnapshot querySnapshot = await carpoolCollection.get();

    List<DocumentSnapshot> sortedCarpools = [];
    print("조회된 카풀 수: ${querySnapshot.docs.length}");

    // 현재 시간을 가져옵니다.
    DateTime currentTime = DateTime.now();

    querySnapshot.docs.forEach((doc) {
      DateTime startTime =
          DateTime.fromMillisecondsSinceEpoch(doc['startTime']);

      // 현재 시간보다 미래의 시간인 경우만 추가
      if (startTime.isAfter(currentTime)) {
        sortedCarpools.add(doc);
      }
    });

    sortedCarpools.sort((a, b) {
      DateTime startTimeA = DateTime.fromMillisecondsSinceEpoch(a['startTime']);
      DateTime startTimeB = DateTime.fromMillisecondsSinceEpoch(b['startTime']);

      return startTimeA.compareTo(startTimeB);
    });

    return sortedCarpools;
  }

  /// 카풀 저장
  static Future<void> addDataToFirestore({
    required DateTime selectedDate,
    required DateTime selectedTime,
    required LatLng startPoint,
    required LatLng endPoint,
    required String endPointName,
    required String startPointName,
    required String selectedLimit,
    required String selectedGender,
    required String memberID,
    required String memberName,
    required String startDetailPoint,
    required String endDetailPoint,
  }) async {
    DateTime combinedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    int dateAsInt = combinedDateTime.millisecondsSinceEpoch;

    try {
      CollectionReference users = _firestore.collection('carpool');
      GeoPoint geoStart = GeoPoint(startPoint.latitude, startPoint.longitude);
      GeoPoint geoEnd = GeoPoint(endPoint.latitude, endPoint.longitude);

      List<String> hobbies = ['${memberID}_$memberName'];

      print(selectedLimit.replaceAll(RegExp(r'[^\d]'), ''));

      DocumentReference carpoolDocRef = await users.add({
        'admin': '${memberID}_$memberName',
        'startPointName': startPointName,
        'startPoint': geoStart,
        'endPointName': endPointName,
        'endPoint': geoEnd,
        'maxMember': int.parse(selectedLimit.replaceAll(RegExp(r'[^\d]'), '')),
        'gender': selectedGender,
        'startTime': dateAsInt,
        'nowMember': 1,
        'status': false,
        'members': hobbies,
        'startDetailPoint': startDetailPoint,
        'endDetailPoint': endDetailPoint,
      });
      await carpoolDocRef.update({'carId': carpoolDocRef.id});

      CollectionReference membersCollection =
          carpoolDocRef.collection('messages');
      await membersCollection.add({
        'memberID': '${memberID}_${memberName}',
        'joinedDate': DateTime.now(),
      });

      print('Data added to Firestore.');
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }

  ///카풀 참가
  static Future<void> addMemberToCarpool(
      String carpoolID, String memberID, String memberName) async {
    try {
      CollectionReference carpoolCollection = _firestore.collection('carpool');
      DocumentReference carpoolDocRef = carpoolCollection.doc(carpoolID);
      //멤버 업데이트 (멤버 추가)
      await carpoolDocRef.update({
        'members': FieldValue.arrayUnion(['${memberID}_${memberName}']),
        'nowMember': FieldValue.increment(1), // nowMember 값을 1 증가
      });

      //채팅방 참여
      CollectionReference membersCollection =
          carpoolDocRef.collection('messages');
      await membersCollection.add({
        'memberID': '${memberID}_${memberName}',
        'joinedDate': DateTime.now(),
      });

      print('카풀에 유저가 추가되었습니다 -> ${memberID}_${memberName}');
    } catch (e) {
      print('카풀에 유저 추가 실패');
    }
  }

  ///거리순 조회
  static Future<List<DocumentSnapshot>> nearByCarpool(
      double myLat, double myLon) async {
    QuerySnapshot querySnapshot = await _firestore.collection('carpool').get();

    List<Map<String, dynamic>> sortedCarpools = [];
    print("조회된 카풀 수: ${querySnapshot.docs.length}");

    // 현재 시간을 가져옵니다.
    DateTime currentTime = DateTime.now();

    querySnapshot.docs.forEach((doc) {
      DateTime startTime =
          DateTime.fromMillisecondsSinceEpoch(doc['startTime']);

      // 현재 시간보다 미래의 시간인 경우만 추가
      if (startTime.isAfter(currentTime)) {
        double startLat = doc['startPoint'].latitude;
        double startLon = doc['startPoint'].longitude;

        double distance = calculateDistance(myLat, myLon, startLat, startLon);
        sortedCarpools.add({
          'doc': doc,
          'distance': distance,
        });
      }
    });

    sortedCarpools.sort((a, b) {
      double distanceA = a['distance'];
      double distanceB = b['distance'];

      // 거리를 오름차순으로 정렬합니다.
      return distanceA.compareTo(distanceB);
    });

    // 정렬된 카풀 리스트를 반환합니다.
    return sortedCarpools.map((entry) {
      double distance = entry['distance'];
      print('거리: $distance'); // 거리 출력
      return entry['doc'] as DocumentSnapshot;
    }).toList();
  }

  ///거리 계산
  static double calculateDistance(
    double myLat,
    double myLon,
    double startLat,
    double startLon,
  ) {
    double distanceInMeters = Geolocator.distanceBetween(
      myLat,
      myLon,
      startLat,
      startLon,
    );

    return distanceInMeters / 1000;
  }

  /// 내가 참여한 카풀
  static Future<List<DocumentSnapshot>> getCarpoolsWithMember(
      String memberID, String memberName) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('carpool')
        .where('members', arrayContains: '${memberID}_$memberName')
        .get();

    List<DocumentSnapshot> sortedCarpools = [];
    print("조회된 카풀 수: ${querySnapshot.docs.length}");

    // 현재 시간을 가져옵니다.
    DateTime currentTime = DateTime.now();

    querySnapshot.docs.forEach((doc) {
      DateTime startTime =
          DateTime.fromMillisecondsSinceEpoch(doc['startTime']);

      // 현재 시간보다 미래의 시간인 경우만 추가
      if (startTime.isAfter(currentTime)) {
        sortedCarpools.add(doc);
      }
    });

    sortedCarpools.sort((a, b) {
      DateTime startTimeA = DateTime.fromMillisecondsSinceEpoch(a['startTime']);
      DateTime startTimeB = DateTime.fromMillisecondsSinceEpoch(b['startTime']);

      return startTimeA.compareTo(startTimeB);
    });

    return sortedCarpools;
  }
}
