import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:inha_Carpool/common/database/d_chat_dao.dart';
import 'package:inha_Carpool/service/sv_fcm.dart';
import '../common/models/m_chat.dart';

/// DatabaseService class - Firebase Firestore Database 관련 함수들을 모아놓은 클래스
class FireStoreService {
  /// uid - 현재 사용자의 uid
  final String? uid;

  /// 생성자
  FireStoreService({this.uid});

  /// CollectionReference - User Collection
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");

  /// CollectionReference - Carpool Collection
  final CollectionReference carpoolCollection =
      FirebaseFirestore.instance.collection("carpool");

  final CollectionReference adminCollection =
  FirebaseFirestore.instance.collection("admin");

  final User? user = FirebaseAuth.instance.currentUser;

  /// 사용자 정보 저장
  Future savingUserData(String userName, String nickName, String email,
      String fcmToken, String gender) async {
    return await userCollection.doc(uid).set({
      "userName": userName,
      "nickName": nickName,
      "email": email,
      "carpools": [],
      "uid": uid,
      "fcmToken": fcmToken,
      "gender": gender,
    });
  }



/*  /// 파이어베이스에서 해당 데이터가 있는지 확인하는 함수
  Future<bool> isDataExist(String carId, String adminId) async {
    final snapshot =
        await carpoolCollection.doc(carId).collection("messages").where();
    return snapshot.exists;
  }*/

  //isCHatAlarmOn을 파베에서 삭제
  Future<void> deleteIsChatAlarm(String carId, String uid) async {
    await carpoolCollection
        .doc(carId)
        .collection("isChatAlarm")
        .doc(uid)
        .delete();
  }

  /// 이메일로 사용자 정보 가져오기
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  /// uid로 사용자가 존재하는지 확인
  Future<bool> isUserExist(String uid) async {
    QuerySnapshot snapshot =
        await userCollection.where("uid", isEqualTo: uid).get();
    return snapshot.docs.isNotEmpty;
  }

  /// 특정 시점 이후의 채팅 메시지 스트림 가져오기
  getChatsFirstTime(String carId, int time) async {
    return carpoolCollection
        .doc(carId)
        .collection("messages")
        .orderBy("time")
        .startAfter([time]).snapshots();
  }

  getChatsAfterSpecTime(String carId) async {
    return carpoolCollection
        .doc(carId)
        .collection("messages")
        .snapshots();
  }

  /// 특정 시점 이후의 채팅 메시지 스트림 가져오기
  getFirstChat(String carId) async {
    return carpoolCollection.doc(carId).collection("messages").snapshots();
  }

