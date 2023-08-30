import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../common/constants.dart';

class ProFile extends StatefulWidget {
  const ProFile({Key? key}) : super(key: key);

  @override
  _ProFileState createState() => _ProFileState();
}

class _ProFileState extends State<ProFile> {
  final storage = FlutterSecureStorage();
  late Future<String> nickNameFuture;
  late Future<String> uidFuture;
  late Future<String> genderFuture;
  late Future<String> emailFuture;
  late TextEditingController _nameController;

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

    _nameController = TextEditingController();
  }

  Future<String> _loadUserDataForKey(String key) async {
    return await storage.read(key: key) ?? "";
  }


  int _remainingChars = 10; // 남은 글자 수



  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
      color: Color(0x52dededf),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    _showEditNameDialog(context);
                  },
                  child: Column(
                    children: [
                      Image.asset(
                        "${basePath}/darkmode/moon.png",
                        width: 70,
                        height: 75,
                      ),
                      FutureBuilder<String?>(
                        future: nickNameFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator(); // 로딩 중이면 로딩 스피너 표시
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            return Text(
                              snapshot.data ?? '', // 데이터가 있으면 표시
                              style: TextStyle(fontSize: 15, color: Colors.black),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                ElevatedButton(
                  onPressed: () {
                    _showEditNameDialog(context);
                  },
                  child: Text(
                    "수정하기",
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(70, 24),
                  ),
                ),
                SizedBox(
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
                        child: Text(
                          "기본정보",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "이메일",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          SizedBox(
                            width: 28,
                          ),
                          FutureBuilder<String?>(
                            future: emailFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Text(
                                  snapshot.data ?? '',
                                  style: TextStyle(fontSize: 15, color: Colors.black),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "성별",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          FutureBuilder<String?>(
                            future: genderFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                return Text(
                                  snapshot.data ?? '',
                                  style: TextStyle(fontSize: 15, color: Colors.black),
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _showEditNameDialog(BuildContext context) async {
    String newName = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("이름 변경"),
          content: TextField(
            controller: _nameController,
            maxLength: 10,
            onChanged: (text) {
              setState(() {
                _remainingChars = 10 - text.length;
              });
            },
            decoration: InputDecoration(
              hintText: "새로운 이름을 입력하세요",
              counterText: "${_remainingChars}/10", // 글자 수 카운트 표시, 수정해야됨
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("취소"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_nameController.text);
              },
              child: Text("저장"),
            ),
          ],
        );
      },
    );

    if (newName != null) {
      setState(() {
        _nameController.text = newName;
      });

      // 수정완료다이얼로그 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("수정 완료"),
            content: const Text("이름이 성공적으로 수정되었습니다."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("확인"),
              ),
            ],
          );
        },
      );
    }
  }
}