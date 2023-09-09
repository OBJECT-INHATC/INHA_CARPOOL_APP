// import 'package:flutter/material.dart';
// import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
// import 'package:inha_Carpool/common/extension/context_extension.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
//
//
// class VerificationDialog extends StatefulWidget {
//   const VerificationDialog({super.key});
//
//   @override
//   State<VerificationDialog> createState() => _VerificationDialogState();
// }
//
// class _VerificationDialogState extends State<VerificationDialog> {
//   @override
//   Widget build(BuildContext context) {
//     var width = MediaQuery.of(context).size.width;//화면의 가로길이
//     FirebaseAuth _auth = FirebaseAuth.instance;
//     User? user;
//     String verificationText = "본인인증 대기중...";
//
//
//     @override
//     void initState() {
//       super.initState();
//       checkUserStatus();
//     }
//
//     ///인증 여부에 따른 state 변경
//     Future<void> checkUserStatus() async {
//       user = _auth.currentUser;
//       if (user != null) {
//         await user!.reload();
//         if (user!.emailVerified) {
//           setState(() { // This will cause the widget to rebuild with the new text.
//             verificationText = "본인 인증 완료!";
//           });
//         }
//       }
//     }
//
//
//     return  AlertDialog(//경고창
//       surfaceTintColor: Colors.transparent,
//         backgroundColor: null,
//       insetPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),//경고창의 내부여백
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),//모서리 둥글게
//       content: SizedBox(//경고창의 크기
//         width: width - 20,// -20을 해주는 이유는 경고창의 내부여백이 20이기 때문
//         height: context.width(2), //경고창의 높이
//
//         child:
//       ),
//
//     );
//   }
// }
//
