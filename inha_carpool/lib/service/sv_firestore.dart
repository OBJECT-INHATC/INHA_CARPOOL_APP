import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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

  /// CollectionReference - FcmTokens Collection
  final CollectionReference fcmTokensCollection =
  FirebaseFirestore.instance.collection("fcmTokens");

  final User? user = FirebaseAuth.instance.currentUser;

  /// 0824 서은율
  /// 사용자 정보 저장
  Future savingUserData(String nickName, String email, String fcmToken, String gender) async {
    return await userCollection.doc(uid).set({
      "nickName": nickName,
      "email": email,
      "carpools": [],
      "uid": uid,
      "fcmToken": fcmToken,
      "gender" : gender,
    });
  }

  /// 0824 서은율
  /// 이메일로 사용자 정보 가져오기
  Future gettingUserData(String email) async {

    QuerySnapshot snapshot =
    await userCollection.where("email", isEqualTo: email).get();
    return snapshot;

  }

  /// 0828 한승완
  /// 특정 시점 이후의 채팅 메시지 스트림 가져오기
  getChatsAfterSpecTime(String carId, int time) async {
    return carpoolCollection
        .doc(carId)
        .collection("messages")
        .orderBy("time")
        .startAfter([time])
        .snapshots();
  }

  /// 0828 한승완
  /// 채팅 메시지 스트림 가져오기
  getChats(String carId) async {
    return carpoolCollection
        .doc(carId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  /// 0828 한승완
  /// 그룹 관리자 가져오기
  Future getGroupAdmin(String carId) async {
    DocumentReference d = carpoolCollection.doc(carId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  /// 0828 한승완
  /// 메시지 전송
  sendMessage(String carId, Map<String, dynamic> chatMessageData) async {
    final carpoolDocRef = carpoolCollection.doc(carId);

    // 최근 메시지 정보 업데이트
    await carpoolDocRef.update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });

    // 사용자 FCM 토큰 get
    var myToken = await FirebaseMessaging.instance.getToken();

    // 다른 유저의 FCM 토큰 get
    QuerySnapshot tokensSnapshot = await fcmTokensCollection.where("carId", isEqualTo: carId).get();
    List<String> tokenList = tokensSnapshot.docs.map((doc) => doc['token'] as String).toList();

    tokenList.remove(myToken);

    await carpoolDocRef.collection("messages").add(chatMessageData);

    // FCM 메시지 전송
    FcmService().sendMessage(
      tokenList: tokenList,
      title: "새로운 채팅이 도착했습니다.",
      body: "${chatMessageData['sender']} : ${chatMessageData['message']}",
      chatMessage: ChatMessage(
        carId: carId,
        message: chatMessageData['message'],
        sender: chatMessageData['sender'],
        time: chatMessageData['time'],
      ),
    );

  }

  ///0830 서은율
  ///카풀 참가시 유저 입장 메시지 전송
  Future sendEntryMessage(String carId, String userName) async {
    Map<String, dynamic> chatMessageMap = {
      "message": "$userName님이 입장하였습니다.",
      "sender": 'service',
      "time": DateTime.now().millisecondsSinceEpoch,
    };
    return carpoolCollection.doc(carId).collection("messages").add(chatMessageMap);
  }
  /// 0829 한승완 - 서버에 Fcm 토큰 저장
  Future<void> saveToken(String token, String carId) async {
    // 이미 해당 carId로 저장된 토큰이 있는지 확인
    QuerySnapshot existingTokens = await fcmTokensCollection.where("carId", isEqualTo: carId).get();
    bool tokenExists = false;

    for (QueryDocumentSnapshot tokenDoc in existingTokens.docs) {
      if (tokenDoc["token"] == token) {
        tokenExists = true;
        break;
      }
    }

    // 이미 저장된 토큰이 없는 경우에만 저장
    if (!tokenExists) {
      await fcmTokensCollection.add(
        {
          "token": token,
          "carId": carId,
        },
      );
    }
  }

  /// 0829 한승완 - 서버에 Fcm 토큰 삭제
  /// TODO : 추후에 방 나가기 기능이 생겼을 때 연결 해야 함
  Future deleteTokenByCarId(String token, String carId) async {
    return await fcmTokensCollection
        .where("token", isEqualTo: token)
        .where("carId", isEqualTo: carId)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        element.reference.delete();
      });
    });
  }


  getMembersList(String carId) async {
    DocumentReference d = carpoolCollection.doc(carId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['members'];
  }

}