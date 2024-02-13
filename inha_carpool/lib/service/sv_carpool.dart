import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/service/sv_fcm.dart';
import 'package:inha_Carpool/service/sv_firestore.dart';

import '../common/util/addMember_Exception.dart';

class CarpoolService {
   final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  /// 카풀 저장
   Future<String> addDataToFireStore({
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

    int dateAsInt = combinedDateTime.millisecondsSinceEpoch;
    String tempCarId = "";

      CollectionReference users = _fireStore.collection('carpool');
      GeoPoint geoStart = GeoPoint(startPoint.latitude, startPoint.longitude);
      GeoPoint geoEnd = GeoPoint(endPoint.latitude, endPoint.longitude);

      List<String> members = ['${memberID}_${memberName}_$memberGender'];

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
        'recentMessageSender': "service",
        'recentMessage': "$memberName님이 새로운 카풀을 생성하였습니다.",
        'members': members,
        'startDetailPoint': startDetailPoint,
        'endDetailPoint': endDetailPoint,
      });

      await carpoolDocRef.update({'carId': carpoolDocRef.id});
      tempCarId = carpoolDocRef.id;

      // 해당 carid에 message collection 생성
      await carpoolDocRef.collection("messages").add({
        'message': "$memberName님이 새로운 카풀을 생성하였습니다.",
        'sender': 'service',
        'time': DateTime.now().millisecondsSinceEpoch,
      });

      // 구독
    await FcmService().subScribeTopic(tempCarId);

    // 구독정보 서버에 저장
    bool isOpen = await FcmService().saveTopicToServer(memberID, tempCarId);

    if (isOpen) {
      print("서버 성공 #######");
      // 참가 메세지 전송
      await FireStoreService().sendCreateMessage(tempCarId, memberName);

      return tempCarId;
    } else {
      print("서버 실패 #######");
      // 토픽 삭제
      await FcmService().unSubScribeTopic(tempCarId);
      // 파이어스토어 카풀 삭제
      await deleteCarpoolToFireStore(tempCarId);

      return "";
    }
  }

  /// 카풀 삭제
   Future<void> deleteCarpoolToFireStore(String carId) async {
    await _fireStore.collection('carpool').doc(carId).delete();
  }

  /// 카풀에 새로운 멤버 추가
   Future<void> addMemberToCarpool(
      String carpoolID,
      String memberID,
      String memberName,
      String memberGender,
      String roomGender) async {
    CollectionReference carpoolCollection = _fireStore.collection('carpool');
    DocumentReference carpoolDocRef = carpoolCollection.doc(carpoolID);

    try {
      await _fireStore.runTransaction((transaction) async {
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
          FireStoreService().sendEntryMessage(carpoolID, memberName);
        } else {
          // 최대 인원 초과 시 처리
          throw MaxCapacityException('최대 인원을 초과했습니다.\n다른 카풀을 이용해주세요.');
        }
      });
      print('카풀에 유저가 추가되었습니다 -> ${memberID}_$memberName');
    } catch (e) {
      // 예외를 다시 던져서 메소드를 호출한 곳에 전달
      // throw e;
      if (e is DeletedRoomException) {
        // 카풀 정보가 없는 경우 예외 처리
        print('카풀 정보가 없는 경우 처리: ${e.message}');
        rethrow;
        // 예외 처리 코드 추가
      } else if (e is MaxCapacityException) {
        // 최대 인원 초과 예외 처리
        print('최대 인원 초과: ${e.message}');
        rethrow;
        // 예외 처리 코드 추가
      } else {
        // 기타 예외 처리
        print('기타 예외: $e');
        rethrow;
        // 예외 처리 코드 추가
      }
    }
  }

  /// 시간순으로 조회, 정렬
   Future<List<DocumentSnapshot>> timeByFunction(
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

    for (var doc in querySnapshot.docs) {
      DateTime startTime =
          DateTime.fromMillisecondsSinceEpoch(doc['startTime']);

      // 현재 시간보다 미래의 시간인 경우만 추가
      if (startTime.isAfter(currentTime)) {
        sortedCarpools.add(doc);
      }
    }
    return sortedCarpools;
  }


  /// 거리순 정렬
   Future<List<DocumentSnapshot>> nearByCarpool(
      double myLat, double myLon) async {
    QuerySnapshot querySnapshot = await _fireStore
        .collection('carpool')
        .where('startTime',
            isGreaterThan: DateTime.now().millisecondsSinceEpoch)
        .get();

    List<Map<String, dynamic>> sortedCarpools = [];
    print("조회된 카풀 총 개수(nearBy): ${querySnapshot.docs.length}");

    // 현재 시간을 가져옵니다.
    DateTime currentTime = DateTime.now();

    for (var doc in querySnapshot.docs) {
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
    }

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

  // 거리 계산
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

  /// 내가 참여한 카풀 - 메인 플로팅 버튼에 사용
   Future<List<DocumentSnapshot>> getCarpoolsWithMember(
      String memberID, String memberName, String memberGender) async {
    QuerySnapshot querySnapshot = await _fireStore
        .collection('carpool')
        .where('members',
            arrayContains: '${memberID}_${memberName}_$memberGender')
        .get();

    List<DocumentSnapshot> sortedCarpools = [];
    // 현재 시간을 가져옵니다.
    DateTime currentTime = DateTime.now();

    for (var doc in querySnapshot.docs) {
      DateTime startTime =
          DateTime.fromMillisecondsSinceEpoch(doc['startTime']);

      // 현재 시간보다 미래의 시간인 경우만 추가
      if (startTime.isAfter(currentTime)) {
        sortedCarpools.add(doc);
      }
    }
    sortedCarpools.sort((a, b) {
      DateTime startTimeA = DateTime.fromMillisecondsSinceEpoch(a['startTime']);
      DateTime startTimeB = DateTime.fromMillisecondsSinceEpoch(b['startTime']);

      return startTimeA.compareTo(startTimeB);
    });

    return sortedCarpools;
  }

  /// 내가 참여한 카풀 - 내가 참가한 카풀 리스트에 사용
   Future<List<DocumentSnapshot>> getCarpoolsRemainingForDay(
      String memberID, String memberName, String memberGender) async {
    QuerySnapshot querySnapshot = await _fireStore
        .collection('carpool')
        .where('members',
            arrayContains: '${memberID}_${memberName}_$memberGender')
        .get();

    List<DocumentSnapshot> sortedCarpools = [];

    // 해당 도큐먼트의 출발시간을 기준으로 계산하니 필요없을 것 같아 주석처리함
    DateTime currentTime = DateTime.now();
    for (var doc in querySnapshot.docs) {
      DateTime startTime =
          DateTime.fromMillisecondsSinceEpoch(doc['startTime']);

      // 하루가 지나기 전까지의 카풀 추가
      if (startTime.isAfter(currentTime.subtract(const Duration(days: 1)))) {
        sortedCarpools.add(doc);
      }
    }

    sortedCarpools.sort((a, b) {
      DateTime startTimeA = DateTime.fromMillisecondsSinceEpoch(a['startTime']);
      DateTime startTimeB = DateTime.fromMillisecondsSinceEpoch(b['startTime']);

      return startTimeA.compareTo(startTimeB);
    });

    return sortedCarpools;
  }
}