  /// 채팅 메시지 스트림 가져오기
  getChats(String carId) async {
    return carpoolCollection
        .doc(carId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  /// 그룹 관리자 가져오기
  Future getGroupAdmin(String carId) async {
    DocumentReference d = carpoolCollection.doc(carId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  /// 메시지 전송
  sendMessage(String carId, Map<String, dynamic> chatMessageData) async {
    final carpoolDocRef = carpoolCollection.doc(carId);

    // 최근 메시지 정보 업데이트
    await carpoolDocRef.update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
      'unreadCount': FieldValue.increment(1),
    });

    await carpoolDocRef.collection("messages").add(chatMessageData);

    // FCM 메시지 전송
    FcmService().sendMessage(
      title: "새로운 채팅이 도착했습니다.",
      body: "${chatMessageData['sender']} : ${chatMessageData['message']}",
      chatMessage: ChatMessage(
        carId: carId,
        message: chatMessageData['message'],
        sender: chatMessageData['sender'],
        time: chatMessageData['time'],
      ),
      type: NotificationType.chat,
    );
  }

  ///0909 서은율 읽지않은 메시지 리셋
  Future<void> resetUnreadCount(String carId) async {
    final carpoolDocRef = carpoolCollection.doc(carId);
    await carpoolDocRef.update({
      'unreadCount': 0,
    });
  }

  /// 주소 기반 API 초기화
  Future<String> getJusoKey() async {
     DocumentSnapshot snapShot = await adminCollection.doc('jusoKey').get();
    return snapShot['apiKey'];
  }

  ///카풀 참가시 유저 입장 메시지 전송 + 로컬 DB에 저장
  Future<void> sendEntryMessage(String carId, String userName) async {
    const String sender = 'service';
    final int currentTime = DateTime.now().millisecondsSinceEpoch;

    final Map<String, dynamic> chatMessageMap = {
      "message": "$userName님이 입장하였습니다.",
      "sender": sender,
      "time": currentTime,
    };

    final ChatMessage chatMessage = ChatMessage(
      carId: carId,
      message: chatMessageMap['message'],
      sender: chatMessageMap['sender'],
      time: chatMessageMap['time'],
    );

    ChatDao().insert(chatMessage);
    await carpoolCollection
        .doc(carId)
        .collection("messages")
        .add(chatMessageMap);
    await carpoolCollection.doc(carId).update(
      {
        'recentMessage': chatMessageMap['message'],
        'recentMessageSender': chatMessageMap['sender'],
        'recentMessageTime': chatMessageMap['time']
      },
    );

    FcmService().sendMessage(
        title: "$userName님이 참가했습니다.",
        body: "즐거운 카풀 되세요!",
        chatMessage: chatMessage,
        type: NotificationType.status);
  }

  /// 카풀 탈퇴시 유저 퇴장 메시지 전송 + 로컬 DB 삭제
  Future<void> sendExitMessage(String carId, String userName) async {
    const String sender = 'service';
    final int currentTime = DateTime.now().millisecondsSinceEpoch;

    final Map<String, dynamic> chatMessageMap = {
      "message": "$userName님이 퇴장하였습니다.",
      "sender": sender,
      "time": currentTime,
    };

    final ChatMessage chatMessage = ChatMessage(
      carId: carId,
      message: chatMessageMap['message'],
      sender: chatMessageMap['sender'],
      time: chatMessageMap['time'],
    );

    // 메시지 전송
    await carpoolCollection
        .doc(carId)
        .collection("messages")
        .add(chatMessageMap);
    FcmService().sendMessage(
        title: "$userName님이 퇴장하였습니다.",
        body: "카풀 인원을 확인하세요.",
        chatMessage: chatMessage,
        type: NotificationType.status);

    await carpoolCollection.doc(carId).update(
      {
        'recentMessage': chatMessageMap['message'],
        'recentMessageSender': chatMessageMap['sender'],
        'recentMessageTime': chatMessageMap['time']
      },
    );

    //5초 후
    await Future.delayed(const Duration(seconds: 3));
    // 로컬 DB 삭제
    ChatDao().deleteByCarId(carId);
  }

  ///카풀 생성 + 로컬 DB에 저장
  Future<void> sendCreateMessage(String carId, String userName) async {
    final ChatMessage chatMessage = ChatMessage(
      carId: carId,
      message: "$userName님이 새로운 카풀을 생성하였습니다.",
      sender: 'service',
      time: DateTime.now().millisecondsSinceEpoch,
    );

    ChatDao().insert(chatMessage);
  }

  // 카풀 정보 가져오기
  Future<Map<String, dynamic>> getCarDetails(String carId) async {
    DocumentReference documentRef = carpoolCollection.doc(carId);
    DocumentSnapshot snapshot = await documentRef.get();

    Map<String, dynamic> carData = snapshot.data() as Map<String, dynamic>;
    return carData;
  }

  // 카풀 나가기
  exitCarpool(String carId, String nickName, String uid, String gender) async {
    DocumentReference carpoolDocRef = carpoolCollection.doc(carId);

    print("${uid}_${nickName}_$gender");

    /// 0902 김영재. 마지막 사람이 방을 나가면 status를 true로 변경
    await carpoolDocRef.update({
      'members': FieldValue.arrayRemove(['${uid}_${nickName}_$gender']),
      'nowMember': FieldValue.increment(-1),
    });

    // 탈퇴 메시지 전송
    FireStoreService().sendExitMessage(carId, nickName);
  }

  deleteCarpool(String carId) async {
    DocumentReference carpoolDocRef = carpoolCollection.doc(carId);
    await carpoolDocRef.delete();
  }

  // 방장의 카풀 나가기
  exitCarpoolAsAdmin(
      String carId, String nickName, String uid, String gender) async {
    DocumentReference carpoolDocRef = carpoolCollection.doc(carId);

    DocumentSnapshot carpoolSnapshot = await carpoolDocRef.get();

    int nowMember = carpoolSnapshot['nowMember'];

    if (nowMember == 1) {
      // 방 삭제
      await carpoolDocRef.delete();
    } else {
      await carpoolDocRef.update({
        'members': FieldValue.arrayRemove(['${uid}_${nickName}_$gender']),
        'nowMember': FieldValue.increment(-1),
      });

      DocumentSnapshot carpoolSnapshot = await carpoolDocRef.get();
      List<dynamic> members = carpoolSnapshot['members'];
      if (members.isNotEmpty) {
        String newAdmin = members[0]; // 첫 번째 멤버를 새로운 방장으로 설정 (원하는 규칙에 따라 변경 가능)
        await carpoolDocRef.update({
          'admin': newAdmin,
        });
      }

      // 탈퇴 메시지 전송
      FireStoreService().sendExitMessage(carId, nickName);
    }
  }

  Stream<DocumentSnapshot?> getLatestMessageStream(String carId) {
    return carpoolCollection
        .doc(carId)
        .collection('messages')
        .orderBy('time', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.isNotEmpty ? snapshot.docs.first : null);
  }

  ///  사용자가 현재 참가한 카풀이 존재하는지 확인하는 메서드
  Future<bool> isUserInCarpool(
      String uid, String nickName, String gender) async {
    QuerySnapshot snapshot = await carpoolCollection
        .where("members", arrayContains: "${uid}_${nickName}_$gender")
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  ///  사용자가 현재 참가한 카풀이 존재하는지 확인하는 메서드
  Future<bool> StartTimeInCarpool(
      String uid, String nickName, String gender) async {
    DateTime currentTime = DateTime.now();
    int currentTimeMillis = currentTime.millisecondsSinceEpoch;

    QuerySnapshot snapshot = await carpoolCollection
        .where("members", arrayContains: "${uid}_${nickName}_$gender")
        .get();

    for (var doc in snapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      if (data['startTime'] >= currentTimeMillis) {
        return true;
      }
    }
    return false;
  }

  Future<void> handleEndCarpoolSignal(String carId) async {
    // FCM에서 해당 carId의 토픽 구독 취소
    FirebaseMessaging.instance.unsubscribeFromTopic(carId);
    FirebaseMessaging.instance.unsubscribeFromTopic("${carId}_info");

    // 로컬 DB에서 해당 카풀 정보 삭제
    ChatDao().deleteByCarId(carId);
  }

  Future<int> getCarpoolStartTime(String carId) async {
    if (carId == '' || carId == null) return 0;
    DocumentSnapshot carpool =
        await FirebaseFirestore.instance.collection('carpool').doc(carId).get();
    if (carpool == null) return 0;
    int startTime = carpool.get('startTime');
    return startTime;
  }
}
