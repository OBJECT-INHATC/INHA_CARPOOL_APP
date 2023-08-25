import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';



class FirebaseCarpool {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //출발 시간순으로 조회 (출발 시간이 현재시간을 넘으면 제외)
  static Future<List<DocumentSnapshot>> getCarpoolsTimeby({
    required double myLatitude,
    required double myLongitude,
  }) async {
    CollectionReference carpoolCollection = _firestore.collection('carpool');
    QuerySnapshot querySnapshot = await carpoolCollection.get();

    List<DocumentSnapshot> sortedCarpools = [];
    print("조회된 카풀 수: ${querySnapshot.docs.length}");

    // 현재 시간을 가져옵니다.
    DateTime currentTime = DateTime.now();

    querySnapshot.docs.forEach((doc) {
      DateTime startTime = DateTime.fromMillisecondsSinceEpoch(doc['startTime']);

      print("///-------------------------------------------------------------///");
      print("출발 위치: ${doc['startPointName']}, 출발시간: $startTime");
      print("도착 위치: ${doc['endPointName']},  방장: ${doc['admin']}");

      // 현재 시간보다 미래의 시간인 경우만 추가
      if (startTime.isAfter(currentTime)) {
        sortedCarpools.add(doc);
      }
    });
    print("///-------------------------------------------------------------///");

    sortedCarpools.sort((a, b) {
      DateTime startTimeA = DateTime.fromMillisecondsSinceEpoch(a['startTime']);
      DateTime startTimeB = DateTime.fromMillisecondsSinceEpoch(b['startTime']);

      return startTimeA.compareTo(startTimeB);
    });

    return sortedCarpools;
  }




  /// 카풀 시작하기 method
  static Future<void> addDataToFirestore({
    required DateTime selectedDate,
    required DateTime selectedTime,
    required LatLng startPoint,
    required LatLng endPoint,
    required String endPointName,
    required String startPointName,
    required String selectedLimit,
    required String selectedGender,
    required String myID,
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
      List<String> hobbies = [myID];

      print(selectedLimit.replaceAll(RegExp(r'[^\d]'), ''));

      DocumentReference carpoolDocRef = await users.add({
        'admin': myID,
        'startPointName': startPointName,
        'startPoint': geoStart,
        'endPointName': endPointName,
        'endPoint': geoEnd,
        'maxMember': selectedLimit.replaceAll(RegExp(r'[^\d]'), ''),
        'gender': selectedGender,
        'startTime': dateAsInt,
        'nowMember': 1,
        'status': false,
        'members': hobbies,
      });

      CollectionReference membersCollection =
          carpoolDocRef.collection('messages');
      await membersCollection.add({
        'memberID': myID,
        'joinedDate': DateTime.now(),
      });

      print('Data added to Firestore.');
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }


  //거리 계산
  static double calculateDistance(
      double myLat,
      double myLon,
      double startLat,
      double startLon,
      ) {
    const int earthRadius = 6371000; // 지구 반지름 (미터)

    double degToRad(double deg) {
      return deg * (pi / 180);
    }

    double dLat = degToRad(startLat - myLat);
    double dLon = degToRad(startLon - myLon);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degToRad(myLat)) * cos(degToRad(startLat)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;

    return distance;
  }

}
