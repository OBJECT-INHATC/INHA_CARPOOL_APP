import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/service/sv_fcm.dart';

import '../../../../../../common/data/preference/prefs.dart';
import '../../../../../../provider/auth/auth_provider.dart';
import '../../../../../../provider/current_carpool/carpool_provider.dart';
import '../../../../../../service/api/Api_topic.dart';
import '../../../../../../service/sv_firestore.dart';
import '../../../../../dialog/d_complainAlert.dart';
import '../../../../s_main.dart';
import '../../../home/enum/mapType.dart';
import '../w_map_icon.dart';
import 'location_align.dart';

class ChatDrawer extends ConsumerStatefulWidget {
  const ChatDrawer(
      {super.key,
      required this.membersList,
      required this.agreedTime,
      required this.admin,
      required this.carId,
      required this.startPoint,
      required this.endPoint,
      required this.startPointLnt,
      required this.endPointLnt, });

  final List membersList;
  final DateTime agreedTime;
  final String admin;
  final String carId;
  final String startPoint;
  final String endPoint;
  final LatLng startPointLnt;
  final LatLng endPointLnt;

  @override
  ConsumerState<ChatDrawer> createState() => _ChatDrawerState();
}

class _ChatDrawerState extends ConsumerState<ChatDrawer> {

  late final String uid;
  late final String nickName;

