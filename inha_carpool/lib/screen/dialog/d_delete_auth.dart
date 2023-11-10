import 'package:flutter/material.dart';

import '../../service/sv_auth.dart';
import '../login/s_login.dart';

class DeleteAuthDialog extends StatefulWidget {
  final String email;
  final String password;
  const DeleteAuthDialog( this.email, this.password, {super.key});

  @override
  State<DeleteAuthDialog> createState() => _DeleteAuthDialogState();
}

class _DeleteAuthDialogState extends State<DeleteAuthDialog> {


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
     content: SingleChildScrollView(
       child: Column(
         children: [
           Padding(
             padding: const EdgeInsets.all(16),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 const SizedBox(height: 20),
                 const Align(
                   alignment: Alignment.centerLeft,
                   child: Text(
                     "탈퇴 사유를 입력해 주세요!",
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                     textAlign: TextAlign.left,
                   ),
                 ),
                 const SizedBox(height: 10),
                 Container(
                   width: double.infinity,
                   padding: const EdgeInsets.all(10),
                   decoration: BoxDecoration(
                     borderRadius: BorderRadius.circular(10),
                     border: Border.all(color: Colors.black),
                   ),
                   child: TextFormField(
                     decoration: const InputDecoration(
                       hintText: "이유를 입력해 주세요",
                       border: InputBorder.none,
                     ),
                     maxLines: 10,
                   ),
                 ),
                 const SizedBox(height: 20),
                 ElevatedButton(
                   onPressed: () async{
                     String realDelete = await AuthService().deleteAccount(widget.email, widget.password);
                     if(realDelete == "Success"){
                       AuthService().signOut().then((value) {
                         Navigator.pushAndRemoveUntil(
                           context,
                           MaterialPageRoute(
                               builder: (context) => const LoginPage()),
                               (Route<dynamic> route) => false,
                         );
                       })
                       ;
                     } // 로그인
                   },
                   style: ElevatedButton.styleFrom(
                     surfaceTintColor: Colors.transparent,
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(10.0),
                     ),
                     padding: const EdgeInsets.symmetric(horizontal: 90, vertical: 10),
                     primary: Colors.grey[300],
                   ),
                   child: const Text('정말 탈퇴하기'),
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
