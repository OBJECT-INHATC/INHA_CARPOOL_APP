import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';

import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/database/d_chat_dao.dart';
import 'package:inha_Carpool/dto/TopicDTO.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';
import 'package:inha_Carpool/screen/main/tab/home/s_carpool_map.dart';

import '../../screen/main/s_main.dart';
import '../../service/api/Api_Topic.dart';
import '../data/preference/prefs.dart';
import 'addMember_Exception.dart';

class FirebaseCarpool {
  static FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static ApiTopic apiTopic = ApiTopic();


  static const storage = FlutterSecureStorage();
  late String nickName = ""; // 기본값으로 초기화
  late String uid = "";
  late String gender = "";

  // ///출발 시간순으로 조회 (출발 시간이 현재시간을 넘으면 제외)
  // static Future<List<DocumentSnapshot>> getCarpoolsTimeby(int limit) async {
  //   CollectionReference carpoolCollection = _firestore.collection('carpool');
  //   QuerySnapshot querySnapshot = await carpoolCollection
  //       .where('startTime',
  //           isGreaterThan: DateTime.now().millisecondsSinceEpoch)
  //       .orderBy('startTime')
  //       .limit(limit)
  //       .get();
  //
  //   List<DocumentSnapshot> sortedCarpools = [];
  //   print("조회된 카풀 수(getCarpoolsTimeby): ${querySnapshot.docs.length}");
  //
  //   // 현재 시간을 가져옵니다.
  //   DateTime currentTime = DateTime.now();
  //
  //   querySnapshot.docs.forEach((doc) {
  //     DateTime startTime =
  //         DateTime.fromMillisecondsSinceEpoch(doc['startTime']);
  //
  //     // 현재 시간보다 미래의 시간인 경우만 추가
  //     if (startTime.isAfter(currentTime)) {
  //       sortedCarpools.add(doc);
  //     }
  //   });
  //
  //   sortedCarpools.sort((a, b) {
  //     DateTime startTimeA = DateTime.fromMillisecondsSinceEpoch(a['startTime']);
  //     DateTime startTimeB = DateTime.fromMillisecondsSinceEpoch(b['startTime']);
  //
  //     return startTimeA.compareTo(startTimeB);
  //   });
  //
  //   return sortedCarpools;
  // }

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
    required String memberGender,
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

      List<String> members = ['${memberID}_${memberName}_$memberGender'];

      print(selectedLimit.replaceAll(RegExp(r'[^\d]'), ''));

      DocumentReference carpoolDocRef = await users.add({
        'admin': '${memberID}_${memberName}_$memberGender',
        'startPointName': startPointName,
        'startPoint': geoStart,
        'endPointName': endPointName,
        'endPoint': geoEnd,
        'maxMember': int.parse(selectedLimit.replaceAll(RegExp(r'[^\d]'), '')),
        'gender': selectedRoomGender,
        'startTime': dateAsInt,
        'nowMember': 1,
        'status': false,
        'members': members,
        'startDetailPoint': startDetailPoint,
        'endDetailPoint': endDetailPoint,
      });
      await carpoolDocRef.update({'carId': carpoolDocRef.id});

      /// 0918 해당 카풀 알림 토픽 추가
      if(Prefs.isPushOnRx.get() == true){
        await FirebaseMessaging.instance.subscribeToTopic(carpoolDocRef.id);
      }
      TopicRequstDTO topicRequstDTO = TopicRequstDTO(uid: memberID, carId: carpoolDocRef.id);
      await apiTopic.saveTopoic(topicRequstDTO);

        print("토픽 추가");
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
  static Future<void> updateNewChatCount(
      String carpoolId, int newChatCount) async {
    try {
      await _firestore.collection('carpools').doc(carpoolId).update({
        'newchat': newChatCount,
      });
    } catch (e) {
      print(e);
      throw e;
    }
  }