  @override
  void initState() {
    uid = ref.read(authProvider).uid ?? "";
    nickName = ref.read(authProvider).nickName ?? "";
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.width(1);
    final screenHeight = context.height(1);

    return Drawer(
      surfaceTintColor: Colors.transparent,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        children: [
          //-------------------------------대화상대 상단
          Container(
            height: screenHeight * 0.15,
            width: double.infinity,
            color: context.appColors.logoColor,
            child: Column(
              children: [
                Height(screenWidth * 0.17),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                     Text(
                      '카풀 멤버',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    /*
                    1. 인원수 1명인지 확인
                      ok "나 혼자네? 그냥 나가기"
                      no
                        2. 시간 확인 (10분전)
                          ok "10분 전이야 아무도 못나가"
                          no
                            3. 방장인지 체크
                                ok "다음 방장은 너다 하고 나가기"
                                no "그냥 나가기"
                     */
                    IconButton(
                      onPressed: () async {
                        ///   1. 인원수 1명인지 확인
                        if (widget.membersList.length == 1) {
                          /// "나 혼자네? 그냥 나가기"
                          _deleteAdmin(context, true);
                        } else {
                          ///  2. 시간 확인 (10분전)
                          final timeDifference = widget.agreedTime
                              .difference(DateTime.now())
                              .inMinutes;
                          if (timeDifference > 10) {
                           /// 3. 방장인지 체크
                            if(widget.admin == nickName){
                              ///  ok "다음 방장은 너다 하고 나가기"
                              _deleteAdmin(context, false);
                            } else {
                              /// 그냥 나가기

                            }
                          } else {
                           /// ok "10분 전이야 아무도 못나가"

                          }





                        }
                      },
                      icon:  Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                        size: screenWidth * 0.07,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          //---------------------------------대화상대 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: widget.membersList.length >= 4
                  ? 4
                  : widget.membersList.length,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                String memberName = getName(widget.membersList[index]);
                String memberGender = getGender(widget.membersList[index]);
                String memberId = getMemberId(widget.membersList[index]);

                return ListTile(
                  onTap: () {
                    _showProfileModal(
                      context,
                      memberId,
                      '$memberName 님',
                       uid,
                      memberGender,
                    );
                  },
                  leading: Icon(
                    Icons.account_circle,
                    size: 35,
                    color: widget.admin == memberName
                        ? Colors.blue
                        : Colors.black,
                  ),
                  title: Row(
                    children: [
                      memberName.text
                          .size(16)
                          .color(widget.admin == memberName
                              ? Colors.blue
                              : Colors.black)
                          .make(),
                    ],
                  ),
                  trailing: const Icon(Icons.navigate_next_rounded),
                );
              },
            ),
          ),
          // 경계라인을 위젯으로 만들어서 사용
          const Line(height: 2),
          /// 최 하단 출발지 - 목적지 위젯
          LocationAlign(
            startPoint: widget.startPoint,
            endPoint: widget.endPoint,
            startPointLnt: widget.startPointLnt,
            endPointLnt: widget.endPointLnt,
          ),
        ],
      ),
    );
  }

  String getName(String res) {
    int start = res.indexOf("_") + 1;
    int end = res.lastIndexOf("_");
    return res.substring(start, end);
  }

  String getGender(String res) {
    String gender = res.substring(res.lastIndexOf("_") + 1);
    return gender;
  }

  // 1002,memberId
  String getMemberId(String res) {
    int start = 0;
    int end = res.indexOf("_");
    return res.substring(start, end);
  }





  void _showProfileModal(BuildContext context, String memberUid, String nickName, String myUid,
      String memberGender) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          // 크기 지정
          height: context.height(0.35),
          width: double.infinity,

          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                margin: const EdgeInsets.all(10.0),
                alignment: Alignment.center,
                child: const Text(
                  '프로필 조회',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(
                height: 1,
                color: Colors.grey,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    margin: const EdgeInsets.fromLTRB(20, 5, 0, 0),
                    alignment: Alignment.centerLeft,
                    child: const Icon(
                      Icons.person_search,
                      size: 120,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nickName,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                      Text(
                        memberGender,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          viewProfile(context, memberUid);
                          if (myUid != memberUid) {
                            Navigator.pop(context);
                            showDialog(
                              context: context,
                              builder: (context) => ComplainAlert(
                                  reportedNickName: nickName,
                                  myId: nickName,
                                  carpoolId: widget.carId),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          surfaceTintColor: Colors.transparent,
                          backgroundColor:
                          const Color.fromARGB(255, 255, 167, 2),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                                (myUid == memberUid)
                                    ? Icons.double_arrow_rounded
                                    : Icons.warning_rounded,
                                color: (myUid == memberUid)
                                    ? Colors.white
                                    : Colors.white),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              (myUid == memberUid) ? "프로필로 이동" : "신고하기",
                              style: TextStyle(
                                  color: (myUid == memberUid)
                                      ? Colors.white
                                      : Colors.white,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  //uid와 memberID비교
  void viewProfile(BuildContext context, String memberId) {
    if (uid == memberId) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(temp: 'MyPage'),
        ),
      );
    }
  }

  // 방장이고 혼자 -> isAdmin = true
  void _deleteAdmin(BuildContext context, bool isAlone) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            surfaceTintColor: Colors.transparent,
            title: const Text('카풀 나가기'),
            content: const Text('현재 카풀의 방장 입니다. \n 정말 나가시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  if(isAlone == true){
                    // 나가기 메소드
                    _exitCarpoolLoding(context);
                  }else{
                    _exitCarpoolLoding(context);
                  }
                },
                child: const Text('나가기'),
              ),
            ],
          );
        },
      );
    }



  // 나가기 처리 메소드
  void _exitCarpoolLoding(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return FutureBuilder(
          // 나가기 처리를 수행하는 비동기 함수
          future: _exitCarpoolFuture(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                backgroundColor: Colors.black.withOpacity(0.5),
                surfaceTintColor: Colors.transparent,
                title: const Text(''),
                content: Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: const Center(
                    child: Column(
                      children: [
                        Center(
                          child: SpinKitThreeBounce(
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                        Text(
                          "나가는 중",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              if (snapshot.error != null) {
                // 에러가 발생한 경우
                return const AlertDialog(
                  title: Text('카풀 나가기'),
                  content: Text('카풀 나가기에 실패했습니다.'),
                );
              } else {
                // 나가기 처리가 완료된 경우
                WidgetsBinding.instance.addPostFrameCallback(
                      (_) {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainScreen(),
                      ),
                    );
                  },
                );
                return Container(); // 빈 컨테이너를 반환
              }
            }
          },
        );
      },
    );
  }



  /// 나가기 처리를 수행하는 비동기 함수 (공통)
  Future<void> _exitCarpoolFuture() async {
    //서버에서 토픽 삭제
    bool isOpen = await ApiTopic().deleteTopic(uid, widget.carId);

    if (isOpen) {
      print("스프링부트 서버 성공 ##########");

      // 참여중인 카풀 상태 삭제
      removeProvider(widget.carId);

      // FCM 토픽 구독해제
      FcmService().unSubScribeTopic(widget.carId);

      FireStoreService().deleteCarpool(widget.carId);

    } else {
      print("스프링부트 서버 실패 #############");
      if (!mounted) return;
      showErrorDialog(context, "현재 서버가 불안정합니다.\n잠시 후 다시 시도해주세요.");
    }
  }

  // 카풀 삭제 처리 상태관리 (공통)
  void removeProvider(String carId) {
    ref.read(carpoolNotifierProvider.notifier).removeCarpool(carId);
  }

  /// 에러 다이얼로그 (공통)
  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          title: const Text('카풀 삭제 실패'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  Nav.globalContext,
                  MaterialPageRoute(
                    builder: (context) => const MainScreen(),
                  ),
                );
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  }

