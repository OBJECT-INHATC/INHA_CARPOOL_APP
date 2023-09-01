import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../service/sv_auth.dart';
import '../login/s_login.dart';

class DeleteAuthDialog extends StatefulWidget {
  final String email;
  final String password;
  const DeleteAuthDialog( this.email, String this.password, {super.key});

  @override
  State<DeleteAuthDialog> createState() => _DeleteAuthDialogState();
}

class _DeleteAuthDialogState extends State<DeleteAuthDialog> {


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width; //화면의 가로길이

    return AlertDialog(
      //경고창
      insetPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      //경고창의 내부여백
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      //모서리 둥글게
      content: SizedBox(
        //경고창의 크기
        width: width, // -20을 해주는 이유는 경고창의 내부여백이 20이기 때문
        // height: 150, //경고창의 높이
        child: Column(
          //열
          children: [

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [


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
                    onPressed: () async{
                      String realDelete = await AuthService().deleteAccount(widget.email, widget.password);
                      if(realDelete == "Success"){
                        AuthService().signOut().then((value) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                                (Route<dynamic> route) => false,
                          );
                        });} // 로그아웃


// Carpool

                    },
                    child: Text('정말 탈퇴하기'),
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

          ],
        ),
      ),
    );
  }
}
