// /*
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
// import 'package:inha_Carpool/common/common.dart';
// import 'package:inha_Carpool/service/sv_fcm.dart';
//
// import '../../../../../../common/data/preference/prefs.dart';
// import '../../../../../../common/widget/w_line.dart';
// import '../../../../../../provider/current_carpool/carpool_provider.dart';
// import '../../../../../../service/api/Api_topic.dart';
// import '../../../../../../service/sv_firestore.dart';
// import '../../../../s_main.dart';
//
// class ExitCarpoolDialog extends ConsumerWidget {
//   const ExitCarpoolDialog({super.key, required this.admin, required this.nickName, required this.memberLenth});
//   final String admin;
//   final String nickName;
//   final int memberLenth;
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//
//     final width = context.width(1);
//
//     return AlertDialog(
//       surfaceTintColor: Colors.transparent, // 틴트 빼기
//       backgroundColor: Colors.white, // 다이얼로그 배경색
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.exit_to_app_outlined, color: Colors.red),
//           Text('카풀 나가기', style: TextStyle(fontSize: width * 0.04, fontWeight: FontWeight.bold)),
//         ],
//       ),
//       content: admin == nickName
//           ? const Text('현재 카풀의 방장 입니다. \n 정말 나가시겠습니까?')
//           : const Text('정말로 카풀을 나가시겠습니까?'),
//       actions: <Widget>[
//         Line(color: context.appColors.divider),
//
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             TextButton(
//               onPressed: () async{
//
//               },
//               child: const Text('예'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('아니오'),
//             ),
//           ],
//         ),
//
//       ],
//     );
//
//   }
//
//
//   void _exitIconBtn(BuildContext context, agreedTime) {
//     final currentTime = DateTime.now();
//     final timeDifference = agreedTime.difference(currentTime);
//     final minutesDifference = timeDifference.inMinutes;
//
//
//     if(memberLenth == 1){
//       AlertDialog(
//         surfaceTintColor: Colors.transparent,
//         title: const Text('카풀 취소'),
//         content: const Text('정말로 카풀을 삭제하시겠습니까'),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text('취소'),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               // 나가기 메소드
//               _exitCarpool(context);
//             },
//             child: const Text('나가기'),
//           ),
//         ],
//       );
//     }
//
//     // 출발 시간과 현재 시간 사이의 차이가 10분 이상인 경우 나가기 작업 수행
//     else if (minutesDifference > 10) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             surfaceTintColor: Colors.transparent,
//             title: const Text('카풀 나가기'),
//             content: admin == nickName
//                 ? const Text('현재 카풀의 방장 입니다. \n 정말 나가시겠습니까?')
//                 : const Text('정말로 카풀을 나가시겠습니까?'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text('취소'),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   Navigator.pop(context);
//                   // 나가기 메소드
//                   _exitCarpool(context);
//                 },
//                 child: const Text('나가기'),
//               ),
//             ],
//           );
//         },
//       );
//     } else {
//
//     }
//   }
//
//   //--------------------------------------------------
//
//   // 나가기 처리 메소드
//   void _exitCarpool(BuildContext context) async {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return FutureBuilder(
//           // 나가기 처리를 수행하는 비동기 함수
//           future: _exitCarpoolFuture("uid", "car"),
//           builder: (BuildContext context, AsyncSnapshot snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return AlertDialog(
//                 backgroundColor: Colors.black.withOpacity(0.5),
//                 surfaceTintColor: Colors.transparent,
//                 title: const Text(''),
//                 content: Container(
//                   height: 80,
//                   alignment: Alignment.center,
//                   child: const Center(
//                     child: Column(
//                       children: [
//                         Center(
//                           child: SpinKitThreeBounce(
//                             color: Colors.white,
//                             size: 25,
//                           ),
//                         ),
//                         Text(
//                           "나가는 중",
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 15,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             } else {
//               if (snapshot.error != null) {
//                 // 에러가 발생한 경우
//                 return const AlertDialog(
//                   title: Text('카풀 나가기'),
//                   content: Text('카풀 나가기에 실패했습니다.'),
//                 );
//               } else {
//                 // 나가기 처리가 완료된 경우
//                 WidgetsBinding.instance.addPostFrameCallback(
//                       (_) {
//                     Navigator.pop(context);
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => const MainScreen(),
//                       ),
//                     );
//                   },
//                 );
//                 return Container(); // 빈 컨테이너를 반환
//               }
//             }
//           },
//         );
//       },
//     );
//   }
//
//
//   /// 나가기 처리를 수행하는 비동기 함수
//   Future<void> _exitCarpoolFuture(uid, carId, ref, gender) async {
//     bool isOpen = await ApiTopic().deleteTopic(uid, carId);
//
//     removeProvider(carId, ref);
//
//     if (isOpen) {
//       print("스프링부트 서버 성공 ##########");
//       FcmService().subScribeTopic(carId);
//
//       if (admin != nickName) {
//         await FireStoreService().exitCarpool(carId, nickName, uid, gender);
//       } else {
//         await FireStoreService().exitCarpoolAsAdmin(carId, nickName, uid, gender);
//       }
//
//     } else {
//       print("스프링부트 서버 실패 #############");
//     //  showErrorDialog(context, "현재 서버가 불안정합니다.\n잠시 후 다시 시도해주세요.");
//     }
//   }
//
//   /// 나가기 불가 메소드
//   void _exitImpossible(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           surfaceTintColor: Colors.transparent,
//           title: const Text('카풀 나가기 불가'),
//           content: const Text('카풀 시작 10분 전이므로 불가능합니다.'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text('확인'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   void removeProvider(String carId, ref) {
//     ref.read(carpoolNotifierProvider.notifier).removeCarpool(carId);
//   }
//
// }
// */
