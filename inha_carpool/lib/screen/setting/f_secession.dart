import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../dialog/d_delete_auth.dart';

class SecessionPage extends StatefulWidget {

  @override
  State<SecessionPage> createState() => _SecessionPageState();
}

class _SecessionPageState extends State<SecessionPage> {

  final storage = FlutterSecureStorage();
  late Future<String> nickNameFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    nickNameFuture = _loadUserDataForKey("nickName");
  }

  Future<String> _loadUserDataForKey(String key) async {
    return await storage.read(key: key) ?? "";
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: 56,
        leading: Center(
          child: BackButton(
            color: Colors.black,
          ),
        ),
        title: Text(
          "회원탈퇴",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            FutureBuilder<String>(
              future: nickNameFuture,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Loading spinner while waiting for data
                } else if (snapshot.hasError) {
                  return Text('Error loading nickname');
                } else {
                  return Text(
                      "${snapshot.data}님... 정말 탈퇴하시겠어요?",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                );
                }
                },
            ),
            SizedBox(height: 25),
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 22,
            ),
            SizedBox(height: 10),
            Text(
              "지금 탈퇴하시면 더이상 카풀 서비스를 이용할 수 없어요!",
              style: TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "탈퇴하시려는 이유를 알려주세요!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
            ),
            SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black),
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: "이유를 입력해주세요",
                  border: InputBorder.none,
                ),
                maxLines: 10,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteAuthDialog();
                  },
                );

                // Carpool

              },
              child: Text('탈퇴하기'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(horizontal: 90, vertical: 10),
                primary: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(home: SecessionPage()));

//탈퇴하기를 누르면 dialog 뜨고 아이디 비밀번호 입력하고 맞으면 확인 눌러서 탈퇴 로직 구현