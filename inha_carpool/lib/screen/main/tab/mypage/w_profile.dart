import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:inha_Carpool/common/common.dart';

/// 상단 프로필 페이지 위젯
/// 닉네임 수정 기능 모두 off
class ProFile extends StatefulWidget {
  const ProFile({Key? key}) : super(key: key);

  @override
  _ProFileState createState() => _ProFileState();
}

class _ProFileState extends State<ProFile> {
  final storage = FlutterSecureStorage();
  late Future<String> nickNameFuture;
  late Future<String> genderFuture;
  late Future<String> emailFuture;
  late Future<String> userNameFuture;
  late String email;
  late String uid;

  String? nickName;
  String? gender;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    nickNameFuture = _loadUserDataForKey("nickName");
    genderFuture = _loadUserDataForKey("gender");
    emailFuture = _loadUserDataForKey("email");
    userNameFuture = _loadUserDataForKey("userName");
    uid = await storage.read(key: 'uid') ?? "";
    nickName = await storage.read(key: "nickName");
    gender = await storage.read(key: "gender");
    email = await storage.read(key: "email") ?? "";
  }

  Future<String> _loadUserDataForKey(String key) async {
    return await storage.read(key: key) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    Colors.transparent; // 틴트 제외
    //프로필 수정 버튼 screenWidth,screenHeight 변수 선언
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      color: const Color(0x00000000),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 10),
                // 기본정보 항목 중 프로필사진, 닉네임 부분
                Row(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 5.0),
                                child: Icon(
                                  Icons.account_circle,
                                  size: 60,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(
                                width: 15,
                              ),
                              FutureBuilder<String?>(
                                future: nickNameFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return Text(
                                      // nickNameFuture의 닉네임 값
                                      snapshot.data ?? ' ',
                                      style: const TextStyle(
                                        fontSize: 21,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              FutureBuilder<String?>(
                                future: userNameFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else {
                                    return Text(
                                      snapshot.data ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey, // 이름 색 변경
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                /*const SizedBox(height: 10),

                //이메일란 원래 위치

                Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    onTap: () {
                      _showEditNicknameDialog(context, uid, nickName!, gender!);
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.05), // 좌우 여백 반응형으로 지정
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.transparent,
                          elevation: 5,
                          primary: Colors.blue[100],
                          // 버튼 배경색
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // 조금 둥글게
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01, // 위아래 여백 반응형으로 지정
                            horizontal: screenWidth * 0.05, // 좌우 여백 반응형으로 지정
                          ),
                        ),
                        onPressed: () {
                          _showEditNicknameDialog(context, uid, nickName!,
                              gender!); // 프로필 수정 버튼 클릭 시 _showEditNicknameDialog 함수 호출
                        },
                        child: const Center(
                          child: Text(
                            '닉네임 수정',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }

 /* Future<void> _showEditNicknameDialog(
      BuildContext context, String uid, String nickName, String gender) async {
    TextEditingController nicknameController = TextEditingController();

    bool userBool =
        await FireStoreService().StartTimeInCarpool(uid, nickName, gender);
    if (!mounted) return;

    if (userBool) {
      context.showErrorSnackbar('카풀에 참여중인 유저는 닉네임을 변경할 수 없습니다.');
    } else {
      await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            surfaceTintColor: Colors.transparent,
            title: const Text("닉네임 변경"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nicknameController,
                  maxLength: 10,
                  decoration: const InputDecoration(
                    hintText: "새로운 닉네임을 입력하세요",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("취소"),
              ),
              TextButton(
                onPressed: () async {
                  String newNickname = nicknameController.text;
                  if (newNickname.isNotEmpty && newNickname.length > 1) {
                    ApiUser apiUser = ApiUser();
                    print('uid : $uid, newNickname : $newNickname');
                    bool isOpen =
                        await apiUser.updateUserNickname(uid, newNickname);

                    if (isOpen) {
                      print("스프링부트 서버 성공 #############");
                      int result =
                          await updateNickname(newNickname, email, storage);

                      if (result == 1) {
                        // 업데이트 성공 팝업
                        if (!mounted) return;
                        Navigator.of(context).pop();
                        _showResultPopup(
                            context, "수정 완료", "닉네임이 성공적으로 수정되었습니다.");
                        setState(() {
                          nickNameFuture = _loadUserDataForKey("nickName");
                        });
                      } else if (result == 2) {
                        // 중복된 닉네임 팝업
                        if (!mounted) return;
                        _showResultPopup(
                            context, "오류", "중복된 닉네임이 있습니다. 다른 닉네임을 선택하세요.");
                      } else if (result == 0) {
                        // 이메일 일치 문서 없음 팝업
                        if (!mounted) return;
                        _showResultPopup(
                            context, "오류", "해당 이메일과 일치하는 문서가 없습니다.");
                      } else {
                        // 업데이트 실패 팝업
                        if (!mounted) return;
                        _showResultPopup(context, "오류", "닉네임 업데이트에 실패했습니다.");
                      }
                    } else {
                      print("스프링부트 서버 실패 #############");
                      if (!mounted) return;
                      _showResultPopup(
                          context, "오류", "서버가 정지하여 닉네임을 변경할 수 없습니다.");
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('2글자 이상 입력해주세요.'),
                      ),
                    );
                  }
                },
                child: const Text("저장"),
              ),
            ],
          );
        },
      );
    }
  }*/
}

/*void _showResultPopup(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,

        /// 소프트키보드가 올라왔을 때 다이얼로그의 사이즈가 조절되는 시간
        insetAnimationDuration: const Duration(milliseconds: 1000),

        /// 소프트키보드가 올라왔을 때 다이얼로그 사이즈 변경 애니메이션
        insetAnimationCurve: Curves.bounceOut,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        surfaceTintColor: Colors.transparent,
                        backgroundColor: Colors.blue[100],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("확인"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      // return AlertDialog(
      //   surfaceTintColor: Colors.transparent,
      //   title: Text(title),
      //   content: Text(content),
      //   actions: [
      //     TextButton(
      //       onPressed: () {
      //         Navigator.of(context).pop();
      //       },
      //       child: const Text("확인"),
      //     ),
      //   ],
      // );
    },
  );
}*/

/*Future<int> updateNickname(
    String newNickname, String email, FlutterSecureStorage storage) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference users = firestore.collection('users');

  try {
    // 이메일 값을 기반으로 쿼리를 수행하여 문서 ID를 가져옴
    final QuerySnapshot querySnapshot =
        await users.where('email', isEqualTo: email).get();

    // 쿼리 결과에서 문서 ID를 가져옴
    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot document = querySnapshot.docs.first;
      final String documentId = document.id;

      // 변경하려는 닉네임이 다른 문서의 닉네임과 중복되지 않는지 확인
      final QuerySnapshot duplicateNicknames =
          await users.where('nickName', isEqualTo: newNickname).get();

      // 중복된 닉네임이 없다면 닉네임을 업데이트
      if (duplicateNicknames.docs.isEmpty) {
        final DocumentReference userRef = users.doc(documentId);
        await userRef.update({'nickName': newNickname});

        // FlutterSecureStorage에 닉네임 기존 거 삭제
        await storage.delete(key: 'nickName');

        // FlutterSecureStorage에 닉네임 업데이트
        await storage.write(key: 'nickName', value: newNickname);

        print('파베 닉네임이 업데이트되었습니다. => $newNickname');
        return 1;
      } else {
        print('파베 중복된 닉네임이 있습니다. 다른 닉네임을 선택하세요.');
        return 2;
      }
    } else {
      print('파베 해당 이메일과 일치하는 문서가 없습니다.');
      return 0;
    }
  } catch (e) {
    print('Error updating nickname: $e');
    return -1;
  }
}*/
