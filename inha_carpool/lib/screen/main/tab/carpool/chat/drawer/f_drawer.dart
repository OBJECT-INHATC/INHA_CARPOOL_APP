import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/data/preference/prefs.dart';
import 'package:inha_Carpool/dto/topic_dto.dart';
import 'package:inha_Carpool/service/sv_fcm.dart';

import '../../../../../../common/models/m_carpool.dart';
import '../../../../../../provider/stateProvider/auth_provider.dart';
import '../../../../../../provider/doing_carpool/doing_carpool_provider.dart';
import '../../../../../../service/api/Api_topic.dart';
import '../../../../../../service/sv_firestore.dart';
import '../../../../../dialog/d_complain_alert.dart';
import '../../../../s_main.dart';
import 'w_chat_notice.dart';
import 'w_location_align.dart';

class ChatDrawer extends ConsumerStatefulWidget {
  const ChatDrawer({
    super.key,
    required this.membersList,
    required this.startTime,
    required this.admin,
    required this.carId,
    required this.startPoint,
    required this.endPoint,
    required this.startPointLnt,
    required this.endPointLnt,
  });

  final List membersList;
  final DateTime startTime;
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
  late final String gender;

  @override
  void initState() {
    uid = ref.read(authProvider).uid ?? "";
    nickName = ref.read(authProvider).nickName ?? "";
    gender = ref.read(authProvider).gender ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = context.width(1);
    final screenHeight = context.height(1);

    // 해당 채팅방 알림 on/off 값을 파베에 있는 값으로 1회 조회하고 상태값으로 들고 있다가 Drawer을 열 때 조회
    final carpoolData = ref.watch(doingProvider);
    final matchingCarpool = carpoolData.firstWhere((element) => element.carId == widget.carId, orElse: () => CarpoolModel());
    bool isChatAlarm = matchingCarpool.isChatAlarmOn ?? Prefs.isPushOnRx.get();

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
            color: context.appColors.logoColor,
            child: Column(
              children: [
                Height(AppBar().preferredSize.height * 1.35),
                Row(
                  children: [
                    Width(screenWidth * 0.05),
                    Text(
                      '카풀 멤버',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),

                    isChatAlarm
                        ? IconButton(
                            onPressed: () {
                              /// 알림 상태 변경
                              print("채팅 알림 끄기");
                              setAlarmState(false);
                            },
                            icon:  Icon(
                              Icons.notifications_active,
                              color: Colors.white,
                              size: screenWidth * 0.07,
                            ),
                          )
                        : IconButton(
                            onPressed: () async {
                              /// 알림 상태 변경
                              print("채팅 알림 켜기");
                             if(Prefs.isPushOnRx.get()){
                               await ApiTopic().saveTopoic(TopicRequstDTO(uid: uid, carId: widget.carId));

                               setAlarmState(true);
                             }else{
                               showOpenDialogAlarm(context, "알림 설정은 내 정보에서 바꿀 수 있습니다.", "알림을 켜주세요!");
                             }
                            },
                            icon:  Icon(
                              Icons.notifications_off,
                              color: Colors.white,
                              size: screenWidth * 0.07,
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
                          _exitCarpool(context, true, true);
                        } else {
                          ///  2. 시간 확인 (10분전)
                          final timeDifference = widget.startTime
                              .difference(DateTime.now())
                              .inMinutes;

                          if (timeDifference > 10) {
                            /// 3. 방장인지 체크
                            if (widget.admin == nickName) {
                              ///  ok "다음 방장은 너다 하고 나가기"
                              _exitCarpool(context, true, false);
                            } else {
                              /// 그냥 나가기
                              _exitCarpool(context, false, false);
                            }
                          } else {
                            /// ok "10분 전이야 아무도 못나가"
                            showOpenDialog(
                                context, "지금은 퇴장할 수 없습니다.", "카풀 퇴장 불가");
                          }
                        }
                      },
                      icon: Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                        size: screenWidth * 0.07,
                      ),
                    ),
                    Width(screenWidth * 0.05),
                    //채팅 알림 설정
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
                      memberName,
                      uid,
                      memberGender,
                      screenHeight,
                    );
                  },
                  leading: Icon(
                    Icons.account_circle,
                    size: screenWidth * 0.1,
                    color: nickName == memberName ? Colors.blue : Colors.black,
                  ),
                  title: Row(
                    children: [
                      memberName.text
                          .size(16)
                          .color(nickName == memberName
                              ? Colors.blue
                              : Colors.black)
                          .make(),
                      const Spacer(),
                      (widget.admin == memberName)
                          ? Icon(
                              Icons.star,
                              color: context.appColors.logoColor,
                              size: screenHeight * 0.0275,
                            )
                          : Container(),
                    ],
                  ),
                  trailing: const Icon(Icons.navigate_next_rounded),
                );
              },
            ),
          ),

          const ChatNotice(),

          const Line(height: 2),

          /// 최 하단 출발지 - 목적지 위젯
          LocationAlign(
            startPoint: widget.startPoint,
            endPoint: widget.endPoint,
            startPointLnt: widget.startPointLnt,
            endPointLnt: widget.endPointLnt,
          ),
          const Height(10),
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

  void _showProfileModal(
      BuildContext context,
      String memberUid,
      String selectedUserNickName,
      String myUid,
      String memberGender,
      double screenHeight) {
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
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                child: Text(
                  '프로필 조회',
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Line(
                height: 1,
                color: Colors.grey,
              ),
              Height(screenHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_search,
                    size: screenHeight * 0.15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Height(screenHeight * 0.03),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(selectedUserNickName,
                              style: TextStyle(
                                  fontSize: screenHeight * 0.025,
                                  fontWeight: FontWeight.w600)),
                          Width(screenHeight * 0.01),
                          Text(
                            memberGender,
                            style: TextStyle(
                                fontSize: screenHeight * 0.02,
                                color: Colors.grey),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          viewProfile(context, memberUid);
                          if (myUid != memberUid) {
                            Navigator.pop(context);

                            /// 유저 신고하기 api 확인
                            print(
                                "ElevatedButton ============? $selectedUserNickName");
                            showDialog(
                              context: context,
                              builder: (context) => ComplainAlert(
                                  reportedNickName: selectedUserNickName,
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

  void setAlarmState(bool isAlarm) {
    ref.read(doingProvider.notifier).setAlarm(widget.carId, isAlarm);

    (isAlarm)
        ? FcmService().subScribeOnlyOne(widget.carId)
        : FcmService().unSubScribeOnlyIOne(widget.carId);
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
  void _exitCarpool(BuildContext context, bool isAdmin, bool isAlone) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          title: const Text(
            '카풀 나가기',
            textAlign: TextAlign.center,
          ),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
          content: isAdmin
              ? const Text(
                  '현재 카풀의 방장 입니다. 정말 나가시겠습니까?',
                  textAlign: TextAlign.center,
                )
              : const Text(
                  '정말로 카풀을 나가시겠습니까?',
                  textAlign: TextAlign.center,
                ),
          actions: [
            Column(
              children: [
                const Line(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () async {
                        print("나가기 버튼 클릭");
                         _exitCarpoolLoding(context, isAlone, isAdmin);
                      },
                      child: const Text('나가기'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('취소'),
                    ),
                  ],
                ),
              ],
            )
          ],
        );
      },
    );
  }

  // 나가기 처리 메소드
   _exitCarpoolLoding(
      BuildContext contextm, bool isAlone, bool isAdmin) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return FutureBuilder(
          // 나가기 처리를 수행하는 비동기 함수
          future: _exitCarpoolFuture(isAlone, isAdmin),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            print("빌더 시작");
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
  Future<void> _exitCarpoolFuture(bool isAlone, bool isAdmin) async {
    print("나가기 처리 시작");
    //서버에서 토픽 삭제
    bool isOpen = await ApiTopic().deleteTopic(uid, widget.carId);

    await FireStoreService().deleteIsChatAlarm(widget.carId, uid);

    if (isOpen) {
      print("스프링부트 서버 성공 ##########");

      // 참여중인 카풀 상태 삭제
      removeProvider(widget.carId);

      await FcmService().unSubScribeTopic(widget.carId);

      if (isAlone) {
        FireStoreService().deleteCarpool(widget.carId);
      } else {
        if (isAdmin) {
          print("혼자가 아니고 방장일 때 퇴장 ");
          await FireStoreService()
              .exitCarpoolAsAdmin(widget.carId, nickName, uid, gender);
        } else {
          print("혼자가 아니고 방장도 아닐 때 퇴장 ");
          await FireStoreService()
              .exitCarpool(widget.carId, nickName, uid, gender);
        }
      }
    } else {
      print("스프링부트 서버 실패 #############");
      if (!mounted) return;
      showOpenDialog(context, "현재 서버가 불안정합니다.\n잠시 후 다시 시도해주세요.", "카풀 삭제 실패");
    }
  }

  // 카풀 삭제 처리 상태관리 (공통)
  void removeProvider(String carId) {
    ref.read(doingProvider.notifier).removeCarpool(carId);
  }

  /// 에러 다이얼로그 (공통)
  void showOpenDialog(BuildContext context, String content, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          title: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
          content: Text(content),
          actions: [
            Column(
              children: [
                const Line(height: 2),
                TextButton(
                  onPressed: () {
                    if (title == "카풀 삭제 실패") {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        Nav.globalContext,
                        MaterialPageRoute(
                          builder: (context) => const MainScreen(),
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // bold
                      Text(
                        '확인',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 알림 on 시 띄울 다이얼로그
  void showOpenDialogAlarm(BuildContext context, String content, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          title: Column(
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          titleTextStyle: const TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
          content: Text(content),
          actions: [
            Column(
              children: [
                const Line(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(temp: 'MyPage'),
                          ),
                        );
                      },
                      child: const Text(
                        '설정 바로가기',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

              ],
            ),
          ],
        );
      },
    );
  }
}