  /// 카풀에 멤버 추가
  static Future<void> addMemberToCarpool(
      String carpoolID,
      String memberID,
      String memberName,
      String memberGender,
      String token,
      String roomGender) async {
    CollectionReference carpoolCollection = _firestore.collection('carpool');
    DocumentReference carpoolDocRef = carpoolCollection.doc(carpoolID);

    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot carpoolSnapshot = await transaction.get(carpoolDocRef);

        if (!carpoolSnapshot.exists) {
          // 카풀 정보가 없는 경우 처리
          throw DeletedRoomException('삭제된 카풀입니다.\n다른 카풀을 참여해주세요.');
        }

        int nowMember = carpoolSnapshot['nowMember'];
        int maxMember = carpoolSnapshot['maxMember'];

        if (nowMember < maxMember) {
          transaction.update(carpoolDocRef, {
            'members': FieldValue.arrayUnion(
                ['${memberID}_${memberName}_$memberGender']),
            'nowMember': FieldValue.increment(1),
          });
          FireStoreService().saveToken(
            token,
            carpoolID,
          );
          FireStoreService().sendEntryMessage(carpoolID, memberName);
        } else {
          // 최대 인원 초과 시 처리
          throw MaxCapacityException('최대 인원을 초과했습니다.\n다른 카풀을 이용해주세요.');
        }
      });
      print('카풀에 유저가 추가되었습니다 -> ${memberID}_${memberName}');
    } catch (e) {
      // 예외를 다시 던져서 메소드를 호출한 곳에 전달
      // throw e;
      if (e is DeletedRoomException) {
        // 카풀 정보가 없는 경우 예외 처리
        print('카풀 정보가 없는 경우 처리: ${e.message}');
        throw e;
        // 예외 처리 코드 추가
      } else if (e is MaxCapacityException) {
        // 최대 인원 초과 예외 처리
        print('최대 인원 초과: ${e.message}');
        throw e;
        // 예외 처리 코드 추가
      } else {
        // 기타 예외 처리
        print('기타 예외: $e');
        throw e;
        // 예외 처리 코드 추가
      }
    }
  }

  /// 시간순으로 조회, 정렬
  static Future<List<DocumentSnapshot>> timeByFunction(
      int limit, DocumentSnapshot? startAfter) async {
    CollectionReference carpoolCollection =
        FirebaseFirestore.instance.collection('carpool');
    Query query = carpoolCollection
        .where('startTime',
            isGreaterThan:
                DateTime.now().millisecondsSinceEpoch) // 현재 시간보다 미래의 시간인 경우만 추가
        .orderBy('startTime') // 출발 시간순으로 정렬
        .limit(limit); // limit 만큼만 가져옴

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    QuerySnapshot querySnapshot = await query.get();

    List<DocumentSnapshot> sortedCarpools = [];
    print("추가된 카풀 수(시간순): ${querySnapshot.docs.length}");

    // 현재 시간 가져옴
    DateTime currentTime = DateTime.now();

    querySnapshot.docs.forEach((doc) {
      DateTime startTime =
          DateTime.fromMillisecondsSinceEpoch(doc['startTime']);

      // 현재 시간보다 미래의 시간인 경우만 추가
      if (startTime.isAfter(currentTime)) {
        sortedCarpools.add(doc);
      }
    });
    return sortedCarpools;
  }

  /// 거리순 정렬
  static Future<List<DocumentSnapshot>> nearByCarpool(
      double myLat, double myLon) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('carpool')
        .where('startTime',
            isGreaterThan: DateTime.now().millisecondsSinceEpoch)
        .get();

    List<Map<String, dynamic>> sortedCarpools = [];
    print("조회된 카풀 총 개수(nearBy): ${querySnapshot.docs.length}");

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

  /// 거리 계산
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
      String memberID, String memberName, String memberGender) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('carpool')
        .where('members',
            arrayContains: '${memberID}_${memberName}_$memberGender')
        .get();

    List<DocumentSnapshot> sortedCarpools = [];
    print("조회된 카풀 수(참여): ${querySnapshot.docs.length}");

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
