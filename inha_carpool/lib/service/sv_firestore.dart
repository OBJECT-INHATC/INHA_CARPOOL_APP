import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  getChatsAfterSpecTime(String carId, int time) async {
    return carpoolCollection
        .doc(carId)
        .collection("messages")
        .orderBy("time")
        .startAfter([time])
        .snapshots();
  }

  /// 채팅 메시지 스트림 메서드
  getChats(String carId) async {
    return carpoolCollection
        .doc(carId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String carId) async {
    DocumentReference d = carpoolCollection.doc(carId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  sendMessage(String carId, Map<String, dynamic> chatMessageData) async {
    carpoolCollection.doc(carId).collection("messages").add(chatMessageData);

    // DocumentSnapshot carpoolSnapshot = await carpoolCollection.doc(groupId).get();
    // List<dynamic> members = carpoolSnapshot['members'];
    // List tokenList = [];
    // String token = '';
    //
    // for (var member in members) {
    //   token = member.substring(member.indexOf('-') + 1);
    //   if (token != myToken) {
    //     tokenList.add(token);
    //   }
    //   token = '';
    // }
    //
    // for(var token in tokenList) {
    //   print(token);
    // }
    // FcmService().sendMessage(
    //     groupName: groupName,
    //     tokenList: tokenList,
    //     title: "New Message in $groupName",
    //     body: "${chatMessageData['sender']} : ${chatMessageData['message']}",
    //     chatMessage: ChatMessage(
    //       groupId: groupId,
    //       message: chatMessageData['message'],
    //       sender: chatMessageData['sender'],
    //       time: chatMessageData['time'],
    //     )
    // );

  }

}