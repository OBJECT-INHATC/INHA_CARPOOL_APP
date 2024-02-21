import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:inha_Carpool/common/common.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../provider/notice/notice_provider.dart';

/// * 외부 URL와 연결된 공지사항 위젯 (추후 광고나 학교 공지로 이동 -> 파이어베이스 admin 컬렉션에 저장) 0207 이상훈
class NoticeBox extends ConsumerStatefulWidget {
  const NoticeBox(this.cardHeight, this.noticeType, {super.key});
  final double cardHeight;
  final String noticeType;

  @override
  ConsumerState<NoticeBox> createState() => _NoticeBoxState();
}

class _NoticeBoxState extends ConsumerState<NoticeBox> {
  late Uri uri;
  late String noticeText;

  @override
  Widget build(BuildContext context) {
    final noticeNotifier = ref.watch(noticeNotifierProvider);
    final screenWidth = context.screenWidth;

    if(widget.noticeType == "main"){
      if(noticeNotifier.mainContext == "") {
        noticeText = "인하카풀은 무료이며 재학생을 위한 서비스입니다.";
      }else{
        noticeText = noticeNotifier.mainContext;
        uri = Uri.parse(noticeNotifier.mainUri);
      }
    }else{
      if(noticeNotifier.carpoolContext == "") {
        noticeText = "신입생 여러분들의 입학을 진심으로 환영합니다!";
      }else{
        noticeText = noticeNotifier.carpoolContext;
        uri = Uri.parse(noticeNotifier.carpoolUri);
      }
    }

    return GestureDetector(
      onTap: () async {
        if (!await launchUrl(uri)) {
          throw Exception('Could not launch $uri');
        }
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        height: widget.cardHeight / 4,
        width: screenWidth,
        alignment: Alignment.center, // 가운데 정렬 추가
        decoration: BoxDecoration(
          color: Colors.white, // 배경색 설정
          border: Border.all(
            color: context
                .appColors.logoColor, // 테두리 색 설정
          ),
        ),
        child: Text(
          noticeText,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.appColors.logoColor,
          ),
        ),
      ),
    );
  }
}
