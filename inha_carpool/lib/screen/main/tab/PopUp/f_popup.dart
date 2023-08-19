import 'package:flutter/material.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:inha_Carpool/common/extension/snackbar_context_extension.dart';
import '../../../../common/widget/round_button_theme.dart';
import '../../../../common/widget/w_arrow.dart';
import '../../../../common/widget/w_round_button.dart';
import '../../../../common/widget/w_text_badge.dart';
import '../../../dialog/d_color_bottom.dart';
import '../../../dialog/d_confirm.dart';
import '../../../dialog/d_message.dart';

class PopUpFragment extends StatelessWidget {
  const PopUpFragment({
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
          const Height(20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Arrow 위젯 - 아래 화살표"), // 위젯 이름 표시
              Arrow(size: 30,),
            ],
          ),
          SizedBox(height: 8), // 간격 8 추가

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue), // 파란색 테두리 추가
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("TextFieldWithDelete 위젯"), // 위젯 이름 표시

              ],
            ),
          ),
          SizedBox(height: 8), // 간격 8 추가
          // TextBadge 위젯
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue), // 파란색 테두리 추가
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("TextBadge 위젯"), // 위젯 이름 표시
                TextBadge(
                  text: "텍스트벳지",
                  backgroundColor: AppColors.blue,
                  textColor: AppColors.veryDarkGrey,
                  fontSize: 16,
                  borderRadius: 10,
                  verticalPadding: 8,
                  horizontalPadding: 12,
                  rightWidget: Icon(Icons.star),
                  onTap: () {
                    print("텍스트벳지 클릭!");
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 8), // 간격 8 추가

          // ... 나머지 위젯들 ...

          const EmptyExpanded(),
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
