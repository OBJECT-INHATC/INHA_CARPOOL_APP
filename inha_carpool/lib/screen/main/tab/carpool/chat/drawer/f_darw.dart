import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:inha_Carpool/common/common.dart';

import '../../../../../../provider/auth/auth_provider.dart';
import '../../../../../dialog/d_complainAlert.dart';
import '../../../../s_main.dart';
import '../../../home/enum/mapType.dart';
import '../w_map_icon.dart';

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
  @override
  Widget build(BuildContext context) {
    final screenWidth = context.width(1);
    final screenHeight = context.height(1);

    final authState = ref.watch(authProvider);


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
                    IconButton(
                      onPressed: () async {
                        /// 혼자면 그냥 나가라
                        if (widget.membersList.length == 1) {
                        //  _exitIconBtn(context);
                        } else {
                          final timeDifference = widget.agreedTime
                              .difference(DateTime.now())
                              .inMinutes;
                          if (timeDifference > 10) {
                            /// 출발 시간과 현재 시간 사이의 차이가 10분 이상인 경우 나가기 작업 수행
                          //  _exitIconBtn(context);
                          } else {
                            /// 10분 미만은 못 나감

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
                      authState.uid!,
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
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.01),
              child: Column(
                children: [
                  ChatLocation(
                    title: '출발지',
                    location: widget.startPoint,
                    point: widget.startPointLnt,
                    mapCategory: MapCategory.start,
                  ),
                  const Line(height: 1),
                  ChatLocation(
                    title: '도착지',
                    location: widget.endPoint,
                    point: widget.endPointLnt,
                    mapCategory: MapCategory.end,
                  ),
                ],
              ),
            ),
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
                          viewProfile(context, myUid, memberUid);
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
  void viewProfile(BuildContext context, String? uid, String memberId) {
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
}
