import 'package:flutter/material.dart';

import '../carpool/s_chatroom.dart';


class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {


    return ListView.builder(
      itemCount: 6,
      itemBuilder: (c, i) {
        if (i == 0) {
          return Container(
            margin: EdgeInsets.all(5),
            height: 30,
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[400],
                border: OutlineInputBorder(),
                labelText: '검색',
              ),
            ),
          );
        } else {
          return GestureDetector(
            onTap:(){
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatroomPage()));
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 700,
              height: 100,
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30), //모서리를 둥글게
                  border: Border.all(color: Colors.black12, width: 3)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.gps_fixed),
                      Text("주안역 "),
                      Text("  08.03 14:52")
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.gps_fixed),
                      Text("인하공전"),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
=======
import 'package:fast_app_base/common/common.dart';
import 'package:fast_app_base/common/widget/round_button_theme.dart';
import 'package:fast_app_base/common/widget/w_round_button.dart';
import 'package:fast_app_base/screen/dialog/d_message.dart';
import 'package:flutter/material.dart';

import '../../../dialog/d_color_bottom.dart';
import '../../../dialog/d_confirm.dart';

class HomeFragment extends StatelessWidget {
  const HomeFragment({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => openDrawer(context),
                icon: const Icon(Icons.menu),
              )
            ],
          ),
          const EmptyExpanded(),
          RoundButton(
            text: 'Snackbar 보이기',
            onTap: () => showSnackbar(context),
            theme: RoundButtonTheme.blue,
          ),
          const Height(20),
          RoundButton(
            text: 'Confirm 다이얼로그',
            onTap: () => showConfirmDialog(context),
            theme: RoundButtonTheme.whiteWithBlueBorder,
          ),
          const Height(20),
          RoundButton(
            text: 'Message 다이얼로그',
            onTap: showMessageDialog,
            theme: RoundButtonTheme.whiteWithBlueBorder,
          ),
          const Height(20),
          RoundButton(
            text: '메뉴 보기',
            onTap: () => openDrawer(context),
            theme: RoundButtonTheme.blink,
          ),
          const EmptyExpanded()
        ],
      ),
    );
  }

  void showSnackbar(BuildContext context) {
    context.showSnackbar('snackbar 입니다.',
        extraButton: Tap(
          onTap: () {
            context.showErrorSnackbar('error');
          },
          child: '에러 보여주기 버튼'.text.white.size(13).make().centered().pSymmetric(h: 10, v: 5),
        ));
  }

  Future<void> showConfirmDialog(BuildContext context) async {
    final confirmDialogResult = await ConfirmDialog(
      '오늘 기분이 좋나요?',
      buttonText: "네",
      cancelButtonText: "아니오",
    ).show();
    debugPrint(confirmDialogResult?.isSuccess.toString());

    confirmDialogResult?.runIfSuccess((data) {
      ColorBottomSheet(
        '❤️',
        context: context,
        backgroundColor: Colors.yellow.shade200,
      ).show();
    });

    confirmDialogResult?.runIfFailure((data) {
      ColorBottomSheet(
        '❤️힘내여',
        backgroundColor: Colors.yellow.shade300,
        textColor: Colors.redAccent,
      ).show();
    });
  }

  Future<void> showMessageDialog() async {
    final result = await MessageDialog("안녕하세요").show();
    debugPrint(result.toString());
  }

  void openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }
}
