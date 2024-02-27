import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/models/m_carpool.dart';
import 'package:inha_Carpool/common/models/m_member.dart';

final carpoolRepositoryProvider = Provider((ref) => DoingCarpoolRepository(ref));

class DoingCarpoolRepository {
  final Ref _ref;
  final _fireStore = FirebaseFirestore.instance;

  DoingCarpoolRepository(this._ref);

  Future<List<CarpoolModel>> getCarPoolList(MemberModel memberModel) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _fireStore
        .collection('carpool')
        .where('members',
        arrayContains:
        '${memberModel.uid}_${memberModel.nickName}_${memberModel.gender}')
    //.orderBy('startTime', descending: true)
        .get();

    // 리턴을 담아줄 리스트
    List<CarpoolModel> currentCarpoolList = [];
    List<CarpoolModel> oldCarpoolList = [];

    // 현재 시간과 출발시간을 비교할 변수
    DateTime currentTime = DateTime.now();
    DateTime oneDayAgo = currentTime.subtract(const Duration(days: 1));


    // 스냅샷을 돌면서 조건에 맞는 카풀을 리스트에 추가
    for (var doc in snapshot.docs) {
      CarpoolModel carModel = CarpoolModel.fromJson(doc.data());

      DocumentSnapshot isCheckAlarm =
      await _fireStore.collection("carpool")
          .doc(carModel.carId)
          .collection("isChatAlarm")
          .doc(memberModel.uid)
          .get();

      bool isChatAlarm = (isCheckAlarm.data() as Map<String, dynamic>?)?['isChatAlarmOn'] ?? true;

      carModel.isChatAlarmOn = isChatAlarm;

    // 가져온 데이터의 출발시간을 DateTime으로 변환
    DateTime startTime =
    DateTime.fromMillisecondsSinceEpoch(doc['startTime']);

    // 하루가 지나기 전까지의 카풀만 리스트에 추가하기 위한 비교 작업
      if (startTime.isAfter(currentTime)) {
        // 미래 카풀
        currentCarpoolList.add(carModel);
      } else if (startTime.isAfter(oneDayAgo)) {
        // 최대 하루 전 과거 카풀
        oldCarpoolList.add(carModel);
      }
    }

    currentCarpoolList.sort((a, b) {
    DateTime startTimeA =
    DateTime.fromMillisecondsSinceEpoch(a.startTime!.toInt());
    DateTime startTimeB =
    DateTime.fromMillisecondsSinceEpoch(b.startTime!.toInt());

    return startTimeA.compareTo(startTimeB);
    });

    oldCarpoolList.sort((a, b) {
      DateTime startTimeA =
      DateTime.fromMillisecondsSinceEpoch(a.startTime!.toInt());
      DateTime startTimeB =
      DateTime.fromMillisecondsSinceEpoch(b.startTime!.toInt());

      return startTimeB.compareTo(startTimeA);
    });

    return currentCarpoolList + oldCarpoolList;
  }

  // carId와 isChatAlarmOn을 업데이트
  Future<void> updateIsChatAlarm(String carId, String uid, bool isChatAlarmOn) async {
    try {
      await _fireStore.collection('carpool').doc(carId).collection('isChatAlarm').doc(uid).set({
        'isChatAlarmOn': isChatAlarmOn,
      });

    } catch (e) {
      print("CarpoolRepository [updateIsChatAlarm] 에러: $e");
    }
  }




}
