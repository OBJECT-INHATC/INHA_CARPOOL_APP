import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:inha_Carpool/common/common.dart';

//import 'package:inha_Carpool/lib/common/constants.dart';

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
  late Future<String> userNameFuture;
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
    userNameFuture = _loadUserDataForKey("userName");
  }

  Future<String> _loadUserDataForKey(String key) async {
    return await storage.read(key: key) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x00000000),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                // 기본정보 항목
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6.0),
                  color: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 13.0), // vertical 값을 조정
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // 추가
                    children: [
                      Text(
                        '기본 정보',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                // 기본정보 학목 중 프로필사진, 닉네임 부분
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
                                  size: 50,
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
                                      snapshot.data ?? '',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Colors.black,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 25,
                          bottom: 15,
                          child: GestureDetector(
                            onTap: () {
                              _showEditNicknameDialog(context);
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.edit, size: 15, color: Colors.grey),
                                Text(
                                  "수정",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                                // SizedBox(width: 5),

                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      "이메일",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      width: 28,
                    ),
                    FutureBuilder<String?>(
                      future: emailFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          email = snapshot.data ?? '';
                          return Text(
                            snapshot.data ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black,
                            ),
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
                      "이름",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      width: 40,
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
                                fontSize: 13, color: Colors.black),
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
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      width: 27,
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
                            snapshot.data ?? '',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.black),
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
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    FutureBuilder<String?>(
                      future: genderFuture,
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
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          )
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
                  int result =
                  await updateNickname(newNickname, AutofillHints.email);

                  if (result == 1) {
                    // 업데이트 성공 팝업
                    Navigator.of(context).pop();
                    _showResultPopup(context, "수정 완료", "닉네임이 성공적으로 수정되었습니다.");

                    // 업데이트된 닉네임으로 상단의 닉네임 다시 빌드
                    setState(() {
                      var nickNameFuture = Future.value(newNickname);
                    });
                  } else if (result == 2) {
                    // 중복된 닉네임 팝업
                    _showResultPopup(
                        context, "오류", "중복된 닉네임이 있습니다. 다른 닉네임을 선택하세요.");
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
}

void setState(Null Function() param0) {}

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

        // FlutterSecureStorage에 닉네임 업데이트
        var storage;
        await storage.write(key: 'nickName', value: newNickname);
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


