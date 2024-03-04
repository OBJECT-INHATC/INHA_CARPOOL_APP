import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import 'package:inha_Carpool/service/sv_fcm.dart';
import 'package:nav/nav.dart';

import '../../../../../common/data/preference/prefs.dart';
import '../../../../../common/models/m_carpool.dart';
import '../../../../../common/util/addMember_Exception.dart';
import '../../../provider/doing_carpool/doing_carpool_provider.dart';
import '../../../service/sv_carpool.dart';
import '../../../../../dto/topic_dto.dart';
import '../../../provider/stateProvider/auth_provider.dart';
import '../../../../../service/api/Api_topic.dart';
import '../../../../../service/sv_firestore.dart';
import '../s_main.dart';
import '../tab/carpool/chat/s_chatroom.dart';

final enterProvider = StateProvider<bool>((ref) => false);

class EnterButton extends ConsumerStatefulWidget {
  const EnterButton({super.key, required this.carId, required this.roomGender,  required this.startTime,required this.startPointName, required this.endPointName });
  final String carId;
  final String roomGender;
  final String startPointName;
  final String endPointName;
  final int startTime;

  @override
  ConsumerState<EnterButton> createState() => _MapButtonState();
}

class _MapButtonState extends ConsumerState<EnterButton> {
  @override
  Widget build(BuildContext context) {

    final carpoolProvider = ref.watch(doingProvider.notifier);

    final enterState = ref.watch(enterProvider.notifier);

    final String nickName = ref.read(authProvider).nickName!;
    final String uid = ref.read(authProvider).uid!;
    final String gender = ref.read(authProvider).gender!;

    bool joinButtonEnabled = true;


    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: ElevatedButton(
        onPressed: () async {
          enterState.state = true;

          String carId = widget.carId;
          String selectedRoomGender = widget.roomGender;

          if (joinButtonEnabled) {
            joinButtonEnabled = false;

            /// 성별 확인
            if (gender != selectedRoomGender && selectedRoomGender != '무관') {
              context.showErrorSnackbar('입장할 수 없는 성별입니다.\n다른 카풀을 이용해주세요!');
              return;
            }

            try {
              /// 1. 카풀 참가 파이어베이스 저장
              await CarpoolService().addMemberToCarpool(
                  carId, uid, nickName, gender, selectedRoomGender);
              /// 2. 알림을 위한 토픽 추가
              FcmService().subScribeTopic(carId);

              /// 3. 카풀 참가 서버 저장
              bool isOpen = await ApiTopic().saveTopoic(TopicRequstDTO(uid: uid, carId: carId));

              /// 서버 저장 성공시
              if (isOpen) {
                /// 참가 상태관리 저장
                carpoolProvider.addCarpool(CarpoolModel(
                    /// 디테일 주소 수정 필요 0207
                    isChatAlarmOn: true,
                    carId: carId,
                    endDetailPoint: widget.endPointName,
                    endPointName: widget.endPointName,
                    startPointName: widget.startPointName,
                    startDetailPoint: widget.startPointName,
                    startTime: widget.startTime,
                    recentMessageSender: "service",
                    recentMessage: "$nickName님이 입장하였습니다."));
                if (!mounted) return;
                enterState.state = false;
                /// 메소드 정상 성공, 페이지 이동 및 채팅방 입장
                Navigator.pop(context);
                Navigator.pushReplacement(Nav.globalContext,
                    MaterialPageRoute(builder: (context) => const MainScreen()));
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ChatroomPage(
                              carId: carId,
                            )));
              } else {
                print("스프링부트 서버 실패, 저장 정보 회수 후 다이얼로그 처리");
                enterState.state = false;
                await FireStoreService()
                    .exitCarpool(carId, nickName, uid, gender);
                if (Prefs.isPushOnRx.get() == true) {
                  await FirebaseMessaging.instance.unsubscribeFromTopic(carId);
                  await FirebaseMessaging.instance
                      .unsubscribeFromTopic("${carId}_info");
                }
                if (!mounted) return;
                Navigator.pop(context);
                showErrorDialog(context, '서버에 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.');
              }
            } catch (error) {
              enterState.state = false;
              if (error is DeletedRoomException) {
                // 방 삭제 예외 처리
                showErrorDialog(context, error.message);
              } else if (error is MaxCapacityException) {
                // 인원 초과 예외 처원리
                showErrorDialog(context, error.message);
              } else {
                // 기타 예외 처리
                print('카풀 참가 실패 (예외): $error');
              }
            }
            setState(() {
              joinButtonEnabled = true;
            });
          } else {
            enterState.state = false;

            context.showErrorSnackbar('참가 중입니다. 잠시만 기다려주세요.');
          }

        },
        style: ElevatedButton.styleFrom(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.blue,
          textStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          child: const Text(
            '입장하기',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }



  /// 에러 다이얼로그
  void showErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.transparent,
          title: const Text('카풀 참가 실패'),
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
