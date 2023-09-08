import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/database/d_chat_dao.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';
import 'package:inha_Carpool/screen/main/tab/home/s_carpool_map.dart';

import '../../screen/main/s_main.dart';

class FirebaseCarpool {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const storage = FlutterSecureStorage();
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
    required String selectedRoomGender,
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

    String? token = await storage.read(key: "token");
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
        'gender': selectedRoomGender,
        'startTime': dateAsInt,
        'nowMember': 1,
        'status': false,
        'members': hobbies,
        'startDetailPoint': startDetailPoint,
        'endDetailPoint': endDetailPoint,
      });
      await carpoolDocRef.update({'carId': carpoolDocRef.id});

      /// 0830 한승완 추가 : carId의 Token 저장
      await FireStoreService().saveToken(token!, carpoolDocRef.id);

      /// 0903 한승완 추가 : 참가 메시지 전송
      await FireStoreService().sendCreateMessage(carpoolDocRef.id, memberName);

      print('Data added to Firestore.');
    } catch (e) {
      print('Error adding data to Firestore: $e');
    }
  }
///0907 새 채팅 카운트 업데이트
  static Future<void> updateNewChatCount(String carpoolId, int newChatCount) async {
    try {
      await _firestore.collection('carpools').doc(carpoolId).update({
        'newchat': newChatCount,
      });
    } catch (e) {
      print(e);
      throw e;
    }
  }


  static Future<void> addMemberToCarpool(String carpoolID, String memberID,
      String memberName, String token, String roomGender) async {
    CollectionReference carpoolCollection = _firestore.collection('carpool');
    DocumentReference carpoolDocRef = carpoolCollection.doc(carpoolID);


    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot carpoolSnapshot = await transaction.get(carpoolDocRef);

        if (!carpoolSnapshot.exists) {
          // 카풀 정보가 없는 경우 처리
          print('해당 카풀이 존재하지 않습니다.');
          return;
        }
        int nowMember = carpoolSnapshot['nowMember'];
        int maxMember = carpoolSnapshot['maxMember'];
        if (nowMember < maxMember) {
          transaction.update(carpoolDocRef, {
            'members': FieldValue.arrayUnion(['${memberID}_$memberName']),
            'nowMember': FieldValue.increment(1),
          });
          FireStoreService().saveToken(
            token,
            carpoolID,
          );
          FireStoreService().sendEntryMessage(carpoolID, memberName);
        } else {
          // 최대 인원 초과 시 예외 발생
          throw Exception('최대 인원 초과');
        }
      });
      print('카풀에 유저가 추가되었습니다 -> ${memberID}_$memberName');
    } catch (e) {
      // 예외를 다시 던져서 메소드를 호출한 곳에 전달
      throw e;
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
