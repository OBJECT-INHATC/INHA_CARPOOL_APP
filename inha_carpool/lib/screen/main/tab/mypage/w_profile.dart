import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:inha_Carpool/common/common.dart';

import '../../../../common/constants.dart';

class ProFile extends StatefulWidget {
  const ProFile({Key? key}) : super(key: key);

  @override
  _ProFileState createState() => _ProFileState();
}

class _ProFileState extends State<ProFile> {
  final storage = const FlutterSecureStorage();
  late Future<String> nickNameFuture;
  late Future<String> uidFuture;
  late Future<String> genderFuture;
  late Future<String> emailFuture;
  late String email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    nickNameFuture = _loadUserDataForKey("nickName");
    uidFuture = _loadUserDataForKey("uid");
    genderFuture = _loadUserDataForKey("gender");
    emailFuture = _loadUserDataForKey("email");
  }

  Future<String> _loadUserDataForKey(String key) async {
    return await storage.read(key: key) ?? "";
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
      color: const Color(0x52dededf),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _showEditNicknameDialog(context);
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        "$basePath/darkmode/moon.png",
                        width: 70,
                        height: 75,
                      ),
                      FutureBuilder<String?>(
                        future: nickNameFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator(); // 로딩 중이면 로딩 스피너 표시
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                              snapshot.data ?? '', // 데이터가 있으면 표시
                              style: const TextStyle(fontSize: 15, color: Colors.black),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    _showEditNicknameDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(70, 24),
                  ),
                  child: const Text(
                    "수정하기",
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        child: const Text(
                          "기본정보",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            "이메일",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          const SizedBox(
                            width: 28,
                          ),
                          FutureBuilder<String?>(
                            future: emailFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                email = snapshot.data ?? '';
                                return Text(
                                  snapshot.data ?? '',
                                  style: const TextStyle(fontSize: 15, color: Colors.black),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            "성별",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                          FutureBuilder<String?>(
                            future: genderFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Text(
                                  snapshot.data ?? '',
                                  style: const TextStyle(fontSize: 15, color: Colors.black),
                                );
                              }
                            },
                          ),

                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          const Text(
                            "닉네임",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          const SizedBox(
                            width: 27,
                          ),
                          FutureBuilder<String?>(
                            future: nickNameFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Text(
                                  snapshot.data ?? '',
                                  style: const TextStyle(fontSize: 15, color: Colors.black),
                                );
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _showEditNicknameDialog(BuildContext context) async {
    TextEditingController nicknameController = TextEditingController();

     await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                  int result = await updateNickname(newNickname, email);

                  if (result == 1) {
                    // 업데이트 성공 팝업
                    Navigator.of(context).pop();
                    _showResultPopup(context, "수정 완료", "닉네임이 성공적으로 수정되었습니다.");

                    // 업데이트된 닉네임으로 상단의 닉네임 다시 빌드
                    setState(() {
                      nickNameFuture = Future.value(newNickname);
                    });
                  } else if (result == 2) {
                    // 중복된 닉네임 팝업
                    _showResultPopup(context, "오류", "중복된 닉네임이 있습니다. 다른 닉네임을 선택하세요.");
                  } else if (result == 0) {
                    // 이메일 일치 문서 없음 팝업
                    _showResultPopup(context, "오류", "해당 이메일과 일치하는 문서가 없습니다.");
                  } else {
                    // 업데이트 실패 팝업
                    _showResultPopup(context, "오류", "닉네임 업데이트에 실패했습니다.");
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

  void _showResultPopup(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("확인"),
            ),
          ],
        );
      },
    );
  }



  Future<int> updateNickname(String newNickname, String email) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference users = firestore.collection('users');

    try {
      // 이메일 값을 기반으로 쿼리를 수행하여 문서 ID를 가져옴
      final QuerySnapshot querySnapshot = await users.where('email', isEqualTo: email).get();

      // 쿼리 결과에서 문서 ID를 가져옴
      if (querySnapshot.docs.isNotEmpty) {
        final DocumentSnapshot document = querySnapshot.docs.first;
        final String documentId = document.id;

        // 변경하려는 닉네임이 다른 문서의 닉네임과 중복되지 않는지 확인
        final QuerySnapshot duplicateNicknames = await users
            .where('nickName', isEqualTo: newNickname)
            .get();

        // 중복된 닉네임이 없다면 닉네임을 업데이트
        if (duplicateNicknames.docs.isEmpty) {
          final DocumentReference userRef = users.doc(documentId);
          await userRef.update({'nickName': newNickname});

          print('닉네임이 업데이트되었습니다. => $newNickname');
          return 1;

        } else {
          print('중복된 닉네임이 있습니다. 다른 닉네임을 선택하세요.');
          return 2;
        }
      } else {
        print('해당 이메일과 일치하는 문서가 없습니다.');
        return 0;
      }
    } catch (e) {
      print('Error updating nickname: $e');
      return -1;
    }
  }


}

